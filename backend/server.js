const express = require('express');
const cors = require('cors');
const sql = require('mssql');
const config = require('./config');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Database connection pool
let pool;

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
        console.log('⚠️  Server will continue running without database connection');
        console.log('⚠️  API endpoints will return mock data for testing');
        pool = null; // Set pool to null to indicate no database connection
      }
    }
  }
}

// Initialize database on startup
initializeDatabase();

// ==================== API ROUTES ====================

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'POS Solution API is running' });
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
    
    // Try to connect to database if not already connected
    if (!pool) {
      try {
        console.log('🔌 Attempting to reconnect to database...');
        pool = await sql.connect(config);
        console.log('✅ Database reconnected successfully');
      } catch (err) {
        console.error('❌ Database reconnection failed:', err.message);
        
        // Fallback to mock authentication for testing
        console.log('🔄 Using fallback authentication for testing...');
        return handleMockAuthentication(salesmanCode, password, res);
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
    // Fallback to mock authentication on error
    console.log('🔄 Using fallback authentication due to error...');
    return handleMockAuthentication(req.body.salesmanCode, req.body.password, res);
  }
});

// Password-only authentication endpoint
app.post('/api/auth/login-password', async (req, res) => {
  try {
    const { password } = req.body;
    
    if (!password) {
      return res.status(400).json({ success: false, message: 'Password is required' });
    }
    
    // Try to connect to database if not already connected
    if (!pool) {
      try {
        console.log('🔌 Attempting to reconnect to database...');
        pool = await sql.connect(config);
        console.log('✅ Database reconnected successfully');
      } catch (err) {
        console.error('❌ Database reconnection failed:', err.message);
        
        // Fallback to mock authentication for testing
        console.log('🔄 Using fallback authentication for testing...');
        return handleMockPasswordAuthentication(password, res);
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
    // Fallback to mock authentication on error
    console.log('🔄 Using fallback authentication due to error...');
    return handleMockPasswordAuthentication(req.body.password, res);
  }
});

// Mock authentication fallback function
function handleMockAuthentication(salesmanCode, password, res) {
  console.log(`🔐 Mock authentication attempt for salesman: ${salesmanCode}`);
  
  // Mock valid credentials for testing - you can add your real credentials here
  const mockSalesmen = {
    'S001': { password: 'tenhg', name: 'tenhg', role: 'Waiter' },
    'S002': { password: 'password123', name: 'Jane Smith', role: 'Manager' },
    '585249': { password: 'password123', name: 'Test User', role: 'Waiter' }
  };
  
  const salesman = mockSalesmen[salesmanCode];
  if (salesman && salesman.password === password) {
    console.log(`✅ Mock authentication successful for: ${salesman.name}`);
    res.json({ 
      success: true, 
      salesman: {
        SalesmanCode: salesmanCode,
        SalesmanName: salesman.name,
        SalesmanType: salesman.role,
        Email: `${salesmanCode.toLowerCase()}@example.com`
      }
    });
  } else {
    console.log(`❌ Mock authentication failed for: ${salesmanCode}`);
    res.status(401).json({ success: false, message: 'Invalid credentials' });
  }
}

// Mock password authentication fallback function
function handleMockPasswordAuthentication(password, res) {
  console.log(`🔐 Mock password authentication attempt for password: ${password}`);
  
  // Mock valid passwords for testing - you can add your real passwords here
  const mockPasswords = {
    'test123': { salesmanCode: 'S001', name: 'tenhg', role: 'Waiter', location: 'Main Branch', companyCode: 'COMP001' },
    'maleesha123': { salesmanCode: 'S002', name: 'Maleesha', role: 'Manager', location: 'Head Office', companyCode: 'COMP001' },
    'password123': { salesmanCode: 'S003', name: 'Test User', role: 'Waiter', location: 'Downtown Branch', companyCode: 'COMP001' }
  };
  
  const salesman = mockPasswords[password];
  if (salesman) {
    console.log(`✅ Mock password authentication successful for: ${salesman.name}`);
    res.json({
      success: true,
      salesman: {
        SalesmanCode: salesman.salesmanCode,
        SalesmanName: salesman.name,
        SalesmanType: salesman.role,
        Email: `${salesman.salesmanCode.toLowerCase()}@example.com`,
        LocationDescription: salesman.location,
        CompanyCode: salesman.companyCode
      }
    });
  } else {
    console.log(`❌ Mock password authentication failed for password: ${password}`);
    res.status(401).json({ success: false, message: 'Invalid password' });
  }
}

// Get all tables
app.get('/api/tables', async (req, res) => {
  try {
    if (!pool) {
      return res.status(503).json({ error: 'Database not connected' });
    }
    
    const result = await pool.request().query(`
      SELECT idx, TableCode, TableName, Location 
      FROM inv_tables 
      ORDER BY TableCode
    `);
    
    console.log(`✅ Loaded ${result.recordset.length} tables from inv_tables`);
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching tables:', err);
    res.status(500).json({ error: 'Failed to fetch tables' });
  }
});

// Get chairs (5 chairs per table with ch1, ch2... naming)
app.get('/api/chairs', async (req, res) => {
  try {
    // All tables have only 5 chairs with ch1, ch2, ch3, ch4, ch5 naming
    const chairs = [
      { chairCode: 'ch1', chairName: 'ch1' },
      { chairCode: 'ch2', chairName: 'ch2' },
      { chairCode: 'ch3', chairName: 'ch3' },
      { chairCode: 'ch4', chairName: 'ch4' },
      { chairCode: 'ch5', chairName: 'ch5' }
    ];
    
    console.log(`✅ Loaded ${chairs.length} chair options (ch1-ch5)`);
    res.json(chairs);
  } catch (err) {
    console.error('Error fetching chairs:', err);
    res.status(500).json({ error: 'Failed to fetch chairs' });
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
    
    // Extract fields from request body, excluding 'id' since it's auto-generated
    const {
      id, // Exclude this field - it's auto-generated by the database
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
      table
    });
    
    // Create a SQL query with required fields
    const result = await pool.request()
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
      .input('locaCode', sql.NVarChar, locaCode || '01')
      .input('serialNo', sql.NVarChar, serialNo || '')
      .input('customer', sql.NVarChar, customer || null)
      .query(`
        INSERT INTO inv_suspend (
          ProductCode, ProductDescription, UnitPrice, Qty, Amount, SalesMan, [Table], Chair,
          FreeQty, DiscPer, DiscAmount, LocaCode, SerialNo, Customer
        ) VALUES (
          @productCode, @productDescription, @unitPrice, @qty, @amount, @salesMan, @table, @chair,
          @freeQty, @discPer, @discAmount, @locaCode, @serialNo, @customer
        );
        SELECT SCOPE_IDENTITY() as id;
      `);
    
    const newId = result.recordset[0].id;
    console.log(`✅ Created suspend order item with ID: ${newId}`);
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
    res.json({ success: true });
  } catch (err) {
    console.error('Error deleting suspend order:', err);
    res.status(500).json({ error: 'Failed to delete suspend order' });
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
    
    // Generate receipt number with incremented counter
    const finalReceiptNo = receiptNo || `RCP${orderNumber.toString().padStart(6, '0')}`;
    
    // Update suspend orders with receipt number and mark as confirmed
    await pool.request()
      .input('tableNumber', sql.NVarChar, tableNumber)
      .input('receiptNo', sql.NVarChar, finalReceiptNo)
      .input('salesMan', sql.NVarChar, salesMan)
      .query(`
        UPDATE inv_suspend 
        SET ReceiptNo = @receiptNo, SalesMan = @salesMan, KotPrint = 1
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

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📊 API endpoints available at http://localhost:${PORT}/api/`);
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
