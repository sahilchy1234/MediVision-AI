const bcrypt = require('bcryptjs');
const db = require('../config/db');
const {
  generateAccessToken,
  generateRefreshToken,
  verifyRefreshToken,
  sanitizeUser,
} = require('../utils/token');

// Email regex validator
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const authController = {
  /**
   * POST /api/auth/register
   * Create a new patient or user account
   */
  async register(req, res, next) {
    try {
      const { fullName, email, password, gender, dateOfBirth } = req.body;

      // Basic Validation
      if (!fullName || typeof fullName !== 'string' || fullName.trim().length < 2) {
        return res.status(400).json({
          success: false,
          message: 'Full name is required and must be at least 2 characters.',
        });
      }

      if (!email || !EMAIL_REGEX.test(email.trim())) {
        return res.status(400).json({
          success: false,
          message: 'A valid email address is required.',
        });
      }

      if (!password || typeof password !== 'string' || password.length < 6) {
        return res.status(400).json({
          success: false,
          message: 'Password must be at least 6 characters in length.',
        });
      }

      // Check duplicate
      const existingUser = await db.findByEmail(email);
      if (existingUser) {
        return res.status(409).json({
          success: false,
          message: 'An account with this email address is already registered.',
        });
      }

      // Hash password
      const salt = await bcrypt.genSalt(10);
      const passwordHash = await bcrypt.hash(password, salt);

      // Create user
      const newUser = await db.createUser({
        fullName: fullName.trim(),
        email: email.trim(),
        passwordHash,
        gender: gender || 'unspecified',
        dateOfBirth: dateOfBirth || null,
        role: 'patient',
      });

      // Generate tokens
      const accessToken = generateAccessToken(newUser);
      const refreshToken = generateRefreshToken(newUser);

      return res.status(201).json({
        success: true,
        message: 'Account created successfully. Welcome to MediVision AI!',
        data: {
          user: sanitizeUser(newUser),
          tokens: {
            accessToken,
            refreshToken,
            tokenType: 'Bearer',
          },
        },
      });
    } catch (err) {
      next(err);
    }
  },

  /**
   * POST /api/auth/login
   * Authenticate user credentials and issue JWT
   */
  async login(req, res, next) {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({
          success: false,
          message: 'Email and password are required fields.',
        });
      }

      const user = await db.findByEmail(email);
      if (!user) {
        return res.status(401).json({
          success: false,
          message: 'Invalid email or password credentials.',
        });
      }

      const isMatch = await bcrypt.compare(password, user.passwordHash);
      if (!isMatch) {
        return res.status(401).json({
          success: false,
          message: 'Invalid email or password credentials.',
        });
      }

      // Update last login
      await db.updateUser(user.id, { lastLoginAt: new Date().toISOString() });

      // Generate tokens
      const accessToken = generateAccessToken(user);
      const refreshToken = generateRefreshToken(user);

      return res.status(200).json({
        success: true,
        message: 'Authentication successful.',
        data: {
          user: sanitizeUser(user),
          tokens: {
            accessToken,
            refreshToken,
            tokenType: 'Bearer',
          },
        },
      });
    } catch (err) {
      next(err);
    }
  },

  /**
   * POST /api/auth/logout
   * Client-side token clearance acknowledgement
   */
  async logout(req, res, next) {
    try {
      // In JWT architectures, token clearance is handled client-side by removing the Bearer token
      // An optional token blacklist can also be maintained here if required
      return res.status(200).json({
        success: true,
        message: 'User logged out successfully. Tokens invalidated on client.',
      });
    } catch (err) {
      next(err);
    }
  },

  /**
   * GET /api/auth/me
   * Retrieve current authenticated user profile
   */
  async getMe(req, res, next) {
    try {
      // req.user is set by requireAuth middleware
      return res.status(200).json({
        success: true,
        data: {
          user: req.user,
        },
      });
    } catch (err) {
      next(err);
    }
  },

  /**
   * POST /api/auth/refresh
   * Issue a new access token using a valid refresh token
   */
  async refresh(req, res, next) {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        return res.status(400).json({
          success: false,
          message: 'Refresh token is required.',
        });
      }

      const decoded = verifyRefreshToken(refreshToken);
      if (!decoded) {
        return res.status(401).json({
          success: false,
          message: 'Invalid or expired refresh token. Please sign in again.',
        });
      }

      const user = await db.findById(decoded.id);
      if (!user) {
        return res.status(401).json({
          success: false,
          message: 'User account not found.',
        });
      }

      const newAccessToken = generateAccessToken(user);

      return res.status(200).json({
        success: true,
        data: {
          accessToken: newAccessToken,
          tokenType: 'Bearer',
        },
      });
    } catch (err) {
      next(err);
    }
  },
};

module.exports = authController;

