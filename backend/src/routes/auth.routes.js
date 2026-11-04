const express = require('express');
const authController = require('../controllers/auth.controller');
const { requireAuth } = require('../middleware/auth.middleware');

const router = express.Router();

/**
 * Public Authentication Routes
 */
router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/logout', authController.logout);
router.post('/refresh', authController.refresh);

/**
 * Protected Authentication Routes (Require Valid JWT)
 */
router.get('/me', requireAuth, authController.getMe);

module.exports = router;

