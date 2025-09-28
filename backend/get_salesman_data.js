const sql = require('mssql');

const config = {
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
};

async function getSalesmanData() {
  try {
    console.log('🔌 Connecting to Windows SQL Server database...');
    const pool = await sql.connect(config);
    console.log('✅ Connected successfully!');
    
    // Get all salesman data with passwords
    const result = await pool.request().query(`
      SELECT 
        SalesmanCode, 
        SalesmanName, 
        salesman_password,
        SalesmanType,
        Email,
        CASE WHEN BlackListed = 0 OR BlackListed IS NULL THEN 'Active' ELSE 'Blacklisted' END as Status,
        CASE WHEN Suspend = 0 OR Suspend IS NULL THEN 'Not Suspended' ELSE 'Suspended' END as Suspension
      FROM gen_salesman 
      ORDER BY SalesmanCode
    `);
    
    console.log('\n📊 All Salesman Data from your Windows Database:');
    console.log('='.repeat(80));
    console.table(result.recordset);
    
    // Show active salesmen only
    const activeResult = await pool.request().query(`
      SELECT 
        SalesmanCode, 
        SalesmanName, 
        salesman_password,
        SalesmanType
      FROM gen_salesman 
      WHERE (BlackListed = 0 OR BlackListed IS NULL) 
        AND (Suspend = 0 OR Suspend IS NULL)
      ORDER BY SalesmanCode
    `);
    
    console.log('\n✅ Active Salesmen (can login):');
    console.log('='.repeat(50));
    console.table(activeResult.recordset);
    
    console.log('\n🔑 Login Credentials:');
    console.log('='.repeat(30));
    activeResult.recordset.forEach(salesman => {
      console.log(`Code: ${salesman.SalesmanCode} | Password: ${salesman.salesman_password} | Name: ${salesman.SalesmanName}`);
    });
    
    await pool.close();
    console.log('\n🔌 Database connection closed');
  } catch (err) {
    console.error('❌ Error connecting to database:', err.message);
    console.log('\n💡 Troubleshooting tips:');
    console.log('1. Make sure your Windows laptop is running');
    console.log('2. Ensure SQL Server Express is running');
    console.log('3. Check that the database POS_SOLUTION exists');
    console.log('4. Verify the IP address 172.20.10.2 is correct');
  }
}

getSalesmanData();
