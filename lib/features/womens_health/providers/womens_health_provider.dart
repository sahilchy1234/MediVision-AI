import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/condition_assessment_model.dart';
import '../models/cycle_data_model.dart';
import '../models/gynecologist_summary_model.dart';
import '../models/symptom_log_model.dart';

class WomensHealthState {
  final CycleDataModel cycleData;
  final List<DailySymptomLog> symptomLogs;
  final List<ConditionAssessment> assessments;
  final bool isPrivateVaultLocked;
  final bool isBiometricsRequired;

  const WomensHealthState({
    required this.cycleData,
    required this.symptomLogs,
    required this.assessments,
    this.isPrivateVaultLocked = false,
    this.isBiometricsRequired = true,
  });

  WomensHealthState copyWith({
    CycleDataModel? cycleData,
    List<DailySymptomLog>? symptomLogs,
    List<ConditionAssessment>? assessments,
    bool? isPrivateVaultLocked,
    bool? isBiometricsRequired,
  }) {
    return WomensHealthState(
      cycleData: cycleData ?? this.cycleData,
      symptomLogs: symptomLogs ?? this.symptomLogs,
      assessments: assessments ?? this.assessments,
      isPrivateVaultLocked: isPrivateVaultLocked ?? this.isPrivateVaultLocked,
      isBiometricsRequired: isBiometricsRequired ?? this.isBiometricsRequired,
    );
  }
}

class WomensHealthNotifier extends StateNotifier<WomensHealthState> {
  WomensHealthNotifier()
      : super(
          WomensHealthState(
            cycleData: CycleDataModel.defaultSample(),
            symptomLogs: DailySymptomLog.defaultSampleLogs(),
            assessments: ConditionAssessment.getInitialAssessments(),
            isPrivateVaultLocked: false,
          ),
        );

  void logDailySymptoms(DailySymptomLog log) {
    state = state.copyWith(
      symptomLogs: [log, ...state.symptomLogs.where((l) => l.date.day != log.date.day || l.date.month != log.date.month)],
    );
    _recalculateAssessments();
  }

  void updateCycleDetails({
    required int averageCycleLength,
    required int averagePeriodDuration,
    required DateTime lastPeriodStartDate,
  }) {
    final now = DateTime.now();
    final dayOfCycle = now.difference(lastPeriodStartDate).inDays + 1;
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

    state = state.copyWith(
      cycleData: CycleDataModel(
        currentDayOfCycle: dayOfCycle.clamp(1, 99),
        averageCycleLength: averageCycleLength,
        averagePeriodDuration: averagePeriodDuration,
        lastPeriodStartDate: lastPeriodStartDate,
        currentPhase: phase,
        isFertileWindow: dayOfCycle >= 10 && dayOfCycle <= 16,
        daysUntilNextPeriod: daysUntilNext,
        history: state.cycleData.history,
      ),
    );
  }

  void _recalculateAssessments() {
    // Dynamic rule evaluation based on logged symptoms
    final hasSevereCramps = state.symptomLogs.any((l) => l.crampsSeverity >= 4);
    final hasPcosMarkers = state.symptomLogs.any((l) => l.pcosObservations.isNotEmpty);

    state = state.copyWith(
      assessments: state.assessments.map((assessment) {
        if (assessment.id == 'endometriosis' && hasSevereCramps) {
          return assessment; // Already flagged
        }
        if (assessment.id == 'pcos_pcod' && hasPcosMarkers) {
          return assessment;
        }
        return assessment;
      }).toList(),
    );
  }

  void togglePrivateVaultLock() {
    state = state.copyWith(isPrivateVaultLocked: !state.isPrivateVaultLocked);
  }

  GynecologistSummary generateDoctorSummary(String patientName) {
    return GynecologistSummary(
      patientName: patientName,
      generatedDate: DateTime.now(),
      cycleData: state.cycleData,
      recentLogs: state.symptomLogs,
      assessments: state.assessments,
      isPrivateEncrypted: true,
    );
  }
}

final womensHealthProvider =
    StateNotifierProvider<WomensHealthNotifier, WomensHealthState>((ref) {
  return WomensHealthNotifier();
});
