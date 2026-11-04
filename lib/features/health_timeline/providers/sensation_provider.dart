import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/sensation_log.dart';
import '../models/timeline_entry.dart';
import 'timeline_provider.dart';

class SensationNotifier extends StateNotifier<List<SensationLog>> {
  static const _storageKey = 'medivision_sensations_storage';
  final FlutterSecureStorage _storage;
  final Ref _ref;

  SensationNotifier(this._ref, {FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        super(SensationLog.getInitialSampleLogs()) {
    _loadPersistedSensations();
  }

  Future<void> _loadPersistedSensations() async {
    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw != null && raw.trim().isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(raw);
        if (jsonList.isNotEmpty && mounted) {
          final loaded = jsonList
              .map((item) => SensationLog.fromJson(item as Map<String, dynamic>))
              .toList();
          state = loaded;
        }
      }
    } catch (e) {
      debugPrint('Error reading persisted sensations: $e');
    }
  }

  Future<void> _persistSensations(List<SensationLog> logs) async {
    try {
      final jsonList = logs.map((l) => l.toJson()).toList();
      await _storage.write(key: _storageKey, value: jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error persisting sensations: $e');
    }
  }

  Future<SensationLog> addSensation({
    required String systemOrArea,
    required String sensation,
    required int severity,
    List<String> qualityTags = const [],
    String? notes,
  }) async {
    final entry = SensationLog(
      id: 'sens_${DateTime.now().millisecondsSinceEpoch}',
      systemOrArea: systemOrArea,
      sensation: sensation,
      severity: severity,
      qualityTags: qualityTags,
      notes: notes,
      timestamp: DateTime.now(),
    );

    // 1. Prepend to sensations list in state
    state = [entry, ...state];

    // 2. Persist directly to device disk (FlutterSecureStorage)
    await _persistSensations(state);

    // 3. Mirror into clinical Timeline entries under Symptoms category (and persist timeline)
    final qualityDescription = qualityTags.isNotEmpty ? ' (${qualityTags.join(', ')})' : '';
    final notesSuffix = notes != null && notes.trim().isNotEmpty ? ' • ${notes.trim()}' : '';

    _ref.read(timelineProvider.notifier).addEntry(
      title: '$sensation - $systemOrArea',
      description: 'Intensity $severity/10$qualityDescription$notesSuffix',
      category: TimelineCategory.symptoms,
      metricValue: '$severity/10 Intensity',
      icon: Icons.healing_rounded,
      statusLabel: entry.severityLabel,
      statusColor: entry.severityColor,
      plainEnglishInsight: 'Sensation logged in $systemOrArea. Tracked for clinical correlations with your physiological vitals.',
      simplePillTag: 'Sensation Log',
    );

    // 4. Sync asynchronously to backend vitals/logs endpoint
    _syncToBackend(entry);

    return entry;
  }

  Future<void> _syncToBackend(SensationLog entry) async {
    try {
      final token = await _storage.read(key: 'medivision_access_token');
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final body = jsonEncode({
        'logEntry': {
          'category': 'sensation',
          'label': '${entry.sensation} (${entry.systemOrArea})',
          'value': '${entry.severity}/10',
          'unit': 'intensity',
          'timestamp': entry.timestamp.toIso8601String(),
          'notes': entry.notes ?? entry.qualityTags.join(', '),
        }
      });
      await http
          .post(Uri.parse(ApiConstants.vitals), headers: headers, body: body)
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      // Offline mode gracefully handled
    }
  }

  List<SensationLog> getLogsForSystem(String systemName) {
    final lower = systemName.toLowerCase();
    return state.where((s) => s.systemOrArea.toLowerCase().contains(lower)).toList();
  }
}

final sensationProvider = StateNotifierProvider<SensationNotifier, List<SensationLog>>((ref) {
  return SensationNotifier(ref);
});
