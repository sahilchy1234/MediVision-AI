const fs = require('fs');
const path = require('path');

const DATA_DIR = path.join(__dirname, '../../data');
const VITALS_FILE = path.join(DATA_DIR, 'vitals.json');

// Ensure data directory exists
if (!fs.existsSync(DATA_DIR)) {
  fs.mkdirSync(DATA_DIR, { recursive: true });
}

// Initial seed data for demo user
function getDefaultVitals(userId = 'usr_demo_alex_morgan') {
  return {
    userId,
    snapshot: {
      steps: 8420,
      stepGoal: 10000,
      activeMinutes: 42,
      activeCalories: 482,
      restingHeartRate: 61,
      bloodPressureSystolic: 118,
      bloodPressureDiastolic: 78,
      bloodOxygenSpO2: 98,
      bodyTemperature: 36.8,
      sleepDurationMinutes: 462, // 7h 42m
      deepSleepMinutes: 108,      // 1h 48m
      sleepQualityScore: 89,
      screenTimeMinutes: 195,    // 3h 15m
      screenPickups: 48,
      lastUpdated: new Date().toISOString(),
    },
    activities: [
      {
        id: 'act_seed_1',
        type: 'Walking',
        startTime: new Date(Date.now() - 6 * 3600 * 1000).toISOString(),
        durationMinutes: 42,
        steps: 4250,
        calories: 215,
        distanceKm: 3.1,
        avgHeartRate: 102,
        notes: 'Brisk evening walk in the park.',
      },
    ],
    logs: [
      {
        id: 'log_seed_1',
        category: 'pulse',
        label: 'Resting Pulse',
        value: '61',
        unit: 'bpm',
        timestamp: new Date(Date.now() - 3 * 3600 * 1000).toISOString(),
        notes: 'Optimal baseline resting pulse.',
      },
      {
        id: 'log_seed_2',
        category: 'sleep',
        label: 'Night Sleep',
        value: '7h 42m',
        unit: 'hours',
        timestamp: new Date(Date.now() - 10 * 3600 * 1000).toISOString(),
        notes: '1h 48m deep sleep, 89% quality.',
      },
      {
        id: 'log_seed_3',
        category: 'steps',
        label: 'Daily Movement',
        value: '8420',
        unit: 'steps',
        timestamp: new Date(Date.now() - 2 * 3600 * 1000).toISOString(),
        notes: '84% of daily goal reached.',
      },
    ],
    updatedAt: new Date().toISOString(),
  };
}

// Read vitals store
function readVitalsStore() {
  try {
    if (!fs.existsSync(VITALS_FILE)) {
      const initial = { usr_demo_alex_morgan: getDefaultVitals('usr_demo_alex_morgan') };
      fs.writeFileSync(VITALS_FILE, JSON.stringify(initial, null, 2), 'utf-8');
      return initial;
    }
    const raw = fs.readFileSync(VITALS_FILE, 'utf-8');
    return JSON.parse(raw);
  } catch (err) {
    console.error('Error reading vitals store:', err);
    return {};
  }
}

// Write vitals store atomically
function writeVitalsStore(store) {
  try {
    const tempFile = `${VITALS_FILE}.tmp`;
    fs.writeFileSync(tempFile, JSON.stringify(store, null, 2), 'utf-8');
    fs.renameSync(tempFile, VITALS_FILE);
    return true;
  } catch (err) {
    console.error('Error writing vitals store:', err);
    return false;
  }
}

const vitalsController = {
  /**
   * GET /api/vitals
   * Retrieve latest vitals snapshot and recent logs for authenticated user
   */
  async getVitals(req, res, next) {
    try {
      const userId = req.user ? req.user.id : 'usr_demo_alex_morgan';
      const store = readVitalsStore();
      
      let userData = store[userId];
      if (!userData) {
        userData = getDefaultVitals(userId);
        store[userId] = userData;
        writeVitalsStore(store);
      }

      return res.status(200).json({
        success: true,
        data: userData,
      });
    } catch (err) {
      next(err);
    }
  },

  /**
   * POST /api/vitals
   * Update or log new vital signs (pulse, BP, SpO2, temp, sleep, screen time, etc.)
   */
  async updateVitals(req, res, next) {
    try {
      const userId = req.user ? req.user.id : 'usr_demo_alex_morgan';
      const store = readVitalsStore();
      let userData = store[userId] || getDefaultVitals(userId);

      const {
        steps,
        stepGoal,
        activeMinutes,
        activeCalories,
        restingHeartRate,
        bloodPressureSystolic,
        bloodPressureDiastolic,
        bloodOxygenSpO2,
        bodyTemperature,
        sleepDurationMinutes,
        deepSleepMinutes,
        sleepQualityScore,
        screenTimeMinutes,
        screenPickups,
        logEntry,
      } = req.body;

      // Update snapshot fields if provided
      if (steps !== undefined) userData.snapshot.steps = Number(steps);
      if (stepGoal !== undefined) userData.snapshot.stepGoal = Number(stepGoal);
      if (activeMinutes !== undefined) userData.snapshot.activeMinutes = Number(activeMinutes);
      if (activeCalories !== undefined) userData.snapshot.activeCalories = Number(activeCalories);
      if (restingHeartRate !== undefined) userData.snapshot.restingHeartRate = Number(restingHeartRate);
      if (bloodPressureSystolic !== undefined) userData.snapshot.bloodPressureSystolic = Number(bloodPressureSystolic);
      if (bloodPressureDiastolic !== undefined) userData.snapshot.bloodPressureDiastolic = Number(bloodPressureDiastolic);
      if (bloodOxygenSpO2 !== undefined) userData.snapshot.bloodOxygenSpO2 = Number(bloodOxygenSpO2);
      if (bodyTemperature !== undefined) userData.snapshot.bodyTemperature = Number(bodyTemperature);
      if (sleepDurationMinutes !== undefined) userData.snapshot.sleepDurationMinutes = Number(sleepDurationMinutes);
      if (deepSleepMinutes !== undefined) userData.snapshot.deepSleepMinutes = Number(deepSleepMinutes);
      if (sleepQualityScore !== undefined) userData.snapshot.sleepQualityScore = Number(sleepQualityScore);
      if (screenTimeMinutes !== undefined) userData.snapshot.screenTimeMinutes = Number(screenTimeMinutes);
      if (screenPickups !== undefined) userData.snapshot.screenPickups = Number(screenPickups);

      userData.snapshot.lastUpdated = new Date().toISOString();
      userData.updatedAt = new Date().toISOString();

      // If a specific log entry was provided, prepend to logs
      if (logEntry && typeof logEntry === 'object') {
        const newLog = {
          id: `log_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`,
          category: logEntry.category || 'vitals',
          label: logEntry.label || 'Vitals Update',
          value: String(logEntry.value || ''),
          unit: logEntry.unit || '',
          timestamp: logEntry.timestamp || new Date().toISOString(),
          notes: logEntry.notes || '',
        };
        userData.logs.unshift(newLog);
        // Keep up to 100 recent logs
        if (userData.logs.length > 100) {
          userData.logs = userData.logs.slice(0, 100);
        }
      }

      store[userId] = userData;
      writeVitalsStore(store);

      return res.status(200).json({
        success: true,
        message: 'Vitals recorded successfully.',
        data: userData,
      });
    } catch (err) {
      next(err);
    }
  },

  /**
   * POST /api/vitals/activity
   * Log a new completed physical activity / workout session
   */
  async logActivity(req, res, next) {
    try {
      const userId = req.user ? req.user.id : 'usr_demo_alex_morgan';
      const store = readVitalsStore();
      let userData = store[userId] || getDefaultVitals(userId);

      const {
        type = 'Walking',
        durationMinutes = 30,
        steps = 0,
        calories = 0,
        distanceKm = 0,
        avgHeartRate = 0,
        notes = '',
      } = req.body;

      const newActivity = {
        id: `act_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`,
        type,
        startTime: new Date().toISOString(),
        durationMinutes: Number(durationMinutes),
        steps: Number(steps),
        calories: Number(calories),
        distanceKm: Number(distanceKm),
        avgHeartRate: Number(avgHeartRate),
        notes,
      };

      userData.activities.unshift(newActivity);
      if (userData.activities.length > 50) {
        userData.activities = userData.activities.slice(0, 50);
      }

      // Automatically accumulate steps & calories into daily snapshot
      userData.snapshot.steps = (userData.snapshot.steps || 0) + Number(steps);
      userData.snapshot.activeMinutes = (userData.snapshot.activeMinutes || 0) + Number(durationMinutes);
      userData.snapshot.activeCalories = (userData.snapshot.activeCalories || 0) + Number(calories);
      userData.snapshot.lastUpdated = new Date().toISOString();
      userData.updatedAt = new Date().toISOString();

      // Also add a log entry
      userData.logs.unshift({
        id: `log_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`,
        category: 'activity',
        label: `${type} Session`,
        value: `${steps} steps`,
        unit: 'steps',
        timestamp: new Date().toISOString(),
        notes: `${durationMinutes}m duration • ${calories} kcal burned • ${distanceKm} km`,
      });

      store[userId] = userData;
      writeVitalsStore(store);

      return res.status(201).json({
        success: true,
        message: 'Activity session recorded successfully.',
        data: {
          activity: newActivity,
          snapshot: userData.snapshot,
        },
      });
    } catch (err) {
      next(err);
    }
  },

  /**
   * GET /api/vitals/history
   * Retrieve historical activity & vitals logs
   */
  async getHistory(req, res, next) {
    try {
      const userId = req.user ? req.user.id : 'usr_demo_alex_morgan';
      const store = readVitalsStore();
      const userData = store[userId] || getDefaultVitals(userId);

      return res.status(200).json({
        success: true,
        data: {
          activities: userData.activities || [],
          logs: userData.logs || [],
        },
      });
    } catch (err) {
      next(err);
    }
  },
};

module.exports = vitalsController;

