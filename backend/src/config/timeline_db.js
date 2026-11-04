const fs = require('fs');
const path = require('path');

const DATA_DIR = path.join(__dirname, '../../data');
const TIMELINE_FILE = path.join(DATA_DIR, 'timeline.json');

if (!fs.existsSync(DATA_DIR)) {
  fs.mkdirSync(DATA_DIR, { recursive: true });
}

function initTimelineDb() {
  if (!fs.existsSync(TIMELINE_FILE)) {
    fs.writeFileSync(TIMELINE_FILE, JSON.stringify([], null, 2), 'utf-8');
    console.log('📦 Timeline database initialized (Clean user timeline)');
  } else {
    // Purge any legacy mock dummy seed entries (t1 to t6)
    try {
      const entries = JSON.parse(fs.readFileSync(TIMELINE_FILE, 'utf-8'));
      const dummyIds = new Set(['t1', 't2', 't3', 't4', 't5', 't6']);
      const clean = entries.filter((e) => !dummyIds.has(e.id));
      if (clean.length !== entries.length) {
        fs.writeFileSync(TIMELINE_FILE, JSON.stringify(clean, null, 2), 'utf-8');
        console.log('🧹 Purged dummy sample timeline entries from database');
      }
    } catch (_) {}
  }
}

function readTimelineEntries() {
  try {
    if (!fs.existsSync(TIMELINE_FILE)) {
      initTimelineDb();
    }
    const raw = fs.readFileSync(TIMELINE_FILE, 'utf-8');
    const all = JSON.parse(raw);
    const dummyIds = new Set(['t1', 't2', 't3', 't4', 't5', 't6']);
    return all.filter((e) => !dummyIds.has(e.id));
  } catch (err) {
    console.error('Error reading timeline database:', err);
    return [];
  }
}

function writeTimelineEntries(entries) {
  try {
    const tempFile = `${TIMELINE_FILE}.tmp`;
    fs.writeFileSync(tempFile, JSON.stringify(entries, null, 2), 'utf-8');
    fs.renameSync(tempFile, TIMELINE_FILE);
    return true;
  } catch (err) {
    console.error('Error writing timeline database:', err);
    return false;
  }
}

const timelineDb = {
  async getAll() {
    return readTimelineEntries();
  },

  async findByUserId(userId, filters = {}) {
    let entries = readTimelineEntries().filter((e) => e.userId === userId || !e.userId);

    if (filters.category && filters.category !== 'all') {
      entries = entries.filter((e) => e.category === filters.category);
    }

    if (filters.search) {
      const q = filters.search.toLowerCase();
      entries = entries.filter(
        (e) =>
          (e.title && e.title.toLowerCase().includes(q)) ||
          (e.description && e.description.toLowerCase().includes(q)) ||
          (e.plainEnglishInsight && e.plainEnglishInsight.toLowerCase().includes(q))
      );
    }

    // Sort newest first
    entries.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
    return entries;
  },

  async findById(id) {
    const entries = readTimelineEntries();
    return entries.find((e) => e.id === id) || null;
  },

  async create(data) {
    const entries = readTimelineEntries();
    const newEntry = {
      id: data.id || `timeline_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`,
      userId: data.userId || 'usr_demo_alex_morgan',
      title: data.title || 'Health Event',
      description: data.description || '',
      timestamp: data.timestamp ? new Date(data.timestamp).toISOString() : new Date().toISOString(),
      category: data.category || 'all',
      metricValue: data.metricValue || '',
      statusLabel: data.statusLabel || null,
      statusColor: data.statusColor || 4279071496, // 0xFF0D9488
      icon: data.icon || 'history',
      plainEnglishInsight: data.plainEnglishInsight || 'Recorded in your personal health record.',
      simplePillTag: data.simplePillTag || 'Logged',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    entries.unshift(newEntry);
    writeTimelineEntries(entries);
    return newEntry;
  },

  async update(id, updates) {
    const entries = readTimelineEntries();
    const idx = entries.findIndex((e) => e.id === id);
    if (idx === -1) return null;

    entries[idx] = {
      ...entries[idx],
      ...updates,
      updatedAt: new Date().toISOString(),
    };

    writeTimelineEntries(entries);
    return entries[idx];
  },

  async delete(id) {
    const entries = readTimelineEntries();
    const filtered = entries.filter((e) => e.id !== id);
    if (filtered.length === entries.length) return false;

    writeTimelineEntries(filtered);
    return true;
  },
};

initTimelineDb();

module.exports = timelineDb;
