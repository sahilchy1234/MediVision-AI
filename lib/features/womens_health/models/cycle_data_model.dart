import 'package:flutter/material.dart';

enum CyclePhase {
  menstrual,
  follicular,
  ovulatory,
  luteal;

  String get label {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Menstrual Phase';
      case CyclePhase.follicular:
        return 'Follicular Phase';
      case CyclePhase.ovulatory:
        return 'Ovulatory Phase';
      case CyclePhase.luteal:
        return 'Luteal Phase';
    }
  }

  String get description {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Uterine lining is shedding. Energy may be lower; focus on hydration and gentle rest.';
      case CyclePhase.follicular:
        return 'Estrogen levels are rising, boosting stamina, cognitive sharpness, and mood.';
      case CyclePhase.ovulatory:
        return 'Peak fertility window with LH surge. High energy, heightened libido, and peak cervical mucus.';
      case CyclePhase.luteal:
        return 'Progesterone dominates. Body temperature rises; PMS, cravings, or mood changes may occur.';
    }
  }

  Color get color {
    switch (this) {
      case CyclePhase.menstrual:
        return const Color(0xFFF43F5E); // Rose Red
      case CyclePhase.follicular:
        return const Color(0xFF0D9488); // Teal
      case CyclePhase.ovulatory:
        return const Color(0xFF8B5CF6); // Purple
      case CyclePhase.luteal:
        return const Color(0xFFF59E0B); // Amber
    }
  }

  static CyclePhase fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'menstrual':
        return CyclePhase.menstrual;
      case 'ovulatory':
        return CyclePhase.ovulatory;
      case 'luteal':
        return CyclePhase.luteal;
      case 'follicular':
      default:
        return CyclePhase.follicular;
    }
  }
}

enum PeriodFlow {
  none,
  spotting,
  light,
  medium,
  heavy;

  String get label {
    switch (this) {
      case PeriodFlow.none:
        return 'No Flow';
      case PeriodFlow.spotting:
        return 'Spotting';
      case PeriodFlow.light:
        return 'Light';
      case PeriodFlow.medium:
        return 'Medium';
      case PeriodFlow.heavy:
        return 'Heavy';
    }
  }

  static PeriodFlow fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'spotting':
        return PeriodFlow.spotting;
      case 'light':
        return PeriodFlow.light;
      case 'medium':
        return PeriodFlow.medium;
      case 'heavy':
        return PeriodFlow.heavy;
      case 'none':
      default:
        return PeriodFlow.none;
    }
  }
}

class PastCycleHistory {
  final DateTime startDate;
  final int lengthInDays;
  final int periodDurationDays;
  final bool isIrregular;

  const PastCycleHistory({
    required this.startDate,
    required this.lengthInDays,
    required this.periodDurationDays,
    this.isIrregular = false,
  });

  Map<String, dynamic> toJson() => {
        'startDate': startDate.toIso8601String(),
        'lengthInDays': lengthInDays,
        'periodDurationDays': periodDurationDays,
        'isIrregular': isIrregular,
      };

  factory PastCycleHistory.fromJson(Map<String, dynamic> json) {
    return PastCycleHistory(
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      lengthInDays: (json['lengthInDays'] as num?)?.toInt() ?? 28,
      periodDurationDays: (json['periodDurationDays'] as num?)?.toInt() ?? 5,
      isIrregular: json['isIrregular'] as bool? ?? false,
    );
  }
}

class CycleDataModel {
  final int currentDayOfCycle; // e.g. 14
  final int averageCycleLength; // e.g. 28 days
  final int averagePeriodDuration; // e.g. 5 days
  final DateTime lastPeriodStartDate;
  final CyclePhase currentPhase;
  final bool isFertileWindow;
  final int daysUntilNextPeriod;
  final List<PastCycleHistory> history;
  final double cycleVariationDays; // Standard deviation of cycle lengths

  const CycleDataModel({
    required this.currentDayOfCycle,
    required this.averageCycleLength,
    required this.averagePeriodDuration,
    required this.lastPeriodStartDate,
    required this.currentPhase,
    required this.isFertileWindow,
    required this.daysUntilNextPeriod,
    required this.history,
    this.cycleVariationDays = 2.4,
  });

  DateTime get predictedNextPeriod =>
      lastPeriodStartDate.add(Duration(days: averageCycleLength));

  bool get isPeriodActive => currentDayOfCycle <= averagePeriodDuration;

  CycleDataModel copyWith({
    int? currentDayOfCycle,
    int? averageCycleLength,
    int? averagePeriodDuration,
    DateTime? lastPeriodStartDate,
    CyclePhase? currentPhase,
    bool? isFertileWindow,
    int? daysUntilNextPeriod,
    List<PastCycleHistory>? history,
    double? cycleVariationDays,
  }) {
    return CycleDataModel(
      currentDayOfCycle: currentDayOfCycle ?? this.currentDayOfCycle,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodDuration: averagePeriodDuration ?? this.averagePeriodDuration,
      lastPeriodStartDate: lastPeriodStartDate ?? this.lastPeriodStartDate,
      currentPhase: currentPhase ?? this.currentPhase,
      isFertileWindow: isFertileWindow ?? this.isFertileWindow,
      daysUntilNextPeriod: daysUntilNextPeriod ?? this.daysUntilNextPeriod,
      history: history ?? this.history,
      cycleVariationDays: cycleVariationDays ?? this.cycleVariationDays,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentDayOfCycle': currentDayOfCycle,
        'averageCycleLength': averageCycleLength,
        'averagePeriodDuration': averagePeriodDuration,
        'lastPeriodStartDate': lastPeriodStartDate.toIso8601String(),
        'currentPhase': currentPhase.name,
        'isFertileWindow': isFertileWindow,
        'daysUntilNextPeriod': daysUntilNextPeriod,
        'cycleVariationDays': cycleVariationDays,
        'history': history.map((h) => h.toJson()).toList(),
      };

  factory CycleDataModel.fromJson(Map<String, dynamic> json) {
    final start = DateTime.tryParse(json['lastPeriodStartDate']?.toString() ?? '') ??
        DateTime.now().subtract(const Duration(days: 13));
    final avgLength = (json['averageCycleLength'] as num?)?.toInt() ?? 28;
    final avgDuration = (json['averagePeriodDuration'] as num?)?.toInt() ?? 5;

    // Dynamically calculate current day of cycle and phase based on real now
    final now = DateTime.now();
    final dayOfCycle = (json['currentDayOfCycle'] != null)
        ? (json['currentDayOfCycle'] as num).toInt()
        : (now.difference(start).inDays + 1).clamp(1, 99);
    final daysUntilNext = (json['daysUntilNextPeriod'] != null)
        ? (json['daysUntilNextPeriod'] as num).toInt()
        : (avgLength - dayOfCycle).clamp(0, avgLength);

    CyclePhase phase;
    if (json['currentPhase'] != null) {
      phase = CyclePhase.fromString(json['currentPhase']?.toString());
    } else {
      if (dayOfCycle <= avgDuration) {
        phase = CyclePhase.menstrual;
      } else if (dayOfCycle < 12) {
        phase = CyclePhase.follicular;
      } else if (dayOfCycle <= 16) {
        phase = CyclePhase.ovulatory;
      } else {
        phase = CyclePhase.luteal;
      }
    }

    final rawHistory = json['history'] as List<dynamic>? ?? [];
    final history = rawHistory
        .map((h) => PastCycleHistory.fromJson(h as Map<String, dynamic>))
        .toList();

    return CycleDataModel(
      currentDayOfCycle: dayOfCycle,
      averageCycleLength: avgLength,
      averagePeriodDuration: avgDuration,
      lastPeriodStartDate: start,
      currentPhase: phase,
      isFertileWindow: json['isFertileWindow'] as bool? ?? (dayOfCycle >= 10 && dayOfCycle <= 16),
      daysUntilNextPeriod: daysUntilNext,
      history: history,
      cycleVariationDays: (json['cycleVariationDays'] as num?)?.toDouble() ?? 2.1,
    );
  }

  static CycleDataModel fromRealDates({
    required DateTime lastPeriodStartDate,
    int averageCycleLength = 28,
    int averagePeriodDuration = 5,
    List<PastCycleHistory> history = const [],
    double cycleVariationDays = 2.0,
  }) {
    final now = DateTime.now();
    final dayOfCycle = (now.difference(lastPeriodStartDate).inDays + 1).clamp(1, 99);
    final daysUntilNext = (averageCycleLength - dayOfCycle).clamp(0, averageCycleLength);

    CyclePhase phase;
    if (dayOfCycle <= averagePeriodDuration) {
      phase = CyclePhase.menstrual;
    } else if (dayOfCycle < 12) {
      phase = CyclePhase.follicular;
    } else if (dayOfCycle <= 16) {
      phase = CyclePhase.ovulatory;
    } else {
      phase = CyclePhase.luteal;
    }

    return CycleDataModel(
      currentDayOfCycle: dayOfCycle,
      averageCycleLength: averageCycleLength,
      averagePeriodDuration: averagePeriodDuration,
      lastPeriodStartDate: lastPeriodStartDate,
      currentPhase: phase,
      isFertileWindow: dayOfCycle >= 10 && dayOfCycle <= 16,
      daysUntilNextPeriod: daysUntilNext,
      history: history,
      cycleVariationDays: cycleVariationDays,
    );
  }
}
