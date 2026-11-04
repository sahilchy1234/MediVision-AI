const db = require('../config/db');
const { sanitizeUser } = require('../utils/token');

const userController = {
  /**
   * GET /api/user/profile
   * Return authenticated user profile from database
   */
  async getProfile(req, res, next) {
    try {
      const user = await db.findById(req.user.id);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User profile not found.',
        });
      }

      return res.status(200).json({
        success: true,
        data: {
          user: sanitizeUser(user),
        },
      });
    } catch (err) {
      next(err);
    }
  },

  /**
   * PUT /api/user/profile
   * Update authenticated user profile fields
   */
  async updateProfile(req, res, next) {
    try {
      const {
        fullName,
        dateOfBirth,
        gender,
        heightCm,
        weightKg,
        allergies,
        medicalConditions,
        enableWomensHealth,
      } = req.body;

      const updates = {};

      if (fullName !== undefined) {
        updates.fullName = String(fullName).trim();
      }
      if (dateOfBirth !== undefined) {
        updates.dateOfBirth = dateOfBirth;
      }
      if (gender !== undefined) {
        updates.gender = String(gender).trim();
      }
      if (heightCm !== undefined) {
        updates.heightCm = Number(heightCm);
      }
      if (weightKg !== undefined) {
        updates.weightKg = Number(weightKg);
      }
      if (allergies !== undefined && Array.isArray(allergies)) {
        updates.allergies = allergies;
      }
      if (medicalConditions !== undefined && Array.isArray(medicalConditions)) {
        updates.medicalConditions = medicalConditions;
      }
      if (enableWomensHealth !== undefined) {
        updates.enableWomensHealth = Boolean(enableWomensHealth);
      }

      const updatedUser = await db.updateUser(req.user.id, updates);
      if (!updatedUser) {
        return res.status(404).json({
          success: false,
          message: 'User profile not found.',
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Clinical profile updated successfully.',
        data: {
          user: sanitizeUser(updatedUser),
        },
      });
    } catch (err) {
      next(err);
    }
  },

  /**
   * GET /api/user/permissions
   * Return authenticated user's permissions & connected data sources
   */
  async getPermissions(req, res, next) {
    try {
      const user = await db.findById(req.user.id);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User profile not found.',
        });
      }

      return res.status(200).json({
        success: true,
        data: {
          permissions: user.permissions || {
            sleep_health: false,
            physical_activity: false,
            screen_time: false,
            device_sensors: false,
            medical_documents: false,
            notifications: false,
          },
        },
      });
    } catch (err) {
      next(err);
    }
  },

  /**
   * PUT /api/user/permissions
   * Update authenticated user's permissions & connected data sources
   */
  async updatePermissions(req, res, next) {
    try {
      const { permissions } = req.body;
      if (!permissions || typeof permissions !== 'object') {
        return res.status(400).json({
          success: false,
          message: 'Permissions payload must be a valid key-value object.',
        });
      }

      const user = await db.findById(req.user.id);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User profile not found.',
        });
      }

      const current = user.permissions || {};
      const merged = { ...current, ...permissions };

      const updated = await db.updateUser(req.user.id, { permissions: merged });

      return res.status(200).json({
        success: true,
        message: 'Data sources & permissions updated in database.',
        data: {
          permissions: updated.permissions,
        },
      });
    } catch (err) {
      next(err);
    }
  },
};

module.exports = userController;

