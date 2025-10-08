module.exports = {
  // Database Configuration
  server: 'POS1', // External Windows SQL Server machine
  database: 'POS_SOLUTION',
  user: 'sa',
  password: 'jbs2014', // External Windows SQL Server password
  port: 1433,
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};