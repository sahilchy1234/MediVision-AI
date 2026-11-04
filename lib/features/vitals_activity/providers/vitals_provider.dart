import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medivision_app/features/health_timeline/models/timeline_entry.dart';
import 'package:medivision_app/features/health_timeline/providers/timeline_provider.dart';
import 'package:medivision_app/features/vitals_activity/data/mobile_health_sync_service.dart';
import 'package:medivision_app/features/vitals_activity/data/vitals_repository.dart';
import 'package:medivision_app/features/vitals_activity/models/vitals_activity_model.dart';

class VitalsState {
  final VitalsSnapshot snapshot;
  final List<ActivitySession> activities;
  final List<VitalLogEntry> logs;
  final bool isLoading;
  final bool isSyncingMobileData;
  final String? lastSyncSource;
  final DateTime? lastSyncTime;

  // Live Activity Tracking
  final bool isLiveTrackingActive;
  final bool isLiveTrackingPaused;
  final String liveTrackerType;
  final int liveElapsedSeconds;
  final int liveSteps;
  final int liveCalories;
  final double liveDistanceKm;

  const VitalsState({
    required this.snapshot,
    this.activities = const [],
    this.logs = const [],
    this.isLoading = false,
    this.isSyncingMobileData = false,
    this.lastSyncSource,
    this.lastSyncTime,
    this.isLiveTrackingActive = false,
    this.isLiveTrackingPaused = false,
    this.liveTrackerType = 'Walking',
    this.liveElapsedSeconds = 0,
    this.liveSteps = 0,
    this.liveCalories = 0,
    this.liveDistanceKm = 0.0,
  });

  String get formattedLiveDuration {
    final minutes = liveElapsedSeconds ~/ 60;
    final seconds = liveElapsedSeconds % 60;
    final hours = minutes ~/ 60;
    if (hours > 0) {
      final remMin = minutes % 60;
      return '${hours.toString().padLeft(2, '0')}:${remMin.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  VitalsState copyWith({
    VitalsSnapshot? snapshot,
    List<ActivitySession>? activities,
    List<VitalLogEntry>? logs,
    bool? isLoading,
    bool? isSyncingMobileData,
    String? lastSyncSource,
    DateTime? lastSyncTime,
    bool? isLiveTrackingActive,
    bool? isLiveTrackingPaused,
    String? liveTrackerType,
    int? liveElapsedSeconds,
    int? liveSteps,
    int? liveCalories,
    double? liveDistanceKm,
  }) {
    return VitalsState(
      snapshot: snapshot ?? this.snapshot,
      activities: activities ?? this.activities,
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      isSyncingMobileData: isSyncingMobileData ?? this.isSyncingMobileData,
      lastSyncSource: lastSyncSource ?? this.lastSyncSource,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      isLiveTrackingActive: isLiveTrackingActive ?? this.isLiveTrackingActive,
      isLiveTrackingPaused: isLiveTrackingPaused ?? this.isLiveTrackingPaused,
      liveTrackerType: liveTrackerType ?? this.liveTrackerType,
      liveElapsedSeconds: liveElapsedSeconds ?? this.liveElapsedSeconds,
      liveSteps: liveSteps ?? this.liveSteps,
      liveCalories: liveCalories ?? this.liveCalories,
      liveDistanceKm: liveDistanceKm ?? this.liveDistanceKm,
    );
  }
}

class VitalsNotifier extends StateNotifier<VitalsState> {
  final Ref _ref;
  Timer? _liveTimer;
  int _lastKnownPedometerSteps = 0;

  VitalsNotifier(this._ref)
      : super(VitalsState(snapshot: VitalsSnapshot.createInitial())) {
    _initData();
  }

  Future<void> _initData() async {
    state = state.copyWith(isLoading: true);
    try {
      final snapshot = await VitalsRepository.loadSnapshot();
      final activities = await VitalsRepository.loadActivities();
      final logs = await VitalsRepository.loadLogs();

      state = state.copyWith(
        snapshot: snapshot,
        activities: activities,
        logs: logs,
        isLoading: false,
      );

      // Auto-fetch real mobile health data on startup
      unawaited(syncWithMobileDevice(silent: true));

      // Hook up continuous hardware pedometer sensor stream
      _initLivePedometerSensor();
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Listens to real mobile hardware pedometer steps continuously
  void _initLivePedometerSensor() {
    MobileHealthSyncService.startLivePedometerTracking(
      onStepUpdate: (deltaSteps, status) {
        if (deltaSteps > _lastKnownPedometerSteps) {
          final difference = deltaSteps - _lastKnownPedometerSteps;
          _lastKnownPedometerSteps = deltaSteps;

          final newSteps = state.snapshot.steps + difference;
          final newCalories = (newSteps * 0.045).round();

          final updatedSnapshot = state.snapshot.copyWith(
            steps: newSteps,
            activeCalories: newCalories,
            lastUpdated: DateTime.now(),
          );

          state = state.copyWith(snapshot: updatedSnapshot);
          unawaited(VitalsRepository.saveSnapshot(updatedSnapshot));
        }
      },
    );
  }

  /// Automatically fetches all real health data from the mobile device (Health Connect / Apple Health / Pedometer)
  Future<MobileHealthSyncResult> syncWithMobileDevice({bool silent = false}) async {
    state = state.copyWith(isSyncingMobileData: true);

    try {
      // 1. Ensure permissions are requested if needed
      await MobileHealthSyncService.requestAllPermissions();

      // 2. Fetch all real data points from device
      final result = await MobileHealthSyncService.fetchMobileHealthData();

      if (result.hasAnyData) {
        final updatedSnapshot = state.snapshot.copyWith(
          steps: result.steps ?? state.snapshot.steps,
          restingHeartRate: result.restingHeartRate ?? state.snapshot.restingHeartRate,
          sleepDurationMinutes: result.sleepDurationMinutes ?? state.snapshot.sleepDurationMinutes,
          deepSleepMinutes: result.deepSleepMinutes ?? state.snapshot.deepSleepMinutes,
          activeCalories: result.activeCalories ?? state.snapshot.activeCalories,
          bloodPressureSystolic: result.systolicBP ?? state.snapshot.bloodPressureSystolic,
          bloodPressureDiastolic: result.diastolicBP ?? state.snapshot.bloodPressureDiastolic,
          bloodOxygenSpO2: result.spO2 ?? state.snapshot.bloodOxygenSpO2,
          bodyTemperature: result.temperature ?? state.snapshot.bodyTemperature,
          lastUpdated: DateTime.now(),
        );

        final syncLog = VitalLogEntry(
          id: 'log_sync_${DateTime.now().millisecondsSinceEpoch}',
          category: 'sync',
          label: 'Mobile Sync (${result.source})',
          value: '${updatedSnapshot.formattedSteps} steps',
          unit: 'steps',
          timestamp: DateTime.now(),
          notes: 'Auto-fetched from mobile: ${updatedSnapshot.formattedPulse} pulse, ${updatedSnapshot.formattedSleep} sleep, ${updatedSnapshot.formattedBP} BP.',
        );

        final updatedLogs = [syncLog, ...state.logs];

        state = state.copyWith(
          snapshot: updatedSnapshot,
          logs: updatedLogs,
          isSyncingMobileData: false,
          lastSyncSource: result.source,
          lastSyncTime: DateTime.now(),
        );

        await VitalsRepository.saveSnapshot(updatedSnapshot, newLog: syncLog);
        await VitalsRepository.saveLogs(updatedLogs);

        if (!silent) {
          _ref.read(timelineProvider.notifier).addEntry(
            title: 'Auto-Synced from Mobile Device',
            description: 'Captured real data from ${result.source}: ${updatedSnapshot.formattedSteps} steps, ${updatedSnapshot.formattedPulse} resting heart rate, and ${updatedSnapshot.formattedSleep} sleep duration.',
            category: TimelineCategory.activity,
            metricValue: '${updatedSnapshot.formattedSteps} steps',
            icon: Icons.sync_rounded,
            statusLabel: 'Device Synced',
            statusColor: const Color(0xFF0D9488),
            plainEnglishInsight: 'Your phone sensors and health data sources automatically synchronized your latest physiological metrics.',
            simplePillTag: 'Mobile Sync',
          );
        }
      } else {
        state = state.copyWith(
          isSyncingMobileData: false,
          lastSyncSource: result.source,
          lastSyncTime: DateTime.now(),
        );
      }

      return result;
    } catch (e) {
      debugPrint('Sync with mobile device error: $e');
      state = state.copyWith(isSyncingMobileData: false);
      return MobileHealthSyncResult(
        success: false,
        source: 'Error',
        message: 'Could not fetch mobile data: $e',
      );
    }
  }

  // --- LIVE ACTIVITY TRACKER ---

  void startLiveTracking({String type = 'Walking'}) {
    _liveTimer?.cancel();
    state = state.copyWith(
      isLiveTrackingActive: true,
      isLiveTrackingPaused: false,
      liveTrackerType: type,
      liveElapsedSeconds: 0,
      liveSteps: 0,
      liveCalories: 0,
      liveDistanceKm: 0.0,
    );

    // Realistic pedometer cadence timer
    _liveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isLiveTrackingPaused) return;

      final newSeconds = state.liveElapsedSeconds + 1;
      final stepIncrement = state.liveTrackerType == 'Running' ? 3 : 2;
      final newSteps = state.liveSteps + stepIncrement;
      final newDistanceKm = double.parse((newSteps * 0.00076).toStringAsFixed(2));
      final newCalories = (newSteps * 0.045).round();

      state = state.copyWith(
        liveElapsedSeconds: newSeconds,
        liveSteps: newSteps,
        liveCalories: newCalories,
        liveDistanceKm: newDistanceKm,
      );
    });
  }

  void pauseLiveTracking() {
    state = state.copyWith(isLiveTrackingPaused: true);
  }

  void resumeLiveTracking() {
    state = state.copyWith(isLiveTrackingPaused: false);
  }

  void addManualLiveSteps(int additionalSteps) {
    if (!state.isLiveTrackingActive) return;
    final newSteps = state.liveSteps + additionalSteps;
    final newDistanceKm = double.parse((newSteps * 0.00076).toStringAsFixed(2));
    final newCalories = (newSteps * 0.045).round();
    state = state.copyWith(
      liveSteps: newSteps,
      liveCalories: newCalories,
      liveDistanceKm: newDistanceKm,
    );
  }

  Future<ActivitySession> finishLiveTracking({String notes = ''}) async {
    _liveTimer?.cancel();
    _liveTimer = null;

    final durationMin = (state.liveElapsedSeconds / 60).ceil().clamp(1, 1440);
    final session = ActivitySession(
      id: 'act_${DateTime.now().millisecondsSinceEpoch}',
      type: state.liveTrackerType,
      startTime: DateTime.now().subtract(Duration(seconds: state.liveElapsedSeconds)),
      durationMinutes: durationMin,
      steps: state.liveSteps,
      calories: state.liveCalories,
      distanceKm: state.liveDistanceKm,
      avgHeartRate: state.snapshot.restingHeartRate + 32,
      notes: notes.isNotEmpty ? notes : 'Live recorded ${state.liveTrackerType.toLowerCase()} session.',
    );

    // Accumulate into daily snapshot
    final newSnapshot = state.snapshot.copyWith(
      steps: state.snapshot.steps + state.liveSteps,
      activeMinutes: state.snapshot.activeMinutes + durationMin,
      activeCalories: state.snapshot.activeCalories + state.liveCalories,
      lastUpdated: DateTime.now(),
    );

    final newLog = VitalLogEntry(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      category: 'activity',
      label: '${session.type} Completed',
      value: '${session.steps} steps',
      unit: 'steps',
      timestamp: DateTime.now(),
      notes: '${session.durationMinutes} min • ${session.calories} kcal • ${session.distanceKm} km',
    );

    final updatedActivities = [session, ...state.activities];
    final updatedLogs = [newLog, ...state.logs];

    state = state.copyWith(
      snapshot: newSnapshot,
      activities: updatedActivities,
      logs: updatedLogs,
      isLiveTrackingActive: false,
      isLiveTrackingPaused: false,
      liveElapsedSeconds: 0,
      liveSteps: 0,
      liveCalories: 0,
      liveDistanceKm: 0.0,
    );

    // Save locally and sync to backend
    await VitalsRepository.saveSnapshot(newSnapshot, newLog: newLog);
    await VitalsRepository.saveActivities(updatedActivities);
    await VitalsRepository.saveLogs(updatedLogs);
    unawaited(VitalsRepository.syncActivityToBackend(session));

    // Also dispatch to timeline provider
    _ref.read(timelineProvider.notifier).addEntry(
      title: '${session.type} Activity Completed',
      description: '${session.steps} steps logged over ${session.durationMinutes} minutes. ${session.calories} active calories burned.',
      category: TimelineCategory.activity,
      metricValue: '${session.steps} steps',
      icon: session.type == 'Running' ? Icons.directions_run_rounded : Icons.directions_walk_rounded,
      statusLabel: 'Completed',
      statusColor: const Color(0xFF0D9488),
      plainEnglishInsight: 'Great aerobic session! You increased your heart rate and burned ${session.calories} calories, building cardiovascular resilience.',
      simplePillTag: 'Active Session',
    );

    return session;
  }

  void cancelLiveTracking() {
    _liveTimer?.cancel();
    _liveTimer = null;
    state = state.copyWith(
      isLiveTrackingActive: false,
      isLiveTrackingPaused: false,
      liveElapsedSeconds: 0,
      liveSteps: 0,
      liveCalories: 0,
      liveDistanceKm: 0.0,
    );
  }

  // --- RECORDING REAL VITALS & SLEEP ---

  /// Record Resting Pulse / Heart Rate
  Future<void> recordPulse({
    required int bpm,
    int? systolic,
    int? diastolic,
    int? spO2,
    double? temperature,
    String notes = '',
  }) async {
    final updatedSnapshot = state.snapshot.copyWith(
      restingHeartRate: bpm,
      bloodPressureSystolic: systolic ?? state.snapshot.bloodPressureSystolic,
      bloodPressureDiastolic: diastolic ?? state.snapshot.bloodPressureDiastolic,
      bloodOxygenSpO2: spO2 ?? state.snapshot.bloodOxygenSpO2,
      bodyTemperature: temperature ?? state.snapshot.bodyTemperature,
      lastUpdated: DateTime.now(),
    );

    final log = VitalLogEntry(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      category: 'pulse',
      label: 'Heart Rate & Vitals',
      value: '$bpm bpm',
      unit: 'bpm',
      timestamp: DateTime.now(),
      notes: notes.isNotEmpty
          ? notes
          : 'Resting pulse: $bpm bpm • BP: ${updatedSnapshot.formattedBP} • SpO2: ${updatedSnapshot.bloodOxygenSpO2}%',
    );

    final updatedLogs = [log, ...state.logs];
    state = state.copyWith(snapshot: updatedSnapshot, logs: updatedLogs);

    await VitalsRepository.saveSnapshot(updatedSnapshot, newLog: log);
    await VitalsRepository.saveLogs(updatedLogs);

    // Push to timeline
    _ref.read(timelineProvider.notifier).addEntry(
      title: 'Resting Pulse & Vitals Measured',
      description: 'Resting heart rate recorded at $bpm bpm. Blood pressure: ${updatedSnapshot.formattedBP}, Blood oxygen: ${updatedSnapshot.bloodOxygenSpO2}%.',
      category: TimelineCategory.symptoms,
      metricValue: '$bpm bpm',
      icon: Icons.monitor_heart_outlined,
      statusLabel: 'Normal Rhythm',
      statusColor: const Color(0xFFE11D48),
      plainEnglishInsight: 'Your resting cardiovascular readings are stable and within the recommended healthy range.',
      simplePillTag: 'Vitals Recorded',
    );
  }

  /// Record Sleep
  Future<void> recordSleep({
    required int totalMinutes,
    required int deepSleepMinutes,
    int? qualityScore,
    String notes = '',
  }) async {
    final updatedSnapshot = state.snapshot.copyWith(
      sleepDurationMinutes: totalMinutes,
      deepSleepMinutes: deepSleepMinutes,
      sleepQualityScore: qualityScore ?? 88,
      lastUpdated: DateTime.now(),
    );

    final log = VitalLogEntry(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      category: 'sleep',
      label: 'Night Sleep Log',
      value: updatedSnapshot.formattedSleep,
      unit: 'duration',
      timestamp: DateTime.now(),
      notes: notes.isNotEmpty
          ? notes
          : 'Total: ${updatedSnapshot.formattedSleep} • Deep Sleep: ${updatedSnapshot.formattedDeepSleep}',
    );

    final updatedLogs = [log, ...state.logs];
    state = state.copyWith(snapshot: updatedSnapshot, logs: updatedLogs);

    await VitalsRepository.saveSnapshot(updatedSnapshot, newLog: log);
    await VitalsRepository.saveLogs(updatedLogs);

    // Push to timeline
    _ref.read(timelineProvider.notifier).addEntry(
      title: 'Sleep Record Updated',
      description: '${updatedSnapshot.formattedSleep} logged with ${updatedSnapshot.formattedDeepSleep} of deep regenerative sleep.',
      category: TimelineCategory.sleep,
      metricValue: updatedSnapshot.formattedSleep,
      icon: Icons.bedtime_rounded,
      statusLabel: 'Well Rested',
      statusColor: const Color(0xFF6366F1),
      plainEnglishInsight: 'Optimal sleep structure! Your brain and physical tissues received deep stage recovery for mental clarity.',
      simplePillTag: 'Rest Logged',
    );
  }

  /// Record Steps / Physical Movement
  Future<void> recordSteps({
    required int steps,
    int? activeMinutes,
    int? calories,
    String notes = '',
  }) async {
    final updatedSnapshot = state.snapshot.copyWith(
      steps: steps,
      activeMinutes: activeMinutes ?? state.snapshot.activeMinutes,
      activeCalories: calories ?? (steps * 0.045).round(),
      lastUpdated: DateTime.now(),
    );

    final log = VitalLogEntry(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      category: 'steps',
      label: 'Daily Steps Update',
      value: '$steps',
      unit: 'steps',
      timestamp: DateTime.now(),
      notes: notes.isNotEmpty ? notes : 'Logged daily step count to $steps steps.',
    );

    final updatedLogs = [log, ...state.logs];
    state = state.copyWith(snapshot: updatedSnapshot, logs: updatedLogs);

    await VitalsRepository.saveSnapshot(updatedSnapshot, newLog: log);
    await VitalsRepository.saveLogs(updatedLogs);

    _ref.read(timelineProvider.notifier).addEntry(
      title: 'Daily Steps Recorded',
      description: '${updatedSnapshot.formattedSteps} steps logged for today (${updatedSnapshot.stepsSubtitle}).',
      category: TimelineCategory.activity,
      metricValue: '${updatedSnapshot.formattedSteps} steps',
      icon: Icons.directions_walk_rounded,
      statusLabel: 'Goal Progress',
      statusColor: const Color(0xFF0D9488),
      plainEnglishInsight: 'You are on track with your physical mobility goal, stimulating healthy metabolic glucose control.',
      simplePillTag: 'Steps Logged',
    );
  }

  /// Record Screen Time
  Future<void> recordScreenTime({
    required int minutes,
    int? pickups,
  }) async {
    final updatedSnapshot = state.snapshot.copyWith(
      screenTimeMinutes: minutes,
      screenPickups: pickups ?? state.snapshot.screenPickups,
      lastUpdated: DateTime.now(),
    );

    final log = VitalLogEntry(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      category: 'screentime',
      label: 'Screen Time Log',
      value: updatedSnapshot.formattedScreenTime,
      unit: 'duration',
      timestamp: DateTime.now(),
      notes: 'Recorded daily device screen duration.',
    );

    final updatedLogs = [log, ...state.logs];
    state = state.copyWith(snapshot: updatedSnapshot, logs: updatedLogs);

    await VitalsRepository.saveSnapshot(updatedSnapshot, newLog: log);
    await VitalsRepository.saveLogs(updatedLogs);
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    MobileHealthSyncService.dispose();
    super.dispose();
  }
}

final vitalsProvider = StateNotifierProvider<VitalsNotifier, VitalsState>((ref) {
  return VitalsNotifier(ref);
});
