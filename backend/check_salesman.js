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

async function checkSalesman() {
  try {
    console.log('🔌 Connecting to database...');
    const pool = await sql.connect(config);
    console.log('✅ Connected!');
    
    // Get salesman data
    const result = await pool.request().query(`
      SELECT SalesmanCode, SalesmanName, salesman_password, SalesmanType, Email
      FROM gen_salesman 
      WHERE (BlackListed = 0 OR BlackListed IS NULL) 
        AND (Suspend = 0 OR Suspend IS NULL)
      ORDER BY SalesmanCode
    `);
    
    console.log('\n📊 Active Salesmen:');
    console.table(result.recordset);
    
    await pool.close();
  } catch (err) {
    console.error('❌ Error:', err.message);
  }
}

checkSalesman();
