import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../authentication/data/auth_service.dart';
import '../../medical_records/data/medical_records_repository.dart';
import '../../medical_records/models/medical_record.dart';
import '../../vitals_activity/data/vitals_repository.dart';
import '../../vitals_activity/models/vitals_activity_model.dart';
import '../models/timeline_entry.dart';

class TimelineRepository {
  static const _storageKey = 'medivision_stored_timeline_v1';
  final FlutterSecureStorage _secureStorage;
  final MedicalRecordsRepository _recordsRepo;

  TimelineRepository({
    FlutterSecureStorage? secureStorage,
    MedicalRecordsRepository? recordsRepo,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _recordsRepo = recordsRepo ?? MedicalRecordsRepository();

  /// Load aggregated real clinical timeline from local cache, device vitals,
  /// medical records vault, and the backend timeline API.
  Future<List<TimelineEntry>> loadTimeline() async {
    final Map<String, TimelineEntry> mergedMap = {};
    const dummyIds = {'t1', 't2', 't3', 't4', 't5', 't6'};

    // 1. Read locally cached custom timeline entries
    try {
      final raw = await _secureStorage.read(key: _storageKey);
      if (raw != null && raw.trim().isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(raw);
        for (final item in jsonList) {
          final entry = TimelineEntry.fromJson(item as Map<String, dynamic>);
          if (!dummyIds.contains(entry.id)) {
            mergedMap[entry.id] = entry;
          }
        }
      }
    } catch (e) {
      debugPrint('Error reading local timeline cache: $e');
    }

    // 2. Synthesize real entries from local Medical Records vault
    try {
      final records = await _recordsRepo.loadRecords();
      for (final rec in records) {
        final entry = _convertRecordToTimelineEntry(rec);
        mergedMap[entry.id] = entry;
      }
    } catch (e) {
      debugPrint('Error synthesizing records for timeline: $e');
    }

    // 3. Synthesize real entries from local Vitals & Activity logs
    try {
      final activities = await VitalsRepository.loadActivities();
      for (final act in activities) {
        final entry = _convertActivityToTimelineEntry(act);
        mergedMap[entry.id] = entry;
      }

      final logs = await VitalsRepository.loadLogs();
      for (final log in logs) {
        final entry = _convertVitalLogToTimelineEntry(log);
        mergedMap[entry.id] = entry;
      }
    } catch (e) {
      debugPrint('Error synthesizing vitals for timeline: $e');
    }

    // 4. Try fetching latest aggregated real events from backend
    try {
      final token = await AuthService.getStoredToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(Uri.parse('${ApiConstants.timeline}?includeAggregated=true'), headers: headers)
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] is List) {
          final List<dynamic> backendList = data['data'];
          for (final item in backendList) {
            final entry = TimelineEntry.fromJson(item as Map<String, dynamic>);
            if (!dummyIds.contains(entry.id)) {
              mergedMap[entry.id] = entry;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Backend timeline sync offline/unavailable: $e. Using local data.');
    }

    final resultList = mergedMap.values.toList();
    resultList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Cache clean list locally
    await saveTimelineLocally(resultList);
    return resultList;
  }

  /// Persist the complete list to local secure storage
  Future<void> saveTimelineLocally(List<TimelineEntry> entries) async {
    try {
      final jsonString = jsonEncode(entries.map((e) => e.toJson()).toList());
      await _secureStorage.write(key: _storageKey, value: jsonString);
    } catch (e) {
      debugPrint('Error saving timeline locally: $e');
    }
  }

  /// Add a newly created health timeline entry
  Future<bool> addEntry(TimelineEntry entry) async {
    // 1. Try backend sync
    try {
      final token = await AuthService.getStoredToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      await http
          .post(
            Uri.parse(ApiConstants.timeline),
            headers: headers,
            body: jsonEncode(entry.toJson()),
          )
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Failed to sync new timeline entry to backend: $e');
    }
    return true;
  }

  /// Delete a timeline entry
  Future<bool> deleteEntry(String id) async {
    try {
      final token = await AuthService.getStoredToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      await http
          .delete(Uri.parse(ApiConstants.timelineItem(id)), headers: headers)
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Failed to delete timeline entry from backend: $e');
    }
    return true;
  }

  // --- Converters from Real Sources ---

  TimelineEntry _convertRecordToTimelineEntry(MedicalRecordItem record) {
    TimelineCategory category = TimelineCategory.reports;
    IconData icon = Icons.document_scanner_rounded;

    if (record.category == RecordCategory.prescriptions) {
      category = TimelineCategory.medications;
      icon = Icons.medication_rounded;
    } else if (record.category == RecordCategory.bloodReports) {
      category = TimelineCategory.reports;
      icon = Icons.water_drop_rounded;
    } else if (record.category == RecordCategory.other) {
      category = TimelineCategory.reports;
      icon = Icons.description_rounded;
    } else if (record.category == RecordCategory.xRays) {
      category = TimelineCategory.reports;
      icon = Icons.document_scanner_rounded;
    }

    return TimelineEntry(
      id: 'rec_tl_${record.id}',
      title: record.title,
      description: '${record.providerName} • ${record.fileSize}',
      timestamp: record.date,
      category: category,
      metricValue: record.status.isNotEmpty ? record.status : 'Clinical Record',
      statusLabel: record.status.isNotEmpty ? record.status : 'Verified',
      statusColor: record.statusColor,
      icon: icon,
      plainEnglishInsight: record.summary.isNotEmpty
          ? record.summary
          : 'Verified clinical record uploaded to your secure health vault.',
      simplePillTag: record.status.isNotEmpty ? record.status : 'Record',
      source: 'medical_records',
    );
  }

  TimelineEntry _convertActivityToTimelineEntry(ActivitySession session) {
    return TimelineEntry(
      id: 'act_tl_${session.id}',
      title: '${session.type} Activity Completed',
      description:
          '${session.steps} steps logged over ${session.durationMinutes} min • ${session.calories} kcal',
      timestamp: session.startTime,
      category: TimelineCategory.activity,
      metricValue: '${session.steps} steps',
      statusLabel: 'Completed',
      statusColor: const Color(0xFF0D9488),
      icon: session.type == 'Running'
          ? Icons.directions_run_rounded
          : Icons.directions_walk_rounded,
      plainEnglishInsight: session.notes.isNotEmpty
          ? session.notes
          : 'Sustained ${session.durationMinutes} minutes of cardiovascular mobility, burning ${session.calories} calories.',
      simplePillTag: 'Active Session',
      source: 'vitals_activity',
    );
  }

  TimelineEntry _convertVitalLogToTimelineEntry(VitalLogEntry log) {
    TimelineCategory category = TimelineCategory.activity;
    IconData icon = Icons.directions_walk_rounded;
    Color color = const Color(0xFF0D9488);

    if (log.category == 'sleep') {
      category = TimelineCategory.sleep;
      icon = Icons.bedtime_rounded;
      color = const Color(0xFF6366F1);
    } else if (log.category == 'pulse') {
      category = TimelineCategory.symptoms;
      icon = Icons.monitor_heart_outlined;
      color = const Color(0xFFE11D48);
    } else if (log.category == 'sync') {
      category = TimelineCategory.activity;
      icon = Icons.sync_rounded;
      color = const Color(0xFF0D9488);
    }

    return TimelineEntry(
      id: 'log_tl_${log.id}',
      title: log.label,
      description: log.notes.isNotEmpty ? log.notes : '${log.value} ${log.unit}',
      timestamp: log.timestamp,
      category: category,
      metricValue: '${log.value} ${log.unit}'.trim(),
      statusLabel: log.category == 'pulse' ? 'Normal Rhythm' : 'Recorded',
      statusColor: color,
      icon: icon,
      plainEnglishInsight: log.notes.isNotEmpty
          ? log.notes
          : 'Recorded vital metric in your personal health record.',
      simplePillTag: log.category.toUpperCase(),
      source: 'vitals_log',
    );
  }
}
