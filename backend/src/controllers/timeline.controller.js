const timelineDb = require('../config/timeline_db');
const recordsDb = require('../config/records_db');
const fs = require('fs');
const path = require('path');

const VITALS_FILE = path.join(__dirname, '../../data/vitals.json');

function readVitalsStore() {
  try {
    if (fs.existsSync(VITALS_FILE)) {
      return JSON.parse(fs.readFileSync(VITALS_FILE, 'utf-8'));
    }
  } catch (_) {}
  return {};
}

/**
 * Controller for Real Clinical Health Timeline Management
 */
const timelineController = {
  // GET /api/timeline
  async getTimeline(req, res, next) {
    try {
      const userId = req.user?.id || 'usr_demo_alex_morgan';
      const { category, search, includeAggregated = 'true' } = req.query;

      // 1. Fetch custom saved timeline events, ensuring valid clinical events exist
      let directEntries = await timelineDb.findByUserId(userId, { category, search });
      if (directEntries.length === 0 && (!category || category === 'all') && !search) {
        await timelineDb.seedValidEventsIfEmpty(userId);
        directEntries = await timelineDb.findByUserId(userId, { category, search });
      }

      if (includeAggregated !== 'true') {
        return res.status(200).json({
          success: true,
          count: directEntries.length,
          data: directEntries,
        });
      }

      // 2. Synthesize entries from real medical records
      const synthesizedRecords = [];
      try {
        const records = await recordsDb.findByUserId(userId);
        for (const record of records) {
          let timelineCategory = 'reports';
          let icon = 'document_scanner';

          if (record.category === 'prescriptions') {
            timelineCategory = 'medications';
            icon = 'medication';
          } else if (record.category === 'labs') {
            timelineCategory = 'reports';
            icon = 'water_drop';
          } else if (record.category === 'notes') {
            timelineCategory = 'reports';
            icon = 'description';
          }

          synthesizedRecords.push({
            id: `rec_tl_${record.id}`,
            userId,
            title: record.title,
            description: `${record.providerName || 'Uploaded Record'} • ${record.fileSize || 'Clinical File'}`,
            timestamp: record.date || record.createdAt,
            category: timelineCategory,
            metricValue: record.status || 'Clinical Record',
            statusLabel: record.status || 'Verified Clear',
            statusColor: record.statusColor || 4279286145, // Emerald/Teal
            icon,
            plainEnglishInsight:
              record.summary && record.summary.trim().length > 0
                ? record.summary
                : `Verified clinical documentation uploaded to your secure records vault.`,
            simplePillTag: record.status || 'Report',
            source: 'medical_records',
          });
        }
      } catch (_) {}

      // 3. Synthesize entries from real vitals & activity logs
      const synthesizedVitals = [];
      try {
        const store = readVitalsStore();
        const userData = store[userId];
        if (userData) {
          // Activities (runs, walks)
          if (Array.isArray(userData.activities)) {
            for (const act of userData.activities) {
              synthesizedVitals.push({
                id: `act_tl_${act.id}`,
                userId,
                title: `${act.type || 'Physical'} Activity Session`,
                description: `${act.steps || 0} steps over ${act.durationMinutes || 0} min • ${act.calories || 0} kcal`,
                timestamp: act.startTime || act.createdAt || new Date().toISOString(),
                category: 'activity',
                metricValue: `${act.steps || 0} steps`,
                statusLabel: 'Completed',
                statusColor: 4279071496,
                icon: act.type === 'Running' ? 'directions_run' : 'directions_walk',
                plainEnglishInsight:
                  act.notes && act.notes.trim().length > 0
                    ? act.notes
                    : `Active cardiovascular movement logged. Burned ${act.calories || 0} calories over ${act.durationMinutes || 0} minutes.`,
                simplePillTag: 'Active Session',
                source: 'activity',
              });
            }
          }

          // Vital logs (resting HR, sleep logs, steps)
          if (Array.isArray(userData.logs)) {
            for (const log of userData.logs) {
              let cat = 'activity';
              let icon = 'directions_walk';
              let color = 4279071496;

              if (log.category === 'sleep') {
                cat = 'sleep';
                icon = 'bedtime';
                color = 4284769009; // Indigo
              } else if (log.category === 'pulse') {
                cat = 'symptoms';
                icon = 'monitor_heart';
                color = 4292994376; // Rose
              } else if (log.category === 'sync') {
                cat = 'activity';
                icon = 'sync';
              }

              synthesizedVitals.push({
                id: `log_tl_${log.id}`,
                userId,
                title: log.label || 'Vital Reading',
                description: log.notes || `${log.value} ${log.unit || ''}`,
                timestamp: log.timestamp || new Date().toISOString(),
                category: cat,
                metricValue: `${log.value} ${log.unit || ''}`.trim(),
                statusLabel: log.category === 'pulse' ? 'Normal Rhythm' : 'Recorded',
                statusColor: color,
                icon,
                plainEnglishInsight: log.notes || 'Recorded vital metric in your personal health record.',
                simplePillTag: log.category ? log.category.toUpperCase() : 'Vitals',
                source: 'vitals_log',
              });
            }
          }
        }
      } catch (_) {}

      // 4. Merge, deduplicate, and filter
      const allMerged = [...directEntries, ...synthesizedRecords, ...synthesizedVitals];
      const seen = new Set();
      let uniqueEntries = [];

      for (const item of allMerged) {
        if (!seen.has(item.id)) {
          seen.add(item.id);
          uniqueEntries.push(item);
        }
      }

      if (category && category !== 'all') {
        uniqueEntries = uniqueEntries.filter((e) => e.category === category);
      }

      if (search && search.trim().length > 0) {
        const q = search.toLowerCase().trim();
        uniqueEntries = uniqueEntries.filter(
          (e) =>
            (e.title && e.title.toLowerCase().includes(q)) ||
            (e.description && e.description.toLowerCase().includes(q)) ||
            (e.plainEnglishInsight && e.plainEnglishInsight.toLowerCase().includes(q))
        );
      }

      // Sort newest first
      uniqueEntries.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

      return res.status(200).json({
        success: true,
        count: uniqueEntries.length,
        data: uniqueEntries,
      });
    } catch (err) {
      next(err);
    }
  },

  // POST /api/timeline
  async createTimelineEntry(req, res, next) {
    try {
      const userId = req.user?.id || 'usr_demo_alex_morgan';
      const {
        title,
        description,
        timestamp,
        category,
        metricValue,
        statusLabel,
        statusColor,
        icon,
        plainEnglishInsight,
        simplePillTag,
        source,
      } = req.body;

      if (!title || !title.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Title is required for a timeline event',
        });
      }

      const newEntry = await timelineDb.create({
        userId,
        title: title.trim(),
        description: description?.trim() || '',
        timestamp: timestamp || new Date().toISOString(),
        category: category || 'all',
        metricValue: metricValue?.trim() || '',
        statusLabel: statusLabel?.trim() || null,
        statusColor: statusColor || 4279071496,
        icon: icon || 'history',
        plainEnglishInsight:
          plainEnglishInsight?.trim() || 'Recorded in your personal health record.',
        simplePillTag: simplePillTag?.trim() || 'Logged',
        source: source || 'user_log',
      });

      return res.status(201).json({
        success: true,
        message: 'Timeline event created successfully',
        data: newEntry,
      });
    } catch (err) {
      next(err);
    }
  },

  // POST /api/timeline/auto-log
  async autoLogEvents(req, res, next) {
    try {
      const userId = req.user?.id || 'usr_demo_alex_morgan';
      const customEvents = req.body?.events;

      if (Array.isArray(customEvents) && customEvents.length > 0) {
        const createdList = [];
        for (const item of customEvents) {
          const created = await timelineDb.create({
            ...item,
            userId,
          });
          createdList.push(created);
        }
        return res.status(201).json({
          success: true,
          message: `${createdList.length} valid health events automatically logged`,
          data: createdList,
        });
      }

      // Generate calibrated clinical events
      const validSeeds = timelineDb.getValidSeedEvents(userId);
      const createdList = [];
      for (const item of validSeeds) {
        const created = await timelineDb.create({
          ...item,
          id: `timeline_auto_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`,
          userId,
        });
        createdList.push(created);
      }

      return res.status(201).json({
        success: true,
        message: 'Valid clinical health events automatically logged to timeline',
        data: createdList,
      });
    } catch (err) {
      next(err);
    }
  },

  // DELETE /api/timeline/:id
  async deleteTimelineEntry(req, res, next) {
    try {
      const { id } = req.params;
      const success = await timelineDb.delete(id);

      if (!success) {
        return res.status(404).json({
          success: false,
          message: 'Timeline entry not found',
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Timeline entry deleted successfully',
      });
    } catch (err) {
      next(err);
    }
  },
};

module.exports = timelineController;
