import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class MobileHealthSyncResult {
  final bool success;
  final String source;
  final int? steps;
  final int? restingHeartRate;
  final int? sleepDurationMinutes;
  final int? deepSleepMinutes;
  final int? activeCalories;
  final int? systolicBP;
  final int? diastolicBP;
  final int? spO2;
  final double? temperature;
  final String message;

  const MobileHealthSyncResult({
    required this.success,
    required this.source,
    this.steps,
    this.restingHeartRate,
    this.sleepDurationMinutes,
    this.deepSleepMinutes,
    this.activeCalories,
    this.systolicBP,
    this.diastolicBP,
    this.spO2,
    this.temperature,
    required this.message,
  });

  bool get hasAnyData =>
      steps != null ||
      restingHeartRate != null ||
      sleepDurationMinutes != null ||
      activeCalories != null ||
      systolicBP != null ||
      spO2 != null;
}

class MobileHealthSyncService {
  static final Health _health = Health();
  static StreamSubscription<StepCount>? _stepSubscription;
  static StreamSubscription<PedestrianStatus>? _statusSubscription;
  static int _initialPedometerBase = -1;
  static int _currentSensorSteps = 0;
  static String _currentPedestrianStatus = 'Unknown';

  static bool get isMobilePlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static final List<HealthDataType> _supportedTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BODY_TEMPERATURE,
  ];

  /// Request all mobile permissions (Activity recognition, Sensors, Health Connect/Apple Health)
  static Future<bool> requestAllPermissions() async {
    if (!isMobilePlatform) return true;

    try {
      // 1. Android runtime permissions
      if (Platform.isAndroid) {
        final activityStatus = await Permission.activityRecognition.request();
        debugPrint('Activity Recognition permission: $activityStatus');
        await Permission.sensors.request();
      }

      // 2. Health Connect / Apple Health permissions
      final authorized = await _health.requestAuthorization(_supportedTypes);
      debugPrint('Health authorization result: $authorized');
      return authorized;
    } catch (e) {
      debugPrint('Permission request error: $e');
      return false;
    }
  }

  /// Automatically fetch all available health data from the mobile device
  static Future<MobileHealthSyncResult> fetchMobileHealthData() async {
    if (!isMobilePlatform) {
      return const MobileHealthSyncResult(
        success: true,
        source: 'Desktop / Sandbox Mode',
        message: 'Running on non-mobile platform. Using stored local baselines.',
      );
    }

    int? fetchedSteps;
    int? fetchedHeartRate;
    int? fetchedSleepMinutes;
    int? fetchedDeepSleepMinutes;
    int? fetchedCalories;
    int? fetchedSys;
    int? fetchedDia;
    int? fetchedSpO2;
    double? fetchedTemp;

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    final yesterdayEvening = midnight.subtract(const Duration(hours: 12));

    String sourceName = Platform.isAndroid ? 'Health Connect' : 'Apple Health';

    try {
      // 1. Attempt Health Connect / Apple Health retrieval
      final authorized = await _health.hasPermissions(_supportedTypes);
      if (authorized == true || (await _health.requestAuthorization(_supportedTypes))) {
        // A. Total Steps Today
        try {
          final stepsCount = await _health.getTotalStepsInInterval(midnight, now);
          if (stepsCount != null && stepsCount > 0) {
            fetchedSteps = stepsCount;
          }
        } catch (e) {
          debugPrint('Health steps interval query error: $e');
        }

        // B. Fetch Data Points for Today and last night
        try {
          final dataPoints = await _health.getHealthDataFromTypes(
            types: _supportedTypes,
            startTime: yesterdayEvening,
            endTime: now,
          );

          for (final point in dataPoints) {
            final val = point.value;

            // Heart Rate
            if (point.type == HealthDataType.HEART_RATE) {
              if (val is NumericHealthValue) {
                final bpm = val.numericValue.round();
                if (bpm > 40 && bpm < 200) {
                  fetchedHeartRate = bpm;
                }
              }
            }
            // Active Calories
            else if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
              if (val is NumericHealthValue) {
                fetchedCalories = (fetchedCalories ?? 0) + val.numericValue.round();
              }
            }
            // Blood Pressure
            else if (point.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC) {
              if (val is NumericHealthValue) fetchedSys = val.numericValue.round();
            } else if (point.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC) {
              if (val is NumericHealthValue) fetchedDia = val.numericValue.round();
            }
            // Blood Oxygen (SpO2)
            else if (point.type == HealthDataType.BLOOD_OXYGEN) {
              if (val is NumericHealthValue) {
                double pct = val.numericValue.toDouble();
                if (pct <= 1.0) pct = pct * 100;
                fetchedSpO2 = pct.round().clamp(70, 100);
              }
            }
            // Temperature
            else if (point.type == HealthDataType.BODY_TEMPERATURE) {
              if (val is NumericHealthValue) {
                fetchedTemp = val.numericValue.toDouble();
              }
            }
            // Sleep Sessions
            else if (point.type == HealthDataType.SLEEP_SESSION) {
              final durationMins = point.dateTo.difference(point.dateFrom).inMinutes;
              if (durationMins > 60 && durationMins < 900) {
                fetchedSleepMinutes = (fetchedSleepMinutes ?? 0) + durationMins;
              }
            } else if (point.type == HealthDataType.SLEEP_DEEP) {
              final durationMins = point.dateTo.difference(point.dateFrom).inMinutes;
              if (durationMins > 0) {
                fetchedDeepSleepMinutes = (fetchedDeepSleepMinutes ?? 0) + durationMins;
              }
            }
          }
        } catch (e) {
          debugPrint('Health data points query error: $e');
        }
      }
    } catch (e) {
      debugPrint('Mobile health fetch exception: $e');
    }

    // 2. Hardware Pedometer Fallback if steps were not returned by Health Connect
    if (fetchedSteps == null || fetchedSteps == 0) {
      if (_currentSensorSteps > 0) {
        fetchedSteps = _currentSensorSteps;
        sourceName = 'Mobile Pedometer Sensor';
      }
    }

    final hasData = fetchedSteps != null ||
        fetchedHeartRate != null ||
        fetchedSleepMinutes != null ||
        fetchedCalories != null;

    return MobileHealthSyncResult(
      success: true,
      source: sourceName,
      steps: fetchedSteps,
      restingHeartRate: fetchedHeartRate,
      sleepDurationMinutes: fetchedSleepMinutes,
      deepSleepMinutes: fetchedDeepSleepMinutes,
      activeCalories: fetchedCalories,
      systolicBP: fetchedSys,
      diastolicBP: fetchedDia,
      spO2: fetchedSpO2,
      temperature: fetchedTemp,
      message: hasData
          ? 'Successfully captured real mobile data from $sourceName.'
          : 'Connected to $sourceName. Awaiting sensor activity points.',
    );
  }

  /// Initialize real-time continuous hardware pedometer sensor stream
  static void startLivePedometerTracking({
    required void Function(int deltaSteps, String status) onStepUpdate,
  }) {
    if (!isMobilePlatform) return;

    _stepSubscription?.cancel();
    _statusSubscription?.cancel();

    try {
      // Pedestrian status (walking/stopped)
      _statusSubscription = Pedometer.pedestrianStatusStream.listen(
        (status) {
          _currentPedestrianStatus = status.status;
          onStepUpdate(_currentSensorSteps, _currentPedestrianStatus);
        },
        onError: (err) => debugPrint('Pedestrian status error: $err'),
      );

      // Hardware step counter sensor
      _stepSubscription = Pedometer.stepCountStream.listen(
        (event) {
          final totalDeviceSteps = event.steps;

          // Initialize base on first reading of current device session
          if (_initialPedometerBase < 0) {
            _initialPedometerBase = totalDeviceSteps;
          }

          final sessionDelta = totalDeviceSteps - _initialPedometerBase;
          _currentSensorSteps = sessionDelta > 0 ? sessionDelta : 0;

          onStepUpdate(_currentSensorSteps, _currentPedestrianStatus);
        },
        onError: (err) => debugPrint('Pedometer sensor stream error: $err'),
      );
    } catch (e) {
      debugPrint('Failed to initialize pedometer hardware stream: $e');
    }
  }

  static void dispose() {
    _stepSubscription?.cancel();
    _statusSubscription?.cancel();
  }
}

