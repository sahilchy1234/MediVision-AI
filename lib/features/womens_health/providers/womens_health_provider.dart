import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../medical_records/providers/medical_records_provider.dart';
import '../../profile/data/models/user_profile_model.dart';
import '../../profile/providers/profile_provider.dart';
import '../data/womens_health_repository.dart';
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
  final bool isLoading;
  final bool isAnalyzing;
  final DateTime? lastAnalyzedAt;
  final String? errorMessage;

  const WomensHealthState({
    required this.cycleData,
    required this.symptomLogs,
    required this.assessments,
    this.isPrivateVaultLocked = false,
    this.isBiometricsRequired = true,
    this.isLoading = false,
    this.isAnalyzing = false,
    this.lastAnalyzedAt,
    this.errorMessage,
  });

  DailySymptomLog? get latestLog =>
      symptomLogs.isNotEmpty ? symptomLogs.first : null;

  DailySymptomLog? get todayLog {
    final now = DateTime.now();
    try {
      return symptomLogs.firstWhere(
        (l) =>
            l.date.year == now.year &&
            l.date.month == now.month &&
            l.date.day == now.day,
      );
    } catch (_) {
      return null;
    }
  }

  double? get latestBasalTemp {
    final withTemp = symptomLogs.where((l) => l.basalBodyTemp != null);
    if (withTemp.isNotEmpty) {
      return withTemp.first.basalBodyTemp;
    }
    return null;
  }

  WomensHealthState copyWith({
    CycleDataModel? cycleData,
    List<DailySymptomLog>? symptomLogs,
    List<ConditionAssessment>? assessments,
    bool? isPrivateVaultLocked,
    bool? isBiometricsRequired,
    bool? isLoading,
    bool? isAnalyzing,
    DateTime? lastAnalyzedAt,
    String? errorMessage,
  }) {
    return WomensHealthState(
      cycleData: cycleData ?? this.cycleData,
      symptomLogs: symptomLogs ?? this.symptomLogs,
      assessments: assessments ?? this.assessments,
      isPrivateVaultLocked: isPrivateVaultLocked ?? this.isPrivateVaultLocked,
      isBiometricsRequired: isBiometricsRequired ?? this.isBiometricsRequired,
      isLoading: isLoading ?? this.isLoading,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      lastAnalyzedAt: lastAnalyzedAt ?? this.lastAnalyzedAt,
      errorMessage: errorMessage,
    );
  }
}

final womensHealthRepositoryProvider = Provider<WomensHealthRepository>((ref) {
  return WomensHealthRepository();
});

class WomensHealthNotifier extends StateNotifier<WomensHealthState> {
  final Ref _ref;
  final WomensHealthRepository _repository;

  WomensHealthNotifier(this._ref, this._repository)
      : super(
          WomensHealthState(
            cycleData: CycleDataModel.fromRealDates(
              lastPeriodStartDate: DateTime.now().subtract(const Duration(days: 13)),
              averageCycleLength: 28,
              averagePeriodDuration: 5,
            ),
            symptomLogs: const [],
            assessments: const [],
            isLoading: true,
          ),
        ) {
    _initData();
  }

  Future<void> _initData() async {
    try {
      final bundle = await _repository.loadData();
      state = state.copyWith(
        cycleData: bundle.cycleData,
        symptomLogs: bundle.symptomLogs,
        assessments: bundle.assessments,
        isPrivateVaultLocked: bundle.isVaultLocked,
        lastAnalyzedAt: bundle.lastAnalyzedAt,
        isLoading: false,
      );

      // If assessments are empty, run initial evaluation
      if (bundle.assessments.isEmpty) {
        await runAiScreeningAnalysis();
      }
    } catch (e) {
      debugPrint('Error initializing womens health data: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Log daily symptoms and recalculate clinical assessments
  Future<void> logDailySymptoms(DailySymptomLog log, {bool isPeriodStart = false}) async {
    // 1. Immediately update local state
    final updatedLogs = [
      log,
      ...state.symptomLogs.where((l) =>
          l.date.year != log.date.year ||
          l.date.month != log.date.month ||
          l.date.day != log.date.day),
    ];

    CycleDataModel currentCycle = state.cycleData;

    // Check if this log marks start of new period
    if (isPeriodStart || log.flow == PeriodFlow.heavy || log.flow == PeriodFlow.medium) {
      if (log.date.isAfter(currentCycle.lastPeriodStartDate)) {
        currentCycle = CycleDataModel.fromRealDates(
          lastPeriodStartDate: log.date,
          averageCycleLength: currentCycle.averageCycleLength,
          averagePeriodDuration: currentCycle.averagePeriodDuration,
          history: currentCycle.history,
          cycleVariationDays: currentCycle.cycleVariationDays,
        );
        _repository.saveCycleData(currentCycle);
      }
    }

    state = state.copyWith(
      symptomLogs: updatedLogs,
      cycleData: currentCycle,
    );

    // 2. Persist to storage and backend
    await _repository.saveSymptomLog(log, state.symptomLogs, isPeriodStart: isPeriodStart);

    // 3. Re-evaluate clinical screening patterns
    await runAiScreeningAnalysis();
  }

  /// Update cycle duration, period length, or period start date
  Future<void> updateCycleDetails({
    required int averageCycleLength,
    required int averagePeriodDuration,
    required DateTime lastPeriodStartDate,
    double? cycleVariationDays,
  }) async {
    final updatedCycle = CycleDataModel.fromRealDates(
      lastPeriodStartDate: lastPeriodStartDate,
      averageCycleLength: averageCycleLength,
      averagePeriodDuration: averagePeriodDuration,
      history: state.cycleData.history,
      cycleVariationDays: cycleVariationDays ?? state.cycleData.cycleVariationDays,
    );

    state = state.copyWith(cycleData: updatedCycle);
    await _repository.saveCycleData(updatedCycle);

    // Trigger AI analysis with updated cycle timing
    await runAiScreeningAnalysis();
  }

  /// Run AI screening analysis combining real profile, cycle, symptoms and medical records
  Future<void> runAiScreeningAnalysis() async {
    if (state.isAnalyzing) return;

    state = state.copyWith(isAnalyzing: true);

    try {
      final profile = _ref.read(profileProvider);
      final records = _ref.read(medicalRecordsProvider).records;

      final assessments = await _repository.runAiScreeningAnalysis(
        userProfile: profile,
        cycleData: state.cycleData,
        symptomLogs: state.symptomLogs,
        records: records,
      );

      state = state.copyWith(
        assessments: assessments,
        isAnalyzing: false,
        lastAnalyzedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Screening analysis error: $e');
      state = state.copyWith(isAnalyzing: false);
    }
  }

  /// Toggle private vault lock
  Future<void> togglePrivateVaultLock() async {
    final newLocked = await _repository.toggleVaultLock(state.isPrivateVaultLocked);
    state = state.copyWith(isPrivateVaultLocked: newLocked);
  }

  /// Generate comprehensive doctor consultation summary
  GynecologistSummary generateDoctorSummary(UserProfileModel profile) {
    int? age;
    if (profile.dateOfBirth != null) {
      age = DateTime.now().difference(profile.dateOfBirth!).inDays ~/ 365;
    }

    return GynecologistSummary(
      patientName: profile.fullName,
      patientAge: age,
      patientGender: profile.gender ?? 'Female',
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
      medicalConditions: profile.medicalConditions,
      allergies: profile.allergies,
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
  final repo = ref.watch(womensHealthRepositoryProvider);
  return WomensHealthNotifier(ref, repo);
});
