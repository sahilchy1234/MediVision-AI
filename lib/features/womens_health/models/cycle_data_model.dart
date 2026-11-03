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
}

class CycleDataModel {
  final int currentDayOfCycle; // e.g. 14
  final int averageCycleLength; // e.g. 29 days
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

  static CycleDataModel defaultSample() {
    final now = DateTime.now();
    return CycleDataModel(
      currentDayOfCycle: 14,
      averageCycleLength: 29,
      averagePeriodDuration: 5,
      lastPeriodStartDate: now.subtract(const Duration(days: 13)),
      currentPhase: CyclePhase.ovulatory,
      isFertileWindow: true,
      daysUntilNextPeriod: 15,
      cycleVariationDays: 3.1,
      history: [
        PastCycleHistory(
          startDate: now.subtract(const Duration(days: 13 + 29)),
          lengthInDays: 29,
          periodDurationDays: 5,
        ),
        PastCycleHistory(
          startDate: now.subtract(const Duration(days: 13 + 29 + 31)),
          lengthInDays: 31,
          periodDurationDays: 6,
          isIrregular: true,
        ),
        PastCycleHistory(
          startDate: now.subtract(const Duration(days: 13 + 29 + 31 + 28)),
          lengthInDays: 28,
          periodDurationDays: 5,
        ),
      ],
    );
  }
}
