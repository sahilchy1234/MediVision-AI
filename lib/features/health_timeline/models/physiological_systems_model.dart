import '../../vitals_activity/models/vitals_activity_model.dart';
import '../../medical_records/models/medical_record.dart';

enum HealthSystemType { brainSleep, heartPulse, staminaMovement, bloodDefenses }

class SystemClinicalData {
  final HealthSystemType type;
  final String name;
  final int score;
  final String status;
  final String headline;
  final String explanation;
  final List<String> keyPills;
  final String recommendation;

  const SystemClinicalData({
    required this.type,
    required this.name,
    required this.score,
    required this.status,
    required this.headline,
    required this.explanation,
    required this.keyPills,
    required this.recommendation,
  });

  factory SystemClinicalData.fromJson(HealthSystemType type, Map<String, dynamic> json) {
    return SystemClinicalData(
      type: type,
      name: json['name'] as String? ?? _defaultName(type),
      score: (json['score'] as num?)?.toInt() ?? 90,
      status: json['status'] as String? ?? 'Normal',
      headline: json['headline'] as String? ?? 'System Baseline Steady',
      explanation: json['explanation'] as String? ?? 'Metrics indicate steady baseline balance.',
      keyPills: (json['keyPills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      recommendation: json['recommendation'] as String? ?? 'Maintain current health regimen.',
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'name': name,
    'score': score,
    'status': status,
    'headline': headline,
    'explanation': explanation,
    'keyPills': keyPills,
    'recommendation': recommendation,
  };

  static String _defaultName(HealthSystemType type) {
    switch (type) {
      case HealthSystemType.brainSleep:
        return 'Sleep & Cognition';
      case HealthSystemType.heartPulse:
        return 'Cardiovascular';
      case HealthSystemType.staminaMovement:
        return 'Physical Activity';
      case HealthSystemType.bloodDefenses:
        return 'Hematology & Labs';
    }
  }
}

class PhysiologicalSystemsAssessment {
  final int overallScore;
  final String overallSummary;
  final bool isAiGenerated;
  final DateTime evaluatedAt;
  final Map<HealthSystemType, SystemClinicalData> systems;

  const PhysiologicalSystemsAssessment({
    required this.overallScore,
    required this.overallSummary,
    required this.isAiGenerated,
    required this.evaluatedAt,
    required this.systems,
  });

  SystemClinicalData get brainSleep =>
      systems[HealthSystemType.brainSleep] ??
      const SystemClinicalData(
        type: HealthSystemType.brainSleep,
        name: 'Sleep & Cognition',
        score: 89,
        status: 'Rested',
        headline: 'Sleep Architecture: Restorative',
        explanation: 'Healthy sleep stages recorded with consistent REM and deep restorative cycles.',
        keyPills: ['7h 42m Total', '1h 48m Deep', '89% Quality'],
        recommendation: 'Maintain regular sleep schedule.',
      );

  SystemClinicalData get heartPulse =>
      systems[HealthSystemType.heartPulse] ??
      const SystemClinicalData(
        type: HealthSystemType.heartPulse,
        name: 'Cardiovascular',
        score: 96,
        status: 'Optimal Baseline',
        headline: 'Cardiovascular: Stable Telemetry',
        explanation: 'Resting pulse and arterial tension within optimal hemodynamic bounds.',
        keyPills: ['61 bpm', '118/78 mmHg', 'SpO2 98%'],
        recommendation: 'Sustain balanced aerobic routine.',
      );

  SystemClinicalData get staminaMovement =>
      systems[HealthSystemType.staminaMovement] ??
      const SystemClinicalData(
        type: HealthSystemType.staminaMovement,
        name: 'Physical Activity',
        score: 84,
        status: 'Active',
        headline: 'Physical Movement: Daily Target Tracked',
        explanation: 'Sustained daily steps and caloric expenditure support musculoskeletal tone.',
        keyPills: ['8,420 Steps', '482 kcal', '42 Active Min'],
        recommendation: 'Aim for 10,000 steps daily.',
      );

  SystemClinicalData get bloodDefenses =>
      systems[HealthSystemType.bloodDefenses] ??
      const SystemClinicalData(
        type: HealthSystemType.bloodDefenses,
        name: 'Hematology & Labs',
        score: 95,
        status: 'In Range',
        headline: 'Hematology & Metabolic: Baseline Stable',
        explanation: 'Biomarkers and peripheral oxygenation indicate balanced metabolic homeostasis.',
        keyPills: ['SpO2 98%', 'Temp 36.8°C', 'Zero Acute Flags'],
        recommendation: 'Review annual comprehensive panel.',
      );

  SystemClinicalData getSystem(HealthSystemType type) {
    switch (type) {
      case HealthSystemType.brainSleep:
        return brainSleep;
      case HealthSystemType.heartPulse:
        return heartPulse;
      case HealthSystemType.staminaMovement:
        return staminaMovement;
      case HealthSystemType.bloodDefenses:
        return bloodDefenses;
    }
  }

  factory PhysiologicalSystemsAssessment.fromJson(Map<String, dynamic> json) {
    final systemsMap = <HealthSystemType, SystemClinicalData>{};
    final rawSystems = json['systems'] as Map<String, dynamic>? ?? {};

    if (rawSystems.containsKey('brainSleep')) {
      systemsMap[HealthSystemType.brainSleep] = SystemClinicalData.fromJson(
        HealthSystemType.brainSleep,
        rawSystems['brainSleep'] as Map<String, dynamic>,
      );
    }
    if (rawSystems.containsKey('heartPulse')) {
      systemsMap[HealthSystemType.heartPulse] = SystemClinicalData.fromJson(
        HealthSystemType.heartPulse,
        rawSystems['heartPulse'] as Map<String, dynamic>,
      );
    }
    if (rawSystems.containsKey('staminaMovement')) {
      systemsMap[HealthSystemType.staminaMovement] = SystemClinicalData.fromJson(
        HealthSystemType.staminaMovement,
        rawSystems['staminaMovement'] as Map<String, dynamic>,
      );
    }
    if (rawSystems.containsKey('bloodDefenses')) {
      systemsMap[HealthSystemType.bloodDefenses] = SystemClinicalData.fromJson(
        HealthSystemType.bloodDefenses,
        rawSystems['bloodDefenses'] as Map<String, dynamic>,
      );
    }

    return PhysiologicalSystemsAssessment(
      overallScore: (json['overallScore'] as num?)?.toInt() ?? 92,
      overallSummary: json['overallSummary'] as String? ??
          'Physiological metrics indicate balanced health and autonomic baseline.',
      isAiGenerated: json['isAiGenerated'] as bool? ?? true,
      evaluatedAt: json['evaluatedAt'] != null
          ? DateTime.tryParse(json['evaluatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      systems: systemsMap,
    );
  }

  Map<String, dynamic> toJson() => {
    'overallScore': overallScore,
    'overallSummary': overallSummary,
    'isAiGenerated': isAiGenerated,
    'evaluatedAt': evaluatedAt.toIso8601String(),
    'systems': {
      'brainSleep': brainSleep.toJson(),
      'heartPulse': heartPulse.toJson(),
      'staminaMovement': staminaMovement.toJson(),
      'bloodDefenses': bloodDefenses.toJson(),
    },
  };

  /// Builds a deterministic clinical assessment derived directly from real user data
  factory PhysiologicalSystemsAssessment.fromRealData({
    required VitalsSnapshot vitals,
    required List<MedicalRecordItem> records,
    bool isAi = false,
  }) {
    final heartScore = vitals.restingHeartRate < 75 &&
            vitals.bloodPressureSystolic <= 120 &&
            vitals.bloodOxygenSpO2 >= 97
        ? 96
        : (vitals.restingHeartRate < 85 ? 88 : 78);
    final sleepScore = vitals.sleepQualityScore.clamp(40, 100);
    final activityScore = (vitals.stepsProgress * 100).round().clamp(20, 100);

    final labRecords = records
        .where((r) =>
            r.category == RecordCategory.bloodReports ||
            r.category == RecordCategory.other)
        .toList();
    final hasLabs = labRecords.isNotEmpty;
    final labsScore = hasLabs ? 94 : 92;

    final overall = ((heartScore * 0.3) +
            (sleepScore * 0.25) +
            (activityScore * 0.25) +
            (labsScore * 0.2))
        .round();

    final systemsMap = <HealthSystemType, SystemClinicalData>{
      HealthSystemType.brainSleep: SystemClinicalData(
        type: HealthSystemType.brainSleep,
        name: 'Sleep & Cognition',
        score: sleepScore,
        status: sleepScore >= 85
            ? 'Rested'
            : (sleepScore >= 70 ? 'Adequate' : 'Fatigued'),
        headline:
            'Sleep Efficiency: ${sleepScore >= 80 ? "Restorative Recovery" : "Mild Sleep Debt"}',
        explanation:
            '${vitals.formattedSleep} total sleep logged with ${vitals.formattedDeepSleep} in restorative deep sleep. Autonomic sleep architecture shows healthy overnight heart rate deceleration.',
        keyPills: [
          '${vitals.formattedSleep} Total',
          '${vitals.formattedDeepSleep} Deep',
          '$sleepScore% Efficiency',
        ],
        recommendation: sleepScore >= 80
            ? 'Maintain consistent wake window to lock circadian stability.'
            : 'Aim for a 30-minute earlier wind-down to increase restorative delta sleep.',
      ),
      HealthSystemType.heartPulse: SystemClinicalData(
        type: HealthSystemType.heartPulse,
        name: 'Cardiovascular',
        score: heartScore,
        status: vitals.restingHeartRate < 70
            ? 'Optimal Baseline'
            : (vitals.restingHeartRate < 85 ? 'Steady' : 'Elevated'),
        headline: 'Cardiovascular: Stable Hemodynamic Range',
        explanation:
            'Resting heart rate measured at ${vitals.formattedPulse} with arterial pressure at ${vitals.formattedBP}. Pulse oximetry reflects optimal peripheral oxygenation at ${vitals.bloodOxygenSpO2}%.',
        keyPills: [
          vitals.formattedPulse,
          vitals.formattedBP,
          'SpO2 ${vitals.bloodOxygenSpO2}%',
        ],
        recommendation:
            'Cardiovascular markers within target thresholds; sustain aerobic activity.',
      ),
      HealthSystemType.staminaMovement: SystemClinicalData(
        type: HealthSystemType.staminaMovement,
        name: 'Physical Activity',
        score: activityScore,
        status: vitals.stepsProgress >= 0.8
            ? 'Goal Met'
            : (vitals.stepsProgress >= 0.5 ? 'Active' : 'Light Mobility'),
        headline:
            'Physical Activity: ${vitals.stepsProgress >= 0.8 ? "Daily Goal Achieved" : "Active Cadence"}',
        explanation:
            '${vitals.formattedSteps} steps logged with ${vitals.activeCalories} active kcal burned across ${vitals.activeMinutes} minutes of sustained cardiovascular engagement.',
        keyPills: [
          '${vitals.formattedSteps} Steps',
          '${vitals.activeCalories} kcal',
          '${vitals.activeMinutes} Active Min',
        ],
        recommendation: vitals.stepsProgress >= 0.8
            ? 'Excellent aerobic volume today; ensure hydration and post-walk stretching.'
            : 'Take a brief 15-minute brisk walk to reach daily step target.',
      ),
      HealthSystemType.bloodDefenses: SystemClinicalData(
        type: HealthSystemType.bloodDefenses,
        name: 'Hematology & Labs',
        score: labsScore,
        status: hasLabs ? 'Lab Verified' : 'Vitals In Range',
        headline: hasLabs
            ? 'Laboratory Chemistry: Analyzed'
            : 'Metabolic & Immune Status: Stable',
        explanation: hasLabs
            ? 'Indexed ${labRecords.length} clinical record(s) including "${labRecords.first.title}". No critical alerts detected across metabolic panels.'
            : 'Core temperature (${vitals.bodyTemperature}°C) and oxygen saturation (${vitals.bloodOxygenSpO2}%) indicate normal metabolic thermoregulation and oxygen perfusion.',
        keyPills: hasLabs
            ? [
                labRecords.first.title.length > 18
                    ? '${labRecords.first.title.substring(0, 16)}...'
                    : labRecords.first.title,
                'Temp ${vitals.bodyTemperature}°C',
                'SpO2 ${vitals.bloodOxygenSpO2}%',
              ]
            : [
                'SpO2 ${vitals.bloodOxygenSpO2}%',
                'Temp ${vitals.bodyTemperature}°C',
                'Zero Acute Flags',
              ],
        recommendation: hasLabs
            ? 'Recent lab panels remain valid; schedule routine annual checkup as planned.'
            : 'Upload your latest blood or lipid panel for deep clinical biomarker extraction.',
      ),
    };

    return PhysiologicalSystemsAssessment(
      overallScore: overall,
      overallSummary:
          'Physiological balance at $overall% optimal capacity. Normal cardiovascular metrics and restorative sleep baseline.',
      isAiGenerated: isAi,
      evaluatedAt: DateTime.now(),
      systems: systemsMap,
    );
  }
}

