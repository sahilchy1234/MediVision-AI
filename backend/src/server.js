require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');

const authRoutes = require('./routes/auth.routes');
const healthRoutes = require('./routes/health.routes');
const { notFoundHandler, globalErrorHandler } = require('./middleware/error.middleware');

const app = express();
const PORT = process.env.PORT || 5000;

// Enable CORS for Flutter web, mobile, and desktop
app.use(
  cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  })
);

// Body parsers
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging in development
if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('dev'));
}

// API Routes
app.use('/api', healthRoutes);
app.use('/api/auth', authRoutes);

// Welcome Root Route
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to MediVision AI Clinical API Backend',
    documentation: '/api/health',
    endpoints: {
      health: 'GET /api/health',
      register: 'POST /api/auth/register',
      login: 'POST /api/auth/login',
      logout: 'POST /api/auth/logout',
      currentUser: 'GET /api/auth/me (Protected)',
      refreshToken: 'POST /api/auth/refresh',
    },
  });
});

// 404 Handler
app.use(notFoundHandler);

// Centralized Error Handler
app.use(globalErrorHandler);

// Start HTTP Server
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`===============================================`);
    console.log(`🚀 MediVision AI Backend is actively running!`);
    console.log(`📍 Port: http://localhost:${PORT}`);
    console.log(`🩺 Health check: http://localhost:${PORT}/api/health`);
    console.log(`🔐 Auth endpoints: http://localhost:${PORT}/api/auth`);
    console.log(`===============================================`);
  });
}

module.exports = app;
