# POS Solution API Backend

This is a simple REST API backend that connects to your SQL Server database and provides endpoints for the Flutter app.

## 🚀 Quick Setup

### 1. Install Node.js
Download and install Node.js from [nodejs.org](https://nodejs.org/)

### 2. Install Dependencies
```bash
cd backend
npm install
```

### 3. Start the Server
```bash
npm start
```

The server will start on `http://localhost:3000`

## 📊 API Endpoints

- `GET /api/health` - Health check
- `GET /api/departments` - Get all departments
- `GET /api/subdepartments/:departmentCode` - Get sub-departments
- `GET /api/products` - Get all products
- `GET /api/products/department/:departmentCode` - Get products by department
- `GET /api/products/subdepartment/:subDepartmentCode` - Get products by sub-department
- `GET /api/products/search?q=query` - Search products
- `POST /api/auth/login` - Authenticate salesman
- `GET /api/salesmen` - Get all salesmen

## 🔧 Configuration

Edit `config.js` to update database connection details:

```javascript
module.exports = {
  server: '172.20.10.2\\SQLEXPRESS',
  database: 'POS_SOLUTION',
  user: 'sa',
  password: 'jbs2014',
  port: 1433,
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};
```

## 🍎 iOS Support

This API approach enables full iOS support for your Flutter app since it uses HTTP requests instead of direct database connections.

## 🔍 Testing

Test the API with curl:

```bash
# Health check
curl http://localhost:3000/api/health

# Get departments
curl http://localhost:3000/api/departments

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"salesmanCode":"001","password":"test123"}'
```
