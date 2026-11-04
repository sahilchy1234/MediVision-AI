const fs = require('fs');
const path = require('path');
const bcrypt = require('bcryptjs');

const DATA_DIR = path.join(__dirname, '../../data');
const USERS_FILE = path.join(DATA_DIR, 'users.json');

// Ensure data directory exists
if (!fs.existsSync(DATA_DIR)) {
  fs.mkdirSync(DATA_DIR, { recursive: true });
}

// Initialize seed user if not present
function initDb() {
  if (!fs.existsSync(USERS_FILE)) {
    const salt = bcrypt.genSaltSync(10);
    const demoPasswordHash = bcrypt.hashSync('Password123!', salt);

    const initialUsers = [
      {
        id: 'usr_demo_alex_morgan',
        fullName: 'Alex Morgan',
        email: 'alex.morgan@medivision.health',
        passwordHash: demoPasswordHash,
        gender: 'female',
        dateOfBirth: '1995-04-12',
        role: 'patient',
        allergies: ['Penicillin', 'Dust Mites'],
        existingConditions: ['Asthma (Mild intermittent)'],
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        lastLoginAt: new Date().toISOString(),
      },
    ];

    fs.writeFileSync(USERS_FILE, JSON.stringify(initialUsers, null, 2), 'utf-8');
    console.log('📦 Database initialized with seed demo account (alex.morgan@medivision.health)');
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
      fullName: userData.fullName.trim(),
      email: userData.email.trim().toLowerCase(),
      passwordHash: userData.passwordHash,
      gender: userData.gender || 'unspecified',
      dateOfBirth: userData.dateOfBirth || null,
      role: userData.role || 'patient',
      allergies: userData.allergies || [],
      existingConditions: userData.existingConditions || [],
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
