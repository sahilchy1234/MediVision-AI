require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');

const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const healthRoutes = require('./routes/health.routes');
const aiRoutes = require('./routes/ai.routes');
const recordsRoutes = require('./routes/records.routes');
const vitalsRoutes = require('./routes/vitals.routes');
const timelineRoutes = require('./routes/timeline.routes');
const womensHealthRoutes = require('./routes/womens_health.routes');
const summaryRoutes = require('./routes/summary.routes');
const { notFoundHandler, globalErrorHandler } = require('./middleware/error.middleware');

const app = express();
const PORT = process.env.PORT || 5000;

// Enable CORS for Flutter web, mobile, and desktop
app.use(
  cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept', 'x-groq-api-key', 'ngrok-skip-browser-warning'],
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
app.use('/api/user', userRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/records', recordsRoutes);
app.use('/api/vitals', vitalsRoutes);
app.use('/api/timeline', timelineRoutes);
app.use('/api/womens-health', womensHealthRoutes);
app.use('/api/summary', summaryRoutes);

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
      summary: 'GET /api/summary',
    },
  });
});

// 404 and Error handling
app.use(notFoundHandler);
app.use(globalErrorHandler);

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`🏥 MediVision AI Backend running on port ${PORT}`);
    console.log(`🚀 Health Check: http://localhost:${PORT}/api/health`);
  });
}

module.exports = app;
