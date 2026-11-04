const fs = require('fs');
const path = require('path');
const bcrypt = require('bcryptjs');

const DATA_DIR = path.join(__dirname, '../../data');
const USERS_FILE = path.join(DATA_DIR, 'users.json');

// Ensure data directory exists
if (!fs.existsSync(DATA_DIR)) {
  fs.mkdirSync(DATA_DIR, { recursive: true });
}

// Initialize seed user if not present or missing fields
function initDb() {
  const salt = bcrypt.genSaltSync(10);
  const demoPasswordHash = bcrypt.hashSync('Password123!', salt);

  const demoUser = {
    id: 'usr_demo_alex_morgan',
    fullName: 'Alex Morgan',
    email: 'alex.morgan@medivision.health',
    passwordHash: demoPasswordHash,
    gender: 'Female',
    dateOfBirth: '1995-04-12',
    heightCm: 168.0,
    weightKg: 58.0,
    role: 'patient',
    allergies: ['Penicillin', 'Dust Mites'],
    medicalConditions: ['Asthma (Mild intermittent)', 'Mild Dysmenorrhea'],
    enableWomensHealth: true,
    permissions: {
      sleep_health: true,
      physical_activity: true,
      screen_time: true,
      device_sensors: true,
      medical_documents: true,
      notifications: true,
    },
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    lastLoginAt: new Date().toISOString(),
  };

  if (!fs.existsSync(USERS_FILE)) {
    fs.writeFileSync(USERS_FILE, JSON.stringify([demoUser], null, 2), 'utf-8');
    console.log('📦 Database initialized with seed demo account (alex.morgan@medivision.health)');
  } else {
    // If exists, ensure demo user is present
    try {
      const users = JSON.parse(fs.readFileSync(USERS_FILE, 'utf-8'));
      const hasDemo = users.some((u) => u.email.toLowerCase() === 'alex.morgan@medivision.health');
      if (!hasDemo) {
        users.unshift(demoUser);
        fs.writeFileSync(USERS_FILE, JSON.stringify(users, null, 2), 'utf-8');
      }
    } catch (_) {
      fs.writeFileSync(USERS_FILE, JSON.stringify([demoUser], null, 2), 'utf-8');
    }
  }
}

// Read all users
function readUsers() {
  try {
    if (!fs.existsSync(USERS_FILE)) {
      initDb();
    }
    const raw = fs.readFileSync(USERS_FILE, 'utf-8');
    return JSON.parse(raw);
  } catch (err) {
    console.error('Error reading users database:', err);
    return [];
  }
}

// Write users atomically
function writeUsers(users) {
  try {
    const tempFile = `${USERS_FILE}.tmp`;
    fs.writeFileSync(tempFile, JSON.stringify(users, null, 2), 'utf-8');
    fs.renameSync(tempFile, USERS_FILE);
    return true;
  } catch (err) {
    console.error('Error writing users database:', err);
    throw new Error('Database write operation failed');
  }
}

// Database Operations
const db = {
  initDb,

  async findByEmail(email) {
    const normalized = (email || '').trim().toLowerCase();
    const users = readUsers();
    return users.find((u) => u.email.toLowerCase() === normalized) || null;
  },

  async findById(id) {
    const users = readUsers();
    return users.find((u) => u.id === id) || null;
  },

  async createUser(userData) {
    const users = readUsers();
    const id = `usr_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    const now = new Date().toISOString();

    const newUser = {
      id,
      fullName: (userData.fullName || 'Health Member').trim(),
      email: userData.email.trim().toLowerCase(),
      passwordHash: userData.passwordHash,
      gender: userData.gender || 'Female',
      dateOfBirth: userData.dateOfBirth || null,
      heightCm: userData.heightCm != null ? Number(userData.heightCm) : 168.0,
      weightKg: userData.weightKg != null ? Number(userData.weightKg) : 58.0,
      role: userData.role || 'patient',
      allergies: Array.isArray(userData.allergies) ? userData.allergies : [],
      medicalConditions: Array.isArray(userData.medicalConditions)
        ? userData.medicalConditions
        : [],
      enableWomensHealth:
        userData.enableWomensHealth !== undefined ? Boolean(userData.enableWomensHealth) : true,
      permissions: {
        sleep_health: true,
        physical_activity: true,
        screen_time: true,
        device_sensors: true,
        medical_documents: true,
        notifications: true,
        ...(userData.permissions || {}),
      },
      createdAt: now,
      updatedAt: now,
      lastLoginAt: now,
    };

    users.push(newUser);
    writeUsers(users);
    return newUser;
  },

  async updateUser(id, updates) {
    const users = readUsers();
    const index = users.findIndex((u) => u.id === id);
    if (index === -1) return null;

    users[index] = {
      ...users[index],
      ...updates,
      updatedAt: new Date().toISOString(),
    };

    writeUsers(users);
    return users[index];
  },
};

// Auto-run init on load
initDb();

module.exports = db;
