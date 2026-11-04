const db = require('../config/db');
const { verifyAccessToken, sanitizeUser } = require('../utils/token');

async function requireAuth(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Authentication token missing or invalid format (Bearer token required)',
      });
    }

    const token = authHeader.split(' ')[1];
    const decoded = verifyAccessToken(token);

    if (!decoded) {
      return res.status(401).json({
        success: false,
        message: 'Invalid, tampered, or expired authentication token',
      });
    }

    const user = await db.findById(decoded.id);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'The user account associated with this token no longer exists',
      });
    }

    // Attach sanitized user to request
    req.user = sanitizeUser(user);
    next();
  } catch (err) {
    console.error('Auth middleware error:', err);
    return res.status(500).json({
      success: false,
      message: 'Internal server authentication error',
    });
  }
}

module.exports = {
  requireAuth,
};
