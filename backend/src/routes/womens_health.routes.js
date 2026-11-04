const express = require('express');
const { womensHealthController } = require('../controllers/womens_health.controller');
const db = require('../config/db');
const { verifyAccessToken, sanitizeUser } = require('../utils/token');

const router = express.Router();

async function flexibleAuth(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      const decoded = verifyAccessToken(token);
      if (decoded) {
        const user = await db.findById(decoded.id);
        if (user) {
          req.user = sanitizeUser(user);
          return next();
        }
      }
    }
  } catch (_) {
    // proceed to fallback
  }

  // Fallback demo user
  req.user = {
    id: 'usr_demo_alex_morgan',
    fullName: 'Alex Morgan',
    email: 'alex.morgan@medivision.health',
    gender: 'Female',
    dateOfBirth: '1995-04-12',
    heightCm: 168.0,
    weightKg: 58.0,
    medicalConditions: ['Asthma (Mild intermittent)', 'Mild Dysmenorrhea'],
  };
  next();
}

router.use(flexibleAuth);

router.get('/', womensHealthController.getWomensHealth);
router.post('/cycle', womensHealthController.updateCycle);
router.post('/symptoms', womensHealthController.logSymptoms);
router.post('/screenings/analyze', womensHealthController.analyzeScreeningPatterns);
router.post('/vault/toggle', womensHealthController.toggleVaultLock);

module.exports = router;

