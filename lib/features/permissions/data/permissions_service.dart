import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class PermissionsService {
  static const _storage = FlutterSecureStorage();
  static const _permissionsStorageKey = 'medivision_permissions_map';
  static const _tokenKey = 'medivision_access_token';
  static const _mockModeKey = 'medivision_mock_mode_active';

  static Future<bool> isMockModeEnabled() async {
    try {
      final val = await _storage.read(key: _mockModeKey);
      return val != 'false';
    } catch (_) {
      return true;
    }
  }

  static Future<void> setMockModeEnabled(bool enabled) async {
    try {
      await _storage.write(key: _mockModeKey, value: enabled ? 'true' : 'false');
    } catch (_) {}
  }

  static const Map<String, bool> defaultPermissions = {
    'sleep_health': true,
    'physical_activity': true,
    'screen_time': true,
    'device_sensors': true,
    'medical_documents': true,
    'notifications': true,
  };

  /// Fetch user permissions from local secure storage and sync with backend
  static Future<Map<String, bool>> loadPermissions() async {
    Map<String, bool> current = Map.from(defaultPermissions);

    // 1. Read from local secure storage
    try {
      final cachedJson = await _storage.read(key: _permissionsStorageKey);
      if (cachedJson != null) {
        final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          current[entry.key] = entry.value == true;
        }
      }
    } catch (e) {
      debugPrint('Local permissions read error: $e');
    }

    // 2. Sync with backend database if logged in
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        final response = await http
            .get(
              Uri.parse(ApiConstants.permissions),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final remoteMap =
              data['data']['permissions'] as Map<String, dynamic>?;
          if (remoteMap != null) {
            for (final entry in remoteMap.entries) {
              current[entry.key] = entry.value == true;
            }
            // Update local cache
            await _storage.write(
              key: _permissionsStorageKey,
              value: jsonEncode(current),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Backend permissions sync error (offline fallback used): $e');
    }

    return current;
  }

  /// Save permissions locally and persist to backend database
  static Future<void> savePermissions(Map<String, bool> permissions) async {
    // 1. Save locally in secure storage
    try {
      await _storage.write(
        key: _permissionsStorageKey,
        value: jsonEncode(permissions),
      );
    } catch (e) {
      debugPrint('Local permissions write error: $e');
    }

    // 2. Persist to backend database
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        await http
            .put(
              Uri.parse(ApiConstants.permissions),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({'permissions': permissions}),
            )
            .timeout(const Duration(seconds: 4));
      }
    } catch (e) {
      debugPrint('Backend permissions save error: $e');
    }
  }
}

