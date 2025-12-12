# Backend Deployment Instructions

## 1. Prerequisites
- **Node.js**: Ensure Node.js (v14+) is installed on your server.
- **MongoDB**: Ensure you have a MongoDB connection string (local or Atlas).
- **Process Manager**: We recommend `pm2` for running in production.
  - Install: `npm install -g pm2`

## 2. Installation
1.  Navigate to this folder.
2.  Install dependencies:
    ```bash
    npm install --production
    ```

## 3. Configuration
1.  Open `.env` file.
2.  Update `MONGO_URI` with your production database URL.
3.  Update `JWT_SECRET` with a strong random string.

## 4. Running the Server

### Using PM2 (Recommended)
```bash
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

### Using Node directly
```bash
npm start
```

Your backend will start on **Port 5000**.
