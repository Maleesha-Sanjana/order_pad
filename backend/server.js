const express = require('express');
const cors = require('cors');
const sql = require('mssql');
const config = require('./config');
const http = require('http');
const WebSocket = require('ws');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Database connection pool
let pool;

// WebSocket server
let wss;
const connectedClients = new Set();

// Initialize database connection
async function initializeDatabase() {
  let retries = 5;
  let delay = 2000; // Start with 2 seconds delay
  
  while (retries > 0) {
    try {
      console.log(`🔌 Attempting to connect to database (${6-retries}/5)...`);
      pool = await sql.connect(config);
      console.log('✅ Connected to SQL Server database');
      return; // Success, exit the function
    } catch (err) {
      retries--;
      console.error(`❌ Database connection failed (${6-retries}/5):`, err.message);
      
      if (retries > 0) {
        console.log(`⏳ Retrying in ${delay/1000} seconds...`);
        await new Promise(resolve => setTimeout(resolve, delay));
        delay *= 1.5; // Exponential backoff
      } else {
        console.error('❌ Failed to connect to database after 5 attempts');
        console.log('⚠️  Server will continue running but API endpoints will fail without database connection');
        pool = null; // Set pool to null to indicate no database connection
      }
    }
  }
}

// Initialize database on startup
initializeDatabase();

// ==================== WEBSOCKET SERVER ====================

// Initialize WebSocket server
function initializeWebSocket(server) {
  wss = new WebSocket.Server({ 
    server,
    path: '/ws',
    perMessageDeflate: false
  });

  wss.on('connection', (ws, req) => {
    console.log('🔌 WebSocket client connected from:', req.socket.remoteAddress);
    connectedClients.add(ws);

    // Send connection status
    ws.send(JSON.stringify({
      type: 'connection_status',
      status: 'connected',
      timestamp: new Date().toISOString()
    }));

    // Handle client messages
    ws.on('message', (message) => {
      try {
        const data = JSON.parse(message);
        console.log('📨 WebSocket message received:', data.type);
        
        switch (data.type) {
          case 'ping':
            ws.send(JSON.stringify({
              type: 'pong',
              timestamp: new Date().toISOString()
            }));
            break;
          case 'subscribe':
            // Handle subscription to specific data types
            console.log('📝 Client subscribed to:', data.dataTypes);
            break;
          default:
            console.log('⚠️ Unknown WebSocket message type:', data.type);
        }
      } catch (error) {
        console.error('❌ Error processing WebSocket message:', error);
      }
    });

    // Handle client disconnect
    ws.on('close', () => {
      console.log('🔌 WebSocket client disconnected');
      connectedClients.delete(ws);
    });

    // Handle errors
    ws.on('error', (error) => {
      console.error('❌ WebSocket error:', error);
      connectedClients.delete(ws);
    });
  });

  console.log('✅ WebSocket server initialized');
}

// Broadcast data changes to all connected clients
function broadcastDataChange(dataType, data) {
  if (connectedClients.size === 0) return;

  const message = JSON.stringify({
    type: 'data_change',
    dataType: dataType,
    data: data,
    timestamp: new Date().toISOString()
  });

  console.log(`📡 Broadcasting ${dataType} change to ${connectedClients.size} clients`);
  
  connectedClients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(message);
    } else {
      // Remove disconnected clients
      connectedClients.delete(client);
    }
  });
}

// Check for data changes endpoint
app.get('/api/sync/check-changes', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    const { type } = req.query;
    
    let query;
    switch (type) {
      case 'departments':
        query = 'SELECT MAX(ModifiedDate) as lastModified FROM inv_department';
        break;
      case 'products':
        query = 'SELECT MAX(ModifiedDate) as lastModified FROM inv_productmaster';
        break;
      case 'suspend_orders':
        query = 'SELECT MAX(CreatedDate) as lastModified FROM inv_suspend';
        break;
      case 'orders':
        query = 'SELECT MAX(CreatedDate) as lastModified FROM inv_orders';
        break;
      default:
        return res.status(400).json({ error: 'Invalid data type' });
    }
    
    const result = await pool.request().query(query);
    const lastModified = result.recordset[0]?.lastModified || new Date(0);
    
    res.json({
      success: true,
      dataType: type,
      lastModified: lastModified.toISOString(),
      hasChanges: true // For now, always return true to trigger updates
    });
  } catch (err) {
    console.error('Error checking data changes:', err);
    res.status(500).json({ error: 'Failed to check data changes' });
  }
});

// ==================== API ROUTES ====================

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'POS Solution API is running' });
});

// Check sysconfig table structure and data
app.get('/api/sysconfig/check', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    // Check if sysconfig table exists
    const tableCheck = await pool.request().query(`
      SELECT * FROM INFORMATION_SCHEMA.TABLES 
      WHERE TABLE_NAME = 'sysconfig'
    `);
    
    if (tableCheck.recordset.length === 0) {
      return res.json({
        success: false,
        message: 'sysconfig table does not exist',
        tableExists: false
      });
    }
    
    // Get columns
    const columns = await pool.request().query(`
      SELECT COLUMN_NAME, DATA_TYPE 
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_NAME = 'sysconfig'
    `);
    
    // Get data
    const data = await pool.request().query(`SELECT * FROM sysconfig`);
    
    res.json({
      success: true,
      tableExists: true,
      columns: columns.recordset,
      data: data.recordset,
      hasUnit: columns.recordset.some(col => col.COLUMN_NAME === 'Unit'),
      hasReceiptNo: columns.recordset.some(col => col.COLUMN_NAME === 'ReceiptNo')
    });
  } catch (err) {
    console.error('Error checking sysconfig:', err);
    res.status(500).json({ error: 'Failed to check sysconfig', details: err.message });
  }
});

// Check and ensure inv_suspend table structure
app.get('/api/suspend-orders/check-structure', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    // Get all columns in the table
    const allColumns = await pool.request().query(`
      SELECT 
        COLUMN_NAME,
        DATA_TYPE,
        IS_NULLABLE,
        COLUMN_DEFAULT,
        COLUMNPROPERTY(OBJECT_ID('inv_suspend'), COLUMN_NAME, 'IsIdentity') as IS_IDENTITY
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_NAME = 'inv_suspend'
      ORDER BY ORDINAL_POSITION
    `);
    
    res.json({
      success: true,
      message: 'Table structure retrieved',
      columns: allColumns.recordset
    });
  } catch (err) {
    console.error('Error checking table structure:', err);
    res.status(500).json({ error: 'Failed to check table structure', details: err.message });
  }
});

// Get next available ID for inv_suspend (DEPRECATED - kept for reference)
// NOTE: Frontend now uses simple sequential IDs (1, 2, 3...) for each receipt
// Each receipt always starts with ID = 1, matching the UI row numbers
// Uniqueness is maintained by: (Table, id) before confirmation, (ReceiptNo, id) after
app.get('/api/suspend-orders/next-id', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    const { tableNumber } = req.query;
    
    if (!tableNumber) {
      return res.status(400).json({ 
        error: 'tableNumber query parameter is required',
        message: 'Usage: /api/suspend-orders/next-id?tableNumber=T01'
      });
    }
    
    // DEPRECATED: This endpoint is no longer used by the frontend
    // Frontend now uses simple 1, 2, 3... IDs that match UI row numbers
    // Keeping this for backward compatibility or future use
    const result = await pool.request()
      .input('tableNumber', sql.NVarChar, tableNumber)
      .query(`
        WITH Numbers AS (
          SELECT 1 AS num
          UNION ALL
          SELECT num + 1
          FROM Numbers
          WHERE num < 999
        )
        SELECT TOP 1 n.num as nextId
        FROM Numbers n
        LEFT JOIN inv_suspend s ON n.num = s.id AND s.[Table] = @tableNumber
        WHERE s.id IS NULL
        ORDER BY n.num
        OPTION (MAXRECURSION 999)
      `);
    
    let nextId;
    if (result.recordset.length > 0) {
      nextId = result.recordset[0].nextId;
    } else {
      console.warn(`⚠️ All IDs from 1-999 are occupied for table ${tableNumber}!`);
      nextId = 1;
    }
    
    console.log(`📋 Next available ID for table ${tableNumber}: ${nextId}`);
    res.json({ 
      success: true, 
      nextId: nextId,
      tableNumber: tableNumber,
      message: `Next available ID for table ${tableNumber}: ${nextId}`
    });
  } catch (err) {
    console.error('Error getting next ID:', err);
    res.status(500).json({ error: 'Failed to get next ID', details: err.message });
  }
});

// Get all departments
app.get('/api/departments', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    const result = await pool.request().query(`
      SELECT * FROM inv_department 
      ORDER BY StandardEAN, DepartmentName
    `);
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching departments:', err);
    res.status(500).json({ error: 'Failed to fetch departments' });
  }
});

// Get sub-departments by department code
app.get('/api/subdepartments/:departmentCode', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    const { departmentCode } = req.params;
    const result = await pool.request()
      .input('departmentCode', sql.NVarChar, departmentCode)
      .query(`
        SELECT * FROM inv_subdepartment 
        WHERE DepartmentCode = @departmentCode
        ORDER BY StandardEAN, SubDepartmentName
      `);
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching sub-departments:', err);
    res.status(500).json({ error: 'Failed to fetch sub-departments' });
  }
});

// Get all products
app.get('/api/products', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    const result = await pool.request().query(`
      SELECT * FROM inv_productmaster 
      WHERE LockProduct = 0 OR LockProduct IS NULL
      ORDER BY ProductName
    `);
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching products:', err);
    res.status(500).json({ error: 'Failed to fetch products' });
  }
});

// Get products by department
app.get('/api/products/department/:departmentCode', async (req, res) => {
  try {
    const { departmentCode } = req.params;
    const result = await pool.request()
      .input('departmentCode', sql.NVarChar, departmentCode)
      .query(`
        SELECT * FROM inv_productmaster 
        WHERE DepartmentCode = @departmentCode
        AND (LockProduct = 0 OR LockProduct IS NULL)
        ORDER BY ProductName
      `);
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching products by department:', err);
    res.status(500).json({ error: 'Failed to fetch products' });
  }
});

// Get products by sub-department
app.get('/api/products/subdepartment/:subDepartmentCode', async (req, res) => {
  try {
    const { subDepartmentCode } = req.params;
    const result = await pool.request()
      .input('subDepartmentCode', sql.NVarChar, subDepartmentCode)
      .query(`
        SELECT * FROM inv_productmaster 
        WHERE SubDepartmentCode = @subDepartmentCode
        AND (LockProduct = 0 OR LockProduct IS NULL)
        ORDER BY ProductName
      `);
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching products by sub-department:', err);
    res.status(500).json({ error: 'Failed to fetch products' });
  }
});

// Authenticate salesman
app.post('/api/auth/login', async (req, res) => {
  try {
    const { salesmanCode, password } = req.body;
    
    // Ensure database connection
    if (!pool) {
      try {
        console.log('🔌 Attempting to connect to database...');
        pool = await sql.connect(config);
        console.log('✅ Database connected successfully');
      } catch (err) {
        console.error('❌ Database connection failed:', err.message);
        return res.status(503).json({ success: false, message: 'Database connection failed' });
      }
    }
    
    console.log(`🔐 Authenticating salesman: ${salesmanCode}`);
    
    const result = await pool.request()
      .input('salesmanCode', sql.NVarChar, salesmanCode)
      .input('password', sql.NVarChar, password)
      .query(`
        SELECT * FROM gen_salesman 
        WHERE SalesmanCode = @salesmanCode 
        AND salesman_password = @password
        AND (BlackListed = 0 OR BlackListed IS NULL)
        AND (Suspend = 0 OR Suspend IS NULL)
      `);
    
    if (result.recordset.length > 0) {
      console.log(`✅ Authentication successful for: ${result.recordset[0].SalesmanName}`);
      res.json({ success: true, salesman: result.recordset[0] });
    } else {
      console.log(`❌ Authentication failed for: ${salesmanCode}`);
      res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
  } catch (err) {
    console.error('Error authenticating salesman:', err);
    res.status(500).json({ success: false, message: 'Authentication failed' });
  }
});

// Password-only authentication endpoint
app.post('/api/auth/login-password', async (req, res) => {
  try {
    const { password } = req.body;
    
    if (!password) {
      return res.status(400).json({ success: false, message: 'Password is required' });
    }
    
    // Ensure database connection
    if (!pool) {
      try {
        console.log('🔌 Attempting to connect to database...');
        pool = await sql.connect(config);
        console.log('✅ Database connected successfully');
      } catch (err) {
        console.error('❌ Database connection failed:', err.message);
        return res.status(503).json({ success: false, message: 'Database connection failed' });
      }
    }
    
    console.log(`🔐 Authenticating with password: ${password}`);
    
    const result = await pool.request()
      .input('password', sql.NVarChar, password)
      .query(`
        SELECT s.*, l.LocationDescription, l.CompanyCode
        FROM gen_salesman s
        LEFT JOIN gen_location l ON s.Location = l.LocationCode
        WHERE s.salesman_password = @password
        AND (s.BlackListed = 0 OR s.BlackListed IS NULL)
        AND (s.Suspend = 0 OR s.Suspend IS NULL)
      `);
    
    if (result.recordset.length > 0) {
      const salesman = result.recordset[0];
      console.log(`✅ Password authentication successful for: ${salesman.SalesmanName}`);
      res.json({ success: true, salesman: salesman });
    } else {
      console.log(`❌ Password authentication failed for password: ${password}`);
      res.status(401).json({ success: false, message: 'Invalid password' });
    }
  } catch (err) {
    console.error('Error authenticating with password:', err);
    res.status(500).json({ success: false, message: 'Authentication failed' });
  }
});


// Get all tables with occupancy status
app.get('/api/tables', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    // Get all tables
    const tablesResult = await pool.request().query(`
      SELECT idx, TableCode, TableName, Location 
      FROM inv_tables 
      ORDER BY TableCode
    `);
    
    // Get occupied tables (tables with unpaid orders in inv_suspend)
    const occupiedTablesResult = await pool.request().query(`
      SELECT DISTINCT [Table] 
      FROM inv_suspend 
      WHERE [Table] IS NOT NULL
    `);
    
    const occupiedTables = new Set(
      occupiedTablesResult.recordset.map(row => row.Table)
    );
    
    // Add isOccupied flag to each table
    const tablesWithStatus = tablesResult.recordset.map(table => ({
      ...table,
      isOccupied: occupiedTables.has(table.TableCode)
    }));
    
    console.log(`✅ Loaded ${tablesWithStatus.length} tables from inv_tables (${occupiedTables.size} occupied)`);
    res.json(tablesWithStatus);
  } catch (err) {
    console.error('Error fetching tables:', err);
    res.status(500).json({ error: 'Failed to fetch tables' });
  }
});

// Get chairs from inv_chair table
app.get('/api/chairs', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    console.log('🔄 Fetching chairs from inv_chair table...');
    const result = await pool.request().query(`
      SELECT 
        TableCode,
        ChairCode,
        ChairName
      FROM inv_chair
      ORDER BY TableCode, ChairCode
    `);
    
    const chairs = result.recordset.map(row => ({
      tableCode: row.TableCode,
      chairCode: row.ChairCode,
      chairName: row.ChairName
    }));
    
    console.log(`✅ Loaded ${chairs.length} chairs from inv_chair table`);
    res.json(chairs);
  } catch (err) {
    console.error('Error fetching chairs:', err);
    res.status(500).json({ error: 'Failed to fetch chairs' });
  }
});

// Get rooms from inv_rooms table with occupancy status
app.get('/api/rooms', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    console.log('🔄 Fetching rooms from inv_rooms table...');
    
    // Get all rooms
    const roomsResult = await pool.request().query(`
      SELECT 
        idx,
        RoomCode,
        RoomName,
        Location
      FROM inv_rooms
      ORDER BY RoomCode
    `);
    
    // Get occupied rooms (rooms with unpaid orders in inv_suspend)
    const occupiedRoomsResult = await pool.request().query(`
      SELECT DISTINCT [Table] 
      FROM inv_suspend 
      WHERE [Table] IS NOT NULL
    `);
    
    const occupiedRooms = new Set(
      occupiedRoomsResult.recordset.map(row => row.Table)
    );
    
    // Add isOccupied flag to each room
    const rooms = roomsResult.recordset.map(row => ({
      idx: row.idx,
      RoomCode: row.RoomCode,
      RoomName: row.RoomName,
      Location: row.Location,
      isOccupied: occupiedRooms.has(row.RoomCode)
    }));
    
    console.log(`✅ Loaded ${rooms.length} rooms from inv_rooms table (${occupiedRooms.size} occupied)`);
    res.json(rooms);
  } catch (err) {
    console.error('Error fetching rooms:', err);
    res.status(500).json({ error: 'Failed to fetch rooms' });
  }
});

// Get all salesmen
app.get('/api/salesmen', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    const result = await pool.request().query(`
      SELECT 
        SalesmanCode as id,
        SalesmanName as name,
        Email as email,
        SalesmanType as role,
        Location as location,
        CASE WHEN BlackListed = 0 AND Suspend = 0 THEN 1 ELSE 0 END as is_active,
        Created_Date as created_at
      FROM gen_salesman 
      WHERE (BlackListed = 0 OR BlackListed IS NULL)
      AND (Suspend = 0 OR Suspend IS NULL)
      ORDER BY SalesmanName
    `);
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching salesmen:', err);
    res.status(500).json({ error: 'Failed to fetch salesmen' });
  }
});

// Get all locations
app.get('/api/locations', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    console.log('🔄 Fetching locations from gen_location...');
    const result = await pool.request().query(`
      SELECT 
        LocationCode,
        LocationDescription,
        CompanyCode,
        Address1,
        Address2,
        Address3,
        Tno,
        Fax,
        Email
      FROM gen_location
      ORDER BY LocationCode
    `);
    
    console.log(`✅ Loaded ${result.recordset.length} locations from database`);
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching locations:', err);
    res.status(500).json({ error: 'Failed to fetch locations' });
  }
});

// Search products
app.get('/api/products/search', async (req, res) => {
  try {
    const { q } = req.query;
    if (!q) {
      return res.status(400).json({ error: 'Search query is required' });
    }
    
    const result = await pool.request()
      .input('searchTerm', sql.NVarChar, `%${q}%`)
      .query(`
        SELECT * FROM inv_productmaster 
        WHERE ProductName LIKE @searchTerm
        AND (LockProduct = 0 OR LockProduct IS NULL)
        ORDER BY ProductName
      `);
    res.json(result.recordset);
  } catch (err) {
    console.error('Error searching products:', err);
    res.status(500).json({ error: 'Search failed' });
  }
});

// ==================== SUSPEND ORDERS ====================

// Get all suspend orders
app.get('/api/suspend-orders', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    const result = await pool.request().query(`
      SELECT * FROM inv_suspend 
      ORDER BY id DESC
    `);
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching suspend orders:', err);
    res.status(500).json({ error: 'Failed to fetch suspend orders' });
  }
});

// Get suspend orders by table
app.get('/api/suspend-orders/table/:tableNumber', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    const { tableNumber } = req.params;
    const result = await pool.request()
      .input('tableNumber', sql.NVarChar, tableNumber)
      .query(`
        SELECT * FROM inv_suspend 
        WHERE [Table] = @tableNumber
        ORDER BY id DESC
      `);
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching suspend orders by table:', err);
    res.status(500).json({ error: 'Failed to fetch suspend orders' });
  }
});

// Create suspend order (add item to cart)
app.post('/api/suspend-orders', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    // Extract fields from request body
    const {
      id, // Can be provided from Flutter UI or auto-generated by database
      ProductCode: productCode,
      ProductDescription: productDescription,
      Unit: unit,
      PackSize: packSize,
      FreeQty: freeQty,
      CostPrice: costPrice,
      UnitPrice: unitPrice,
      WholeSalePrice: wholeSalePrice,
      Qty: qty,
      DiscPer: discPer,
      DiscAmount: discAmount,
      Amount: amount,
      Iid: iid,
      LocaCode: locaCode,
      BatchNo: batchNo,
      StockLoca: stockLoca,
      Tax: tax,
      RowIdx: rowIdx,
      SerialNo: serialNo,
      WarrantyPeriod: warrantyPeriod,
      PeriodDays: periodDays,
      ExpiryDate: expiryDate,
      ReceiptNo: receiptNo,
      SalesMan: salesMan,
      Customer: customer,
      Table: table,
      Chair: chair,
      KotPrint: kotPrint
    } = req.body;
    
    console.log('📋 Request body received:', {
      productCode,
      productDescription,
      unitPrice,
      qty,
      amount,
      salesMan,
      table,
      locaCode,
      batchNo
    });
    
    // Validate and set BatchNo - only allow: "DineIn", "RoomService", or "Takeaway"
    const validBatchNumbers = ['DineIn', 'RoomService', 'Takeaway'];
    let finalBatchNo = batchNo;
    
    if (!finalBatchNo || !validBatchNumbers.includes(finalBatchNo)) {
      finalBatchNo = 'DineIn'; // Default to DineIn
      console.log(`⚠️  Invalid or missing BatchNo. Using default: ${finalBatchNo}`);
    } else {
      console.log(`✅ Valid BatchNo: ${finalBatchNo}`);
    }
    
    // Get location code from gen_salesman if not provided
    let finalLocaCode = locaCode;
    if (!finalLocaCode && salesMan) {
      try {
        const salesmanResult = await pool.request()
          .input('salesmanCode', sql.NVarChar, salesMan)
          .query('SELECT Location FROM gen_salesman WHERE SalesmanCode = @salesmanCode');
        
        if (salesmanResult.recordset.length > 0) {
          finalLocaCode = salesmanResult.recordset[0].Location;
          console.log(`✅ Retrieved location code '${finalLocaCode}' from salesman ${salesMan}`);
        }
      } catch (err) {
        console.error('Error fetching salesman location:', err);
      }
    }
    
    // Fallback to '01' if still no location code
    if (!finalLocaCode) {
      finalLocaCode = '01';
      console.log(`⚠️  No location code found, using default: ${finalLocaCode}`);
    }
    
    // ID column is NOT an identity column - must always be provided
    if (!id) {
      return res.status(400).json({ 
        success: false, 
        error: 'ID is required',
        message: 'The id field must be provided from Flutter UI. Use the # number from your interface.'
      });
    }
    
    console.log(`📋 Using provided ID: ${id}`);
    
    // Don't generate ReceiptNo when adding items to cart
    // Receipt number will be assigned only when order is confirmed
    let finalReceiptNo = receiptNo || null;
    console.log(`📋 ReceiptNo for cart item: ${finalReceiptNo || 'NULL (will be assigned on order confirmation)'}`);

    
    // ALWAYS INSERT NEW ROWS - NEVER UPDATE
    // Even if same product is ordered multiple times, each order gets its own row
    // This preserves order history and allows tracking individual items separately
    
    // KotPrint Logic:
    // - New items (adding to cart): KotPrint = 1 (needs to be printed in kitchen)
    // - Use provided kotPrint value or default to 1
    let finalKotPrint = 1; // Default for new items - MUST be printed
    
    if (kotPrint !== undefined && kotPrint !== null) {
      finalKotPrint = kotPrint ? 1 : 0;
      console.log(`✅ New item ${id} for table ${table} - using provided kotPrint = ${finalKotPrint}`);
    } else {
      finalKotPrint = 1;
      console.log(`✅ New item ${id} for table ${table} - defaulting to kotPrint = 1 (will be sent to kitchen)`);
    }
    
    // ALWAYS INSERT - Each order is a new row
    // Frontend is responsible for providing unique IDs
    try {
      await pool.request()
        .input('id', sql.Int, id)
        .input('productCode', sql.NVarChar, productCode)
        .input('productDescription', sql.NVarChar, productDescription)
        .input('unitPrice', sql.Decimal(18, 2), unitPrice)
        .input('qty', sql.Decimal(18, 2), qty)
        .input('amount', sql.Decimal(18, 2), amount)
        .input('salesMan', sql.NVarChar, salesMan)
        .input('table', sql.NVarChar, table)
        .input('chair', sql.NVarChar, chair || null)
        .input('freeQty', sql.Decimal(18, 2), freeQty || 0)
        .input('discPer', sql.Decimal(18, 2), discPer || 0)
        .input('discAmount', sql.Decimal(18, 2), discAmount || 0)
        .input('locaCode', sql.NVarChar, finalLocaCode)
        .input('batchNo', sql.NVarChar, finalBatchNo)
        .input('serialNo', sql.NVarChar, serialNo || '')
        .input('customer', sql.NVarChar, '....')
        .input('receiptNo', sql.NVarChar, finalReceiptNo)
        .input('kotPrint', sql.Bit, finalKotPrint)
        .query(`
          INSERT INTO inv_suspend (
            id, ProductCode, ProductDescription, UnitPrice, Qty, Amount, SalesMan, [Table], Chair,
            FreeQty, DiscPer, DiscAmount, LocaCode, BatchNo, SerialNo, Customer, ReceiptNo, KotPrint
          ) VALUES (
            @id, @productCode, @productDescription, @unitPrice, @qty, @amount, @salesMan, @table, @chair,
            @freeQty, @discPer, @discAmount, @locaCode, @batchNo, @serialNo, @customer, @receiptNo, @kotPrint
          )
        `);
      
      console.log(`✅ Inserted new row: ID ${id} for table ${table} (Product: ${productCode})`);
    } catch (insertError) {
      // Check if it's a duplicate key error
      if (insertError.number === 2627 || insertError.number === 2601) {
        console.error(`❌ Duplicate ID ${id} for table ${table} - Frontend should provide unique IDs`);
        throw new Error(`Duplicate ID ${id} already exists for table ${table}. Please use a different ID.`);
      }
      throw insertError;
    }
    
    const newId = id;
    console.log(`✅ Created suspend order item with ID: ${newId}`);
    
    // Broadcast the change to connected clients
    broadcastDataChange('suspend_orders', {
      action: 'created',
      id: newId,
      table: table
    });
    
    res.json({ success: true, id: newId });
  } catch (err) {
    console.error('Error creating suspend order:', err);
    console.error('Error details:', err.message);
    res.status(500).json({ error: 'Failed to create suspend order', details: err.message });
  }
});

// Update suspend order
app.put('/api/suspend-orders/:id', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    const { id } = req.params;
    const {
      productCode,
      productDescription,
      unit,
      packSize,
      freeQty,
      costPrice,
      unitPrice,
      wholeSalePrice,
      qty,
      discPer,
      discAmount,
      amount,
      iid,
      locaCode,
      batchNo,
      stockLoca,
      tax,
      rowIdx,
      serialNo,
      warrantyPeriod,
      periodDays,
      expiryDate,
      receiptNo,
      salesMan,
      customer,
      table,
      chair,
      kotPrint
    } = req.body;
    
    await pool.request()
      .input('id', sql.Int, id)
      .input('productCode', sql.NVarChar, productCode)
      .input('productDescription', sql.NVarChar, productDescription)
      .input('unit', sql.NVarChar, unit)
      .input('packSize', sql.Decimal(18, 2), packSize)
      .input('freeQty', sql.Decimal(18, 2), freeQty)
      .input('costPrice', sql.Decimal(18, 2), costPrice)
      .input('unitPrice', sql.Decimal(18, 2), unitPrice)
      .input('wholeSalePrice', sql.Decimal(18, 2), wholeSalePrice)
      .input('qty', sql.Decimal(18, 2), qty)
      .input('discPer', sql.Decimal(18, 2), discPer)
      .input('discAmount', sql.Decimal(18, 2), discAmount)
      .input('amount', sql.Decimal(18, 2), amount)
      .input('iid', sql.NVarChar, iid)
      .input('locaCode', sql.NVarChar, locaCode)
      .input('batchNo', sql.NVarChar, batchNo)
      .input('stockLoca', sql.NVarChar, stockLoca)
      .input('tax', sql.Decimal(18, 2), tax)
      .input('rowIdx', sql.Int, rowIdx)
      .input('serialNo', sql.NVarChar, serialNo)
      .input('warrantyPeriod', sql.Int, warrantyPeriod)
      .input('periodDays', sql.Int, periodDays)
      .input('expiryDate', sql.DateTime, expiryDate)
      .input('receiptNo', sql.NVarChar, receiptNo)
      .input('salesMan', sql.NVarChar, salesMan)
      .input('customer', sql.NVarChar, customer)
      .input('table', sql.NVarChar, table)
      .input('chair', sql.NVarChar, chair)
      .input('kotPrint', sql.Bit, kotPrint)
      .query(`
        UPDATE inv_suspend SET
          ProductCode = @productCode,
          ProductDescription = @productDescription,
          Unit = @unit,
          PackSize = @packSize,
          FreeQty = @freeQty,
          CostPrice = @costPrice,
          UnitPrice = @unitPrice,
          WholeSalePrice = @wholeSalePrice,
          Qty = @qty,
          DiscPer = @discPer,
          DiscAmount = @discAmount,
          Amount = @amount,
          Iid = @iid,
          LocaCode = @locaCode,
          BatchNo = @batchNo,
          StockLoca = @stockLoca,
          Tax = @tax,
          RowIdx = @rowIdx,
          SerialNo = @serialNo,
          WarrantyPeriod = @warrantyPeriod,
          PeriodDays = @periodDays,
          ExpiryDate = @expiryDate,
          ReceiptNo = @receiptNo,
          SalesMan = @salesMan,
          Customer = @customer,
          [Table] = @table,
          Chair = @chair,
          KotPrint = @kotPrint
        WHERE id = @id
      `);
    
    console.log(`✅ Updated suspend order with ID: ${id}`);
    
    // Broadcast the change to connected clients
    broadcastDataChange('suspend_orders', {
      action: 'updated',
      id: id
    });
    
    res.json({ success: true });
  } catch (err) {
    console.error('Error updating suspend order:', err);
    res.status(500).json({ error: 'Failed to update suspend order' });
  }
});

// Delete suspend order
app.delete('/api/suspend-orders/:id', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    const { id } = req.params;
    
    await pool.request()
      .input('id', sql.Int, id)
      .query('DELETE FROM inv_suspend WHERE id = @id');
    
    console.log(`✅ Deleted suspend order with ID: ${id}`);
    
    // Broadcast the change to connected clients
    broadcastDataChange('suspend_orders', {
      action: 'deleted',
      id: id
    });
    
    res.json({ success: true });
  } catch (err) {
    console.error('Error deleting suspend order:', err);
    res.status(500).json({ error: 'Failed to delete suspend order' });
  }
});

// Get receipt number for order (combines unit and ReceiptNo from sysconfig)
app.get('/api/orders/generate-receipt/:tableNumber', async (req, res) => {
  try {
    if (!pool) {
      console.error('❌ Database not connected');
      return res.status(503).json({ 
        success: false,
        error: 'Database not connected' 
      });
    }
    
    const { tableNumber } = req.params;
    console.log(`📋 Generating receipt number for table/room: ${tableNumber}`);
    
    // Get both Unit and ReceiptNo from sysconfig (with NOLOCK to read latest value)
    const sysconfigResult = await pool.request().query(`SELECT Unit, ReceiptNo FROM sysconfig WITH (NOLOCK)`);
    
    if (sysconfigResult.recordset.length === 0) {
      console.error('❌ Sysconfig not found in database');
      return res.status(404).json({ 
        success: false,
        error: 'Sysconfig not found' 
      });
    }
    
    // Get unit from sysconfig and convert to string
    const unitValue = sysconfigResult.recordset[0].Unit;
    const unit = unitValue !== null && unitValue !== undefined ? unitValue.toString() : '1';
    console.log(`📋 Unit from sysconfig: ${unit} (raw value: ${unitValue}, type: ${typeof unitValue})`);
    
    // Get ReceiptNo counter from sysconfig
    const counter = parseInt(sysconfigResult.recordset[0].ReceiptNo) || 1;
    const receiptCounter = counter.toString().padStart(8, '0');
    console.log(`📋 ReceiptNo from sysconfig: ${receiptCounter} (raw value: ${sysconfigResult.recordset[0].ReceiptNo})`);
    
    // Combine unit + receiptCounter (e.g., "1" + "00000001" = "100000001")
    const finalReceiptNo = unit + receiptCounter;
    console.log(`✅ Generated receipt number: ${finalReceiptNo}`);
    
    // Increment sysconfig counter for next order
    const nextCounter = counter + 1;
    await pool.request()
      .input('newReceiptNo', sql.Int, nextCounter)
      .query('UPDATE sysconfig SET ReceiptNo = @newReceiptNo');
    
    console.log(`✅ Incremented sysconfig ReceiptNo from ${counter} to ${nextCounter}`);
    
    res.json({ 
      success: true, 
      receiptNo: finalReceiptNo,
      unit: unit,
      counter: receiptCounter
    });
  } catch (err) {
    console.error('❌ Error generating receipt number:', err);
    console.error('❌ Error details:', err.message);
    res.status(500).json({ 
      success: false,
      error: 'Failed to generate receipt number',
      details: err.message
    });
  }
});

// Confirm order (move from suspend to final order)
app.post('/api/orders/confirm/:tableNumber', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    const { tableNumber } = req.params;
    const { receiptNo, salesMan } = req.body;
    
    // Get all suspend orders for this table
    const suspendOrders = await pool.request()
      .input('tableNumber', sql.NVarChar, tableNumber)
      .query(`
        SELECT * FROM inv_suspend 
        WHERE [Table] = @tableNumber
      `);
    
    if (suspendOrders.recordset.length === 0) {
      return res.status(404).json({ error: 'No pending orders found for this table' });
    }
    
    // Get and increment the order counter
    let orderNumber;
    try {
      // Try to get current counter value
      const counterResult = await pool.request().query(`
        SELECT counter_value FROM order_counter WHERE counter_name = 'daily_orders'
      `);
      
      if (counterResult.recordset.length > 0) {
        // Increment existing counter
        orderNumber = counterResult.recordset[0].counter_value + 1;
        await pool.request()
          .input('newValue', sql.Int, orderNumber)
          .query(`
            UPDATE order_counter 
            SET counter_value = @newValue, last_updated = GETDATE()
            WHERE counter_name = 'daily_orders'
          `);
      } else {
        // Create counter table and initialize
        orderNumber = 1;
        await pool.request().query(`
          IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='order_counter' AND xtype='U')
          CREATE TABLE order_counter (
            counter_name NVARCHAR(50) PRIMARY KEY,
            counter_value INT NOT NULL,
            last_updated DATETIME DEFAULT GETDATE()
          )
        `);
        
        await pool.request()
          .input('counterValue', sql.Int, orderNumber)
          .query(`
            INSERT INTO order_counter (counter_name, counter_value, last_updated)
            VALUES ('daily_orders', @counterValue, GETDATE())
          `);
      }
      
      console.log(`📊 Order counter incremented to: ${orderNumber}`);
    } catch (counterErr) {
      console.error('Error managing order counter:', counterErr);
      // Continue without counter if it fails
      orderNumber = Date.now();
    }
    
    // Check if table already has items with a ReceiptNo (existing unpaid order)
    const existingReceiptCheck = suspendOrders.recordset.find(item => item.ReceiptNo != null && item.ReceiptNo !== '');
    
    // Generate receipt number: both unit and counter from sysconfig
    let finalReceiptNo = receiptNo;
    
    // If a receiptNo already exists in the database for this table, use it (don't increment counter)
    if (!finalReceiptNo && existingReceiptCheck && existingReceiptCheck.ReceiptNo) {
      finalReceiptNo = existingReceiptCheck.ReceiptNo;
      console.log(`♻️ Table ${tableNumber} already has ReceiptNo: ${finalReceiptNo}`);
      console.log(`✅ Reusing existing receipt (NOT incrementing sysconfig.ReceiptNo)`);
    }
    // Only generate NEW receipt number if this is truly a new order
    else if (!finalReceiptNo) {
      try {
        // Get both Unit and ReceiptNo from sysconfig (with NOLOCK to read latest value)
        const sysconfigResult = await pool.request().query(`SELECT Unit, ReceiptNo FROM sysconfig WITH (NOLOCK)`);
        if (sysconfigResult.recordset.length > 0) {
          // Get unit from sysconfig and convert to string
          const unitValue = sysconfigResult.recordset[0].Unit;
          const unit = unitValue !== null && unitValue !== undefined ? unitValue.toString() : '1';
          
          // Get counter from sysconfig
          const counter = parseInt(sysconfigResult.recordset[0].ReceiptNo) || 1;
          const receiptCounter = counter.toString().padStart(8, '0');
          
          // Combine: unit + counter (e.g., "1" + "00000001" = "100000001")
          finalReceiptNo = unit + receiptCounter;
          console.log(`📋 NEW ORDER - Generated receipt number: ${finalReceiptNo} (unit: ${unit}, counter: ${receiptCounter})`);
          console.log(`📊 sysconfig.Unit raw value: ${unitValue} (type: ${typeof unitValue})`);
          console.log(`📊 sysconfig.ReceiptNo raw value: ${sysconfigResult.recordset[0].ReceiptNo}`);
          
          // Increment sysconfig counter for next order (ONLY for new orders)
          const nextCounter = counter + 1;
          await pool.request()
            .input('newReceiptNo', sql.Int, nextCounter)
            .query('UPDATE sysconfig SET ReceiptNo = @newReceiptNo');
          
          console.log(`✅ NEW ORDER - Incremented sysconfig ReceiptNo from ${counter} to ${nextCounter}`);
        } else {
          finalReceiptNo = '100000001';
        }
      } catch (err) {
        console.error('Error generating receipt number:', err);
        finalReceiptNo = `RCP${orderNumber}`;
      }
    } else {
      console.log(`✅ Using provided ReceiptNo: ${finalReceiptNo} (NOT incrementing counter)`);
    }
    
    // Update suspend orders with receipt number and mark as confirmed
    // Note: KotPrint is NOT updated here to preserve manual database changes
    await pool.request()
      .input('tableNumber', sql.NVarChar, tableNumber)
      .input('receiptNo', sql.NVarChar, finalReceiptNo)
      .input('salesMan', sql.NVarChar, salesMan)
      .query(`
        UPDATE inv_suspend 
        SET ReceiptNo = @receiptNo, SalesMan = @salesMan
        WHERE [Table] = @tableNumber
      `);
    
    console.log(`✅ Confirmed order for table ${tableNumber} with receipt ${finalReceiptNo}`);
    console.log(`📈 Order number: ${orderNumber}`);
    
    res.json({ 
      success: true, 
      receiptNo: finalReceiptNo,
      orderNumber: orderNumber,
      orderCount: suspendOrders.recordset.length 
    });
  } catch (err) {
    console.error('Error confirming order:', err);
    res.status(500).json({ error: 'Failed to confirm order' });
  }
});

// Get current order counter
app.get('/api/counter/:counterName', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    const { counterName } = req.params;
    
    const result = await pool.request()
      .input('counterName', sql.NVarChar, counterName)
      .query(`
        SELECT counter_value, last_updated FROM order_counter 
        WHERE counter_name = @counterName
      `);
    
    if (result.recordset.length > 0) {
      res.json({ 
        success: true, 
        counterName: counterName,
        value: result.recordset[0].counter_value,
        lastUpdated: result.recordset[0].last_updated
      });
    } else {
      res.json({ 
        success: true, 
        counterName: counterName,
        value: 0,
        lastUpdated: null
      });
    }
  } catch (err) {
    console.error('Error getting counter:', err);
    res.status(500).json({ error: 'Failed to get counter' });
  }
});

// Reset order counter
app.post('/api/counter/:counterName/reset', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    const { counterName } = req.params;
    const { resetValue = 0 } = req.body;
    
    // Create table if it doesn't exist
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='order_counter' AND xtype='U')
      CREATE TABLE order_counter (
        counter_name NVARCHAR(50) PRIMARY KEY,
        counter_value INT NOT NULL,
        last_updated DATETIME DEFAULT GETDATE()
      )
    `);
    
    // Update or insert counter
    await pool.request()
      .input('counterName', sql.NVarChar, counterName)
      .input('resetValue', sql.Int, resetValue)
      .query(`
        IF EXISTS (SELECT 1 FROM order_counter WHERE counter_name = @counterName)
          UPDATE order_counter 
          SET counter_value = @resetValue, last_updated = GETDATE()
          WHERE counter_name = @counterName
        ELSE
          INSERT INTO order_counter (counter_name, counter_value, last_updated)
          VALUES (@counterName, @resetValue, GETDATE())
      `);
    
    console.log(`🔄 Counter '${counterName}' reset to: ${resetValue}`);
    res.json({ 
      success: true, 
      counterName: counterName,
      newValue: resetValue
    });
  } catch (err) {
    console.error('Error resetting counter:', err);
    res.status(500).json({ error: 'Failed to reset counter' });
  }
});

// Clear suspend orders for a table (cancel order)
app.delete('/api/suspend-orders/table/:tableNumber', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    const { tableNumber } = req.params;
    
    const result = await pool.request()
      .input('tableNumber', sql.NVarChar, tableNumber)
      .query('DELETE FROM inv_suspend WHERE [Table] = @tableNumber');
    
    console.log(`✅ Cleared all suspend orders for table ${tableNumber}`);
    res.json({ success: true, deletedCount: result.rowsAffected[0] });
  } catch (err) {
    console.error('Error clearing suspend orders:', err);
    res.status(500).json({ error: 'Failed to clear suspend orders' });
  }
});

// Create HTTP server
const server = http.createServer(app);

// Initialize WebSocket server
initializeWebSocket(server);

// Start server
server.listen(PORT, '0.0.0.0', () => {
  const os = require('os');
  const nets = os.networkInterfaces();
  let serverIP = 'localhost';
  
  // Find the first non-internal IPv4 address
  Object.keys(nets).forEach(name => {
    nets[name].forEach(net => {
      if (net.family === 'IPv4' && !net.internal) {
        serverIP = net.address;
      }
    });
  });
  
  console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
  console.log(`📊 API endpoints available at http://localhost:${PORT}/api/`);
  console.log(`📊 Network access available at http://${serverIP}:${PORT}/api/`);
  console.log(`🔌 WebSocket server available at ws://${serverIP}:${PORT}/ws`);
});

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('🔄 Shutting down server...');
  if (pool) {
    await pool.close();
    console.log('🔌 Database connection closed');
  }
  process.exit(0);
});
