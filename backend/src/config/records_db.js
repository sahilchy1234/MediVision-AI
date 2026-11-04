const fs = require('fs');
const path = require('path');

const DATA_DIR = path.join(__dirname, '../../data');
const RECORDS_FILE = path.join(DATA_DIR, 'records.json');

if (!fs.existsSync(DATA_DIR)) {
  fs.mkdirSync(DATA_DIR, { recursive: true });
}

function initRecordsDb() {
  if (!fs.existsSync(RECORDS_FILE)) {
    fs.writeFileSync(RECORDS_FILE, JSON.stringify([], null, 2), 'utf-8');
    console.log('📦 Records database initialized (Clean user records)');
  } else {
    // Clean out any legacy mock dummy seed records (rec_1 to rec_5)
    try {
      const records = JSON.parse(fs.readFileSync(RECORDS_FILE, 'utf-8'));
      const dummyIds = new Set(['rec_1', 'rec_2', 'rec_3', 'rec_4', 'rec_5']);
      const cleanRecords = records.filter((r) => !dummyIds.has(r.id));
      if (cleanRecords.length !== records.length) {
        fs.writeFileSync(RECORDS_FILE, JSON.stringify(cleanRecords, null, 2), 'utf-8');
        console.log('🧹 Purged dummy sample records from database');
      }
    } catch (_) {}
  }
}

function readRecords() {
  try {
    if (!fs.existsSync(RECORDS_FILE)) {
      initRecordsDb();
    }
    const raw = fs.readFileSync(RECORDS_FILE, 'utf-8');
    const all = JSON.parse(raw);
    const dummyIds = new Set(['rec_1', 'rec_2', 'rec_3', 'rec_4', 'rec_5']);
    return all.filter((r) => !dummyIds.has(r.id));
  } catch (err) {
    console.error('Error reading records database:', err);
    return [];
  }
}

function writeRecords(records) {
  try {
    const tempFile = `${RECORDS_FILE}.tmp`;
    fs.writeFileSync(tempFile, JSON.stringify(records, null, 2), 'utf-8');
    fs.renameSync(tempFile, RECORDS_FILE);
    return true;
  } catch (err) {
    console.error('Error writing records database:', err);
    throw new Error('Database write operation failed');
  }
}

const recordsDb = {
  initRecordsDb,

  async findByUserId(userId, filters = {}) {
    const all = readRecords();
    let userRecords = all.filter(
      (r) => !userId || r.userId === userId || r.userId === 'usr_demo_alex_morgan'
    );

    if (filters.category && filters.category !== 'all') {
      userRecords = userRecords.filter((r) => r.category === filters.category);
    }

    if (filters.search) {
      const q = filters.search.toLowerCase();
      userRecords = userRecords.filter(
        (r) =>
          r.title?.toLowerCase().includes(q) ||
          r.providerName?.toLowerCase().includes(q) ||
          r.summary?.toLowerCase().includes(q)
      );
    }

    // Sort descending by date
    return userRecords.sort((a, b) => new Date(b.date) - new Date(a.date));
  },

  async findById(id) {
    const all = readRecords();
    return all.find((r) => r.id === id) || null;
  },

  async createRecord(recordData) {
    const all = readRecords();
    const id = recordData.id || `rec_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`;
    const now = new Date().toISOString();

    const newRecord = {
      id,
      userId: recordData.userId || 'usr_demo_alex_morgan',
      title: recordData.title || 'Untitled Medical Record',
      category: recordData.category || 'other',
      date: recordData.date || now,
      providerName: recordData.providerName || 'Healthcare Provider',
      fileSize: recordData.fileSize || '1.0 MB',
      status: recordData.status || 'Uploaded',
      statusColor: recordData.statusColor || 0xFF0D9488,
      summary: recordData.summary || 'Clinical record indexed into personal health timeline.',
      notes: recordData.notes || '',
      fileName: recordData.fileName || null,
      fileData: recordData.fileData || null,
      createdAt: now,
      updatedAt: now,
    };

    all.unshift(newRecord);
    writeRecords(all);
    return newRecord;
  },

  async updateRecord(id, updates) {
    const all = readRecords();
    const index = all.findIndex((r) => r.id === id);
    if (index === -1) return null;

    all[index] = {
      ...all[index],
      ...updates,
      updatedAt: new Date().toISOString(),
    };

    writeRecords(all);
    return all[index];
  },

  async deleteRecord(id) {
    const all = readRecords();
    const filtered = all.filter((r) => r.id !== id);
    if (filtered.length === all.length) return false;
    writeRecords(filtered);
    return true;
  },
};

initRecordsDb();

module.exports = recordsDb;
