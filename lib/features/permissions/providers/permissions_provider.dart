import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/permission_item.dart';
import '../data/permissions_service.dart';

class PermissionsNotifier extends StateNotifier<List<HealthPermissionItem>> {
  PermissionsNotifier() : super(_initialItems) {
    _initAndSync();
  }

  static const List<HealthPermissionItem> _initialItems = [
    HealthPermissionItem(
      id: 'sleep_health',
      title: 'Sleep and Health Data',
      description: 'Access Apple Health / Health Connect sleep stages and vitals.',
      rationale:
          'Needed by MediVision to detect sleep anomalies and correlate circadian rhythms.',
      icon: Icons.bedtime_rounded,
      status: PermissionStatus.granted,
    ),
    HealthPermissionItem(
      id: 'physical_activity',
      title: 'Physical Activity & Steps',
      description:
          'Read steps, active minutes, and cardiovascular heart rate zones.',
      rationale:
          'Required to track daily exertion and recommend adaptive recovery pacing.',
      icon: Icons.directions_run_rounded,
      status: PermissionStatus.granted,
    ),
    HealthPermissionItem(
      id: 'screen_time',
      title: 'Screen-time Summaries',
      description:
          'Read aggregated daily screen duration and pre-bed usage metrics.',
      rationale:
          'Enables AI insights on how late-night digital blue light affects deep sleep.',
      icon: Icons.phone_android_rounded,
      status: PermissionStatus.granted,
    ),
    HealthPermissionItem(
      id: 'device_sensors',
      title: 'Device Sensors & Heart Monitor',
      description:
          'Direct pairing with supported Bluetooth smart rings and monitors.',
      rationale: 'Allows real-time pulse and temperature trend tracking.',
      icon: Icons.sensors_rounded,
      status: PermissionStatus.granted,
    ),
    HealthPermissionItem(
      id: 'medical_documents',
      title: 'Medical Document Access',
      description:
          'Access file storage to import lab PDFs, X-ray DICOMs, and scans.',
      rationale: 'Essential for OCR reading and AI health timeline integration.',
      icon: Icons.folder_shared_rounded,
      status: PermissionStatus.granted,
    ),
    HealthPermissionItem(
      id: 'notifications',
      title: 'Health Notifications',
      description:
          'Deliver timely medication reminders and circadian alerts.',
      rationale:
          'Crucial for proactive health guidance and urgent report anomalies.',
      icon: Icons.notifications_active_rounded,
      status: PermissionStatus.granted,
    ),
  ];

  Future<void> _initAndSync() async {
    try {
      final savedMap = await PermissionsService.loadPermissions();
      state = [
        for (final item in state)
          item.copyWith(
            status: savedMap[item.id] == false
                ? PermissionStatus.notGranted
                : PermissionStatus.granted,
          ),
      ];
    } catch (_) {}
  }

  /// Sync permissions directly from logged in user payload
  void syncFromMap(Map<String, dynamic>? remoteMap) {
    if (remoteMap == null || remoteMap.isEmpty) {
      grantAll();
      return;
    }
    state = [
      for (final item in state)
        item.copyWith(
          status: remoteMap[item.id] == false
              ? PermissionStatus.notGranted
              : PermissionStatus.granted,
        ),
    ];
    PermissionsService.savePermissions(_toMap());
  }

  /// Re-sync permissions with backend after login/token change
  Future<void> reloadAndSync() async {
    await _initAndSync();
  }

  Map<String, bool> _toMap() {
    return {
      for (final item in state)
        item.id: item.status == PermissionStatus.granted,
    };
  }

  void togglePermission(String id) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(
            status: item.status == PermissionStatus.granted
                ? PermissionStatus.notGranted
                : PermissionStatus.granted,
          )
        else
          item
    ];
    PermissionsService.savePermissions(_toMap());
  }

  void grantAll() {
    state = [
      for (final item in state)
        item.copyWith(status: PermissionStatus.granted)
    ];
    PermissionsService.savePermissions(_toMap());
  }

  void useMockDataSources() {
    state = [
      for (final item in state)
        item.copyWith(status: PermissionStatus.granted)
    ];
    PermissionsService.savePermissions(_toMap());
    PermissionsService.setMockModeEnabled(true);
  }

  void revokeAll() {
    state = [
      for (final item in state)
        item.copyWith(status: PermissionStatus.notGranted)
    ];
    PermissionsService.savePermissions(_toMap());
  }

  bool isGranted(String id) {
    return state.any(
      (p) => p.id == id && p.status == PermissionStatus.granted,
    );
  }

  bool get isSleepGranted => isGranted('sleep_health');
  bool get isActivityGranted => isGranted('physical_activity');
  bool get isScreenTimeGranted => isGranted('screen_time');
  bool get isSensorsGranted => isGranted('device_sensors');
  bool get isDocumentsGranted => isGranted('medical_documents');
  bool get isNotificationsGranted => isGranted('notifications');
}

final permissionsProvider =
    StateNotifierProvider<PermissionsNotifier, List<HealthPermissionItem>>((ref) {
  return PermissionsNotifier();
});
