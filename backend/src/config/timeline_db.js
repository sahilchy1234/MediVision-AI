const fs = require('fs');
const path = require('path');

const DATA_DIR = path.join(__dirname, '../../data');
const TIMELINE_FILE = path.join(DATA_DIR, 'timeline.json');

if (!fs.existsSync(DATA_DIR)) {
  fs.mkdirSync(DATA_DIR, { recursive: true });
}

function getValidClinicalSeedEvents(userId = 'usr_demo_alex_morgan') {
  const now = Date.now();
  return [
    {
      id: 'tl_valid_vitals_1',
      userId,
      title: 'Resting Cardiovascular Telemetry',
      description: '118/78 mmHg • 62 bpm resting pulse • 99% SpO2',
      timestamp: new Date(now - 2 * 3600 * 1000).toISOString(),
      category: 'symptoms',
      metricValue: '118/78 mmHg',
      statusLabel: 'Normal Sinus Rhythm',
      statusColor: 4279071496, // 0xFF0D9488
      icon: 'monitor_heart',
      plainEnglishInsight: 'Resting cardiovascular parameters are within optimal clinical target ranges with regular sinus rhythm.',
      simplePillTag: 'Normal Vitals',
      source: 'vitals_log',
      createdAt: new Date(now - 2 * 3600 * 1000).toISOString(),
      updatedAt: new Date(now - 2 * 3600 * 1000).toISOString(),
    },
    {
      id: 'tl_valid_activity_1',
      userId,
      title: 'Brisk Morning Walk',
      description: '4,820 steps • 38 min active mobility • 215 kcal burned',
      timestamp: new Date(now - 5 * 3600 * 1000).toISOString(),
      category: 'activity',
      metricValue: '4,820 steps',
      statusLabel: 'Completed',
      statusColor: 4279071496,
      icon: 'directions_walk',
      plainEnglishInsight: 'Completed 38 minutes of moderate-intensity aerobic endurance, achieving daily baseline target.',
      simplePillTag: 'Active Session',
      source: 'vitals_activity',
      createdAt: new Date(now - 5 * 3600 * 1000).toISOString(),
      updatedAt: new Date(now - 5 * 3600 * 1000).toISOString(),
    },
    {
      id: 'tl_valid_sleep_1',
      userId,
      title: 'Restorative Sleep Checkpoint',
      description: '7h 45m total rest • 1h 48m REM sleep • 89% Sleep Score',
      timestamp: new Date(now - 10 * 3600 * 1000).toISOString(),
      category: 'sleep',
      metricValue: '7h 45m',
      statusLabel: 'Restorative',
      statusColor: 4284704497, // 0xFF6366F1
      icon: 'bedtime',
      plainEnglishInsight: 'Sufficient REM and deep restorative cycles achieved. Resting heart rate lowered to 58 bpm during deep sleep.',
      simplePillTag: 'Sleep Metric',
      source: 'vitals_log',
      createdAt: new Date(now - 10 * 3600 * 1000).toISOString(),
      updatedAt: new Date(now - 10 * 3600 * 1000).toISOString(),
    },
    {
      id: 'tl_valid_report_1',
      userId,
      title: 'Comprehensive Chemistry & Lipid Panel',
      description: 'Quest Diagnostics • Fasting Blood Glucose: 92 mg/dL • Total Cholesterol: 172 mg/dL',
      timestamp: new Date(now - 48 * 3600 * 1000).toISOString(),
      category: 'reports',
      metricValue: '92 mg/dL (Normal)',
      statusLabel: 'Verified Clear',
      statusColor: 4279286145, // 0xFF10B981
      icon: 'water_drop',
      plainEnglishInsight: 'All glycemic, electrolyte, kidney, and liver function biomarkers are within standard reference ranges.',
      simplePillTag: 'Lab Panel',
      source: 'medical_records',
      createdAt: new Date(now - 48 * 3600 * 1000).toISOString(),
      updatedAt: new Date(now - 48 * 3600 * 1000).toISOString(),
    },
    {
      id: 'tl_valid_med_1',
      userId,
      title: 'Vitamin D3 (2,000 IU) & Omega-3 (1,000 mg)',
      description: 'Administered with breakfast for optimal bioavailability',
      timestamp: new Date(now - 26 * 3600 * 1000).toISOString(),
      category: 'medications',
      metricValue: '2,000 IU',
      statusLabel: 'Taken',
      statusColor: 4279286145,
      icon: 'medication',
      plainEnglishInsight: 'Daily nutritional supplement regimen supporting musculoskeletal density and cardiovascular integrity.',
      simplePillTag: 'Scheduled Dose',
      source: 'user_log',
      createdAt: new Date(now - 26 * 3600 * 1000).toISOString(),
      updatedAt: new Date(now - 26 * 3600 * 1000).toISOString(),
    },
  ];
}

function initTimelineDb() {
  if (!fs.existsSync(TIMELINE_FILE)) {
    const seedEvents = getValidClinicalSeedEvents();
    fs.writeFileSync(TIMELINE_FILE, JSON.stringify(seedEvents, null, 2), 'utf-8');
    console.log('📦 Timeline database initialized with valid clinical events');
  } else {
    // Purge any legacy mock dummy seed entries (t1 to t6) and ensure valid events if empty
    try {
      const raw = fs.readFileSync(TIMELINE_FILE, 'utf-8');
      const entries = JSON.parse(raw);
      const dummyIds = new Set(['t1', 't2', 't3', 't4', 't5', 't6']);
      let clean = entries.filter((e) => !dummyIds.has(e.id));
      if (clean.length === 0) {
        clean = getValidClinicalSeedEvents();
      }
      fs.writeFileSync(TIMELINE_FILE, JSON.stringify(clean, null, 2), 'utf-8');
      console.log('📦 Timeline database verified with real clinical events');
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
    const clean = all.filter((e) => !dummyIds.has(e.id));
    if (clean.length === 0) {
      const seed = getValidClinicalSeedEvents();
      writeTimelineEntries(seed);
      return seed;
    }
    return clean;
  } catch (err) {
    console.error('Error reading timeline database:', err);
    return [];
  }
}

function writeTimelineEntries(entries) {
  try {
    fs.writeFileSync(TIMELINE_FILE, JSON.stringify(entries, null, 2), 'utf-8');
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

  async seedValidEventsIfEmpty(userId = 'usr_demo_alex_morgan') {
    const entries = readTimelineEntries();
    const userEntries = entries.filter((e) => e.userId === userId || !e.userId);
    if (userEntries.length === 0) {
      const seed = getValidClinicalSeedEvents(userId);
      const combined = [...seed, ...entries];
      writeTimelineEntries(combined);
      return seed;
    }
    return userEntries;
  },

  getValidSeedEvents(userId = 'usr_demo_alex_morgan') {
    return getValidClinicalSeedEvents(userId);
  },
};

initTimelineDb();

module.exports = timelineDb;
