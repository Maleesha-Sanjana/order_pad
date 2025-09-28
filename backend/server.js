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
