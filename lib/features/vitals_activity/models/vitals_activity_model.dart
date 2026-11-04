import 'package:intl/intl.dart';

class VitalsSnapshot {
  final int steps;
  final int stepGoal;
  final int activeMinutes;
  final int activeCalories;
  final int restingHeartRate;
  final int bloodPressureSystolic;
  final int bloodPressureDiastolic;
  final int bloodOxygenSpO2;
  final double bodyTemperature;
  final int sleepDurationMinutes; // e.g. 462 = 7h 42m
  final int deepSleepMinutes;     // e.g. 108 = 1h 48m
  final int sleepQualityScore;    // 0-100
  final int screenTimeMinutes;    // e.g. 195 = 3h 15m
  final int screenPickups;
  final DateTime lastUpdated;

  const VitalsSnapshot({
    this.steps = 8420,
    this.stepGoal = 10000,
    this.activeMinutes = 42,
    this.activeCalories = 482,
    this.restingHeartRate = 61,
    this.bloodPressureSystolic = 118,
    this.bloodPressureDiastolic = 78,
    this.bloodOxygenSpO2 = 98,
    this.bodyTemperature = 36.8,
    this.sleepDurationMinutes = 462,
    this.deepSleepMinutes = 108,
    this.sleepQualityScore = 89,
    this.screenTimeMinutes = 195,
    this.screenPickups = 48,
    required this.lastUpdated,
  });

  // --- Display Formatters ---
  String get formattedSteps => NumberFormat('#,###').format(steps);
  double get stepsProgress => (steps / (stepGoal > 0 ? stepGoal : 10000)).clamp(0.0, 1.0);
  String get stepsSubtitle => '${(stepsProgress * 100).toInt()}% of daily goal';

  String get formattedPulse => '$restingHeartRate bpm';
  double get pulseProgress {
    // 40 bpm -> 0.0, 100 bpm -> 1.0
    return ((restingHeartRate - 40) / 60.0).clamp(0.1, 1.0);
  }
  String get pulseSubtitle {
    if (restingHeartRate < 60) return 'Optimal resting baseline';
    if (restingHeartRate <= 80) return 'Healthy aerobic range';
    if (restingHeartRate <= 100) return 'Normal resting pulse';
    return 'Elevated heart rate';
  }

  String get formattedSleep {
    final hours = sleepDurationMinutes ~/ 60;
    final minutes = sleepDurationMinutes % 60;
    return '${hours}h ${minutes}m';
  }
  String get formattedDeepSleep {
    final hours = deepSleepMinutes ~/ 60;
    final minutes = deepSleepMinutes % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }
  String get sleepSubtitle => '$formattedDeepSleep Deep sleep';
  double get sleepProgress => (sleepDurationMinutes / 480.0).clamp(0.0, 1.0); // 8 hours target

  String get formattedScreenTime {
    final hours = screenTimeMinutes ~/ 60;
    final minutes = screenTimeMinutes % 60;
    return '${hours}h ${minutes}m';
  }
  String get screenTimeSubtitle {
    if (screenTimeMinutes < 180) return 'Optimal digital balance';
    if (screenTimeMinutes < 240) return 'Moderate screen usage';
    return 'High device engagement';
  }
  double get screenTimeProgress => (screenTimeMinutes / 360.0).clamp(0.0, 1.0); // 6 hours scale

  String get formattedBP => '$bloodPressureSystolic/$bloodPressureDiastolic mmHg';

  /// Clinical health score calculation derived from real vitals
  int get computedHealthScore {
    double score = 100.0;

    // 1. Cardiovascular deduction (Resting HR ideal: 55-75)
    if (restingHeartRate < 50 || restingHeartRate > 85) {
      score -= ((restingHeartRate - 70).abs() * 0.3);
    }
    // 2. Blood Pressure ideal: <120 / <80
    if (bloodPressureSystolic > 125) {
      score -= (bloodPressureSystolic - 120) * 0.2;
    }
    // 3. SpO2 ideal: >= 97%
    if (bloodOxygenSpO2 < 97) {
      score -= (97 - bloodOxygenSpO2) * 2.5;
    }
    // 4. Activity deduction (based on step progress)
    if (stepsProgress < 0.7) {
      score -= (0.7 - stepsProgress) * 15;
    }
    // 5. Sleep deduction (ideal: 7-9 hours)
    if (sleepDurationMinutes < 420) {
      score -= ((420 - sleepDurationMinutes) / 60) * 4;
    }

    return score.round().clamp(65, 99);
  }

  VitalsSnapshot copyWith({
    int? steps,
    int? stepGoal,
    int? activeMinutes,
    int? activeCalories,
    int? restingHeartRate,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? bloodOxygenSpO2,
    double? bodyTemperature,
    int? sleepDurationMinutes,
    int? deepSleepMinutes,
    int? sleepQualityScore,
    int? screenTimeMinutes,
    int? screenPickups,
    DateTime? lastUpdated,
  }) {
    return VitalsSnapshot(
      steps: steps ?? this.steps,
      stepGoal: stepGoal ?? this.stepGoal,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      activeCalories: activeCalories ?? this.activeCalories,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      bloodPressureSystolic: bloodPressureSystolic ?? this.bloodPressureSystolic,
      bloodPressureDiastolic: bloodPressureDiastolic ?? this.bloodPressureDiastolic,
      bloodOxygenSpO2: bloodOxygenSpO2 ?? this.bloodOxygenSpO2,
      bodyTemperature: bodyTemperature ?? this.bodyTemperature,
      sleepDurationMinutes: sleepDurationMinutes ?? this.sleepDurationMinutes,
      deepSleepMinutes: deepSleepMinutes ?? this.deepSleepMinutes,
      sleepQualityScore: sleepQualityScore ?? this.sleepQualityScore,
      screenTimeMinutes: screenTimeMinutes ?? this.screenTimeMinutes,
      screenPickups: screenPickups ?? this.screenPickups,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'stepGoal': stepGoal,
      'activeMinutes': activeMinutes,
      'activeCalories': activeCalories,
      'restingHeartRate': restingHeartRate,
      'bloodPressureSystolic': bloodPressureSystolic,
      'bloodPressureDiastolic': bloodPressureDiastolic,
      'bloodOxygenSpO2': bloodOxygenSpO2,
      'bodyTemperature': bodyTemperature,
      'sleepDurationMinutes': sleepDurationMinutes,
      'deepSleepMinutes': deepSleepMinutes,
      'sleepQualityScore': sleepQualityScore,
      'screenTimeMinutes': screenTimeMinutes,
      'screenPickups': screenPickups,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory VitalsSnapshot.fromJson(Map<String, dynamic> json) {
    return VitalsSnapshot(
      steps: json['steps'] as int? ?? 8420,
      stepGoal: json['stepGoal'] as int? ?? 10000,
      activeMinutes: json['activeMinutes'] as int? ?? 42,
      activeCalories: json['activeCalories'] as int? ?? 482,
      restingHeartRate: json['restingHeartRate'] as int? ?? 61,
      bloodPressureSystolic: json['bloodPressureSystolic'] as int? ?? 118,
      bloodPressureDiastolic: json['bloodPressureDiastolic'] as int? ?? 78,
      bloodOxygenSpO2: json['bloodOxygenSpO2'] as int? ?? 98,
      bodyTemperature: (json['bodyTemperature'] as num?)?.toDouble() ?? 36.8,
      sleepDurationMinutes: json['sleepDurationMinutes'] as int? ?? 462,
      deepSleepMinutes: json['deepSleepMinutes'] as int? ?? 108,
      sleepQualityScore: json['sleepQualityScore'] as int? ?? 89,
      screenTimeMinutes: json['screenTimeMinutes'] as int? ?? 195,
      screenPickups: json['screenPickups'] as int? ?? 48,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static VitalsSnapshot createInitial() {
    return VitalsSnapshot(lastUpdated: DateTime.now());
  }
}

class ActivitySession {
  final String id;
  final String type; // Walking, Running, Cycling, Workout
  final DateTime startTime;
  final int durationMinutes;
  final int steps;
  final int calories;
  final double distanceKm;
  final int avgHeartRate;
  final String notes;

  const ActivitySession({
    required this.id,
    required this.type,
    required this.startTime,
    required this.durationMinutes,
    required this.steps,
    required this.calories,
    required this.distanceKm,
    this.avgHeartRate = 0,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'startTime': startTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'steps': steps,
      'calories': calories,
      'distanceKm': distanceKm,
      'avgHeartRate': avgHeartRate,
      'notes': notes,
    };
  }

  factory ActivitySession.fromJson(Map<String, dynamic> json) {
    return ActivitySession(
      id: json['id'] as String? ?? 'act_${DateTime.now().millisecondsSinceEpoch}',
      type: json['type'] as String? ?? 'Walking',
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      steps: json['steps'] as int? ?? 0,
      calories: json['calories'] as int? ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      avgHeartRate: json['avgHeartRate'] as int? ?? 0,
      notes: json['notes'] as String? ?? '',
    );
  }
}

class VitalLogEntry {
  final String id;
  final String category; // pulse, bp, spo2, sleep, steps, activity, temperature, screentime
  final String label;
  final String value;
  final String unit;
  final DateTime timestamp;
  final String notes;

  const VitalLogEntry({
    required this.id,
    required this.category,
    required this.label,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'label': label,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory VitalLogEntry.fromJson(Map<String, dynamic> json) {
    return VitalLogEntry(
      id: json['id'] as String? ?? 'log_${DateTime.now().millisecondsSinceEpoch}',
      category: json['category'] as String? ?? 'vitals',
      label: json['label'] as String? ?? 'Vital Entry',
      value: json['value'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      notes: json['notes'] as String? ?? '',
    );
  }
}
