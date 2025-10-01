module.exports = {
  // Database Configuration
  server: 'localhost', // Changed to localhost for local Mac setup
  database: 'POS_SOLUTION',
  user: 'sa',
  password: 'Jbs@2014!', // Updated with new password
  port: 1433,
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};
