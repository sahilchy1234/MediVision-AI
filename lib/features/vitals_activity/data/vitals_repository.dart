import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:medivision_app/core/constants/api_constants.dart';
import 'package:medivision_app/features/vitals_activity/models/vitals_activity_model.dart';

class VitalsRepository {
  static const _storage = FlutterSecureStorage();
  static const _vitalsSnapshotKey = 'medivision_vitals_snapshot';
  static const _vitalsActivitiesKey = 'medivision_vitals_activities';
  static const _vitalsLogsKey = 'medivision_vitals_logs';
  static const _tokenKey = 'medivision_access_token';

  /// Load cached snapshot or fetch from remote backend
  static Future<VitalsSnapshot> loadSnapshot() async {
    // 1. Check local storage
    try {
      final cached = await _storage.read(key: _vitalsSnapshotKey);
      if (cached != null) {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        return VitalsSnapshot.fromJson(map);
      }
    } catch (e) {
      debugPrint('Local vitals snapshot read error: $e');
    }

    // 2. Fallback to initial
    return VitalsSnapshot.createInitial();
  }

  /// Load cached activity sessions
  static Future<List<ActivitySession>> loadActivities() async {
    try {
      final cached = await _storage.read(key: _vitalsActivitiesKey);
      if (cached != null) {
        final list = jsonDecode(cached) as List<dynamic>;
        return list.map((e) => ActivitySession.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Local activities read error: $e');
    }
    return [];
  }

  /// Load cached logs
  static Future<List<VitalLogEntry>> loadLogs() async {
    try {
      final cached = await _storage.read(key: _vitalsLogsKey);
      if (cached != null) {
        final list = jsonDecode(cached) as List<dynamic>;
        return list.map((e) => VitalLogEntry.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Local logs read error: $e');
    }
    return [];
  }

  /// Save snapshot to local storage and sync to backend
  static Future<void> saveSnapshot(VitalsSnapshot snapshot, {VitalLogEntry? newLog}) async {
    // 1. Save locally
    try {
      await _storage.write(
        key: _vitalsSnapshotKey,
        value: jsonEncode(snapshot.toJson()),
      );
    } catch (e) {
      debugPrint('Error saving vitals snapshot locally: $e');
    }

    // 2. Persist to backend
    try {
      final token = await _storage.read(key: _tokenKey);
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final body = {
        ...snapshot.toJson(),
        if (newLog != null) 'logEntry': newLog.toJson(),
      };

      await http
          .post(
            Uri.parse(ApiConstants.vitals),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Vitals backend sync notice (offline mode active): $e');
    }
  }

  /// Save activities locally
  static Future<void> saveActivities(List<ActivitySession> activities) async {
    try {
      await _storage.write(
        key: _vitalsActivitiesKey,
        value: jsonEncode(activities.map((a) => a.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving activities locally: $e');
    }
  }

  /// Save logs locally
  static Future<void> saveLogs(List<VitalLogEntry> logs) async {
    try {
      await _storage.write(
        key: _vitalsLogsKey,
        value: jsonEncode(logs.map((l) => l.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving vitals logs locally: $e');
    }
  }

  /// Sync activity session with backend
  static Future<void> syncActivityToBackend(ActivitySession session) async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      await http
          .post(
            Uri.parse(ApiConstants.vitalsActivity),
            headers: headers,
            body: jsonEncode(session.toJson()),
          )
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Activity backend sync notice: $e');
    }
  }
}
