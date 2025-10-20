module.exports = {
  // Database Configuration
  server: '172.18.225.26', // External Windows SQL Server machine
  database: 'POS_SOLUTION',
  user: 'sa',
  password: 'jbs2014', // External Windows SQL Server password
  port: 1433,
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};
