const sql = require('mssql');

// Try different connection configurations
const configs = [
  {
    server: '172.20.10.2',
    database: 'POS_SOLUTION',
    user: 'sa',
    password: 'jbs2014',
    port: 1433,
    options: {
      encrypt: false,
      trustServerCertificate: true,
      instanceName: 'SQLEXPRESS'
    }
  },
  {
    server: '172.20.10.2\\SQLEXPRESS',
    database: 'POS_SOLUTION',
    user: 'sa',
    password: 'jbs2014',
    port: 1433,
    options: {
      encrypt: false,
      trustServerCertificate: true
    }
  }
];

async function testConnections() {
  for (let i = 0; i < configs.length; i++) {
    const config = configs[i];
    console.log(`\n🔌 Testing configuration ${i + 1}:`);
    console.log(`Server: ${config.server}`);
    
    try {
      const pool = await sql.connect(config);
      console.log('✅ Connected successfully!');
      
      // Get salesman data
      const result = await pool.request().query(`
        SELECT TOP 5 SalesmanCode, SalesmanName, salesman_password, SalesmanType
        FROM gen_salesman 
        WHERE (BlackListed = 0 OR BlackListed IS NULL) 
          AND (Suspend = 0 OR Suspend IS NULL)
        ORDER BY SalesmanCode
      `);
      
      console.log('\n📊 Salesman Data:');
      console.table(result.recordset);
      
      console.log('\n🔑 Login Credentials:');
      result.recordset.forEach(salesman => {
        console.log(`Code: ${salesman.SalesmanCode} | Password: ${salesman.salesman_password} | Name: ${salesman.SalesmanName}`);
      });
      
      await pool.close();
      console.log('🔌 Connection closed');
      break; // Exit on success
    } catch (err) {
      console.error(`❌ Configuration ${i + 1} failed:`, err.message);
    }
  }
}

testConnections();
