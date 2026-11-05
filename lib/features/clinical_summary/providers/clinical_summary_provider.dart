import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../health_timeline/providers/physiological_systems_provider.dart';
import '../../health_timeline/providers/sensation_provider.dart';
import '../../health_timeline/providers/timeline_provider.dart';
import '../../medical_records/providers/medical_records_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../vitals_activity/providers/vitals_provider.dart';
import '../../womens_health/providers/womens_health_provider.dart';
import '../data/clinical_summary_repository.dart';
import '../models/clinical_summary_model.dart';
import '../services/clinical_pdf_export_service.dart';

final clinicalSummaryRepositoryProvider = Provider<ClinicalSummaryRepository>((ref) {
  return ClinicalSummaryRepository();
});

class ClinicalSummaryState {
  final ClinicalSummaryModel summary;
  final bool isLoading;
  final bool isExportingPdf;
  final String? errorMessage;

  const ClinicalSummaryState({
    required this.summary,
    this.isLoading = false,
    this.isExportingPdf = false,
    this.errorMessage,
  });

  ClinicalSummaryState copyWith({
    ClinicalSummaryModel? summary,
    bool? isLoading,
    bool? isExportingPdf,
    String? errorMessage,
  }) {
    return ClinicalSummaryState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isExportingPdf: isExportingPdf ?? this.isExportingPdf,
      errorMessage: errorMessage,
    );
  }
}

class ClinicalSummaryNotifier extends StateNotifier<ClinicalSummaryState> {
  final Ref _ref;
  final ClinicalSummaryRepository _repository;

  ClinicalSummaryNotifier(this._ref, this._repository)
      : super(
          ClinicalSummaryState(
            summary: ClinicalSummaryModel.fromRealData(
              profile: _ref.read(profileProvider),
              vitals: _ref.read(vitalsProvider).snapshot,
              records: _ref.read(medicalRecordsProvider).records,
              timeline: _ref.read(timelineProvider),
              sensations: _ref.read(sensationProvider),
              physiologicalSystems: _ref.read(physiologicalSystemsProvider).assessment,
              womensHealthState: _ref.read(womensHealthProvider),
            ),
          ),
        ) {
    loadSummary();
  }

  /// Load or synthesize clinical summary
  Future<void> loadSummary({bool forceFresh = false}) async {
    _setLoading(true);
    try {
      final profile = _ref.read(profileProvider);
      final vitals = _ref.read(vitalsProvider).snapshot;
      final records = _ref.read(medicalRecordsProvider).records;
      final timeline = _ref.read(timelineProvider);
      final sensations = _ref.read(sensationProvider);
      final physio = _ref.read(physiologicalSystemsProvider).assessment;
      final womens = _ref.read(womensHealthProvider);

      final summary = await _repository.fetchOrSynthesizeSummary(
        profile: profile,
        vitals: vitals,
        records: records,
        timeline: timeline,
        sensations: sensations,
        physiologicalSystems: physio,
        womensHealthState: womens,
        forceFresh: forceFresh,
      );

      if (mounted) {
        state = state.copyWith(summary: summary, isLoading: false);
      }
    } catch (e) {
      debugPrint('Error loading clinical summary: $e');
      if (mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    }
  }

  /// Export complete clinical summary to a PDF file and trigger system share / download
  Future<bool> exportPdf() async {
    state = state.copyWith(isExportingPdf: true);
    try {
      await ClinicalPdfExportService.exportPdf(state.summary);
      if (mounted) {
        state = state.copyWith(isExportingPdf: false);
      }
      return true;
    } catch (e) {
      debugPrint('Error exporting clinical summary PDF: $e');
      if (mounted) {
        state = state.copyWith(isExportingPdf: false, errorMessage: 'Failed to export PDF: $e');
      }
      return false;
    }
  }

  /// Print or preview PDF document
  Future<bool> printOrPreview(BuildContext context) async {
    state = state.copyWith(isExportingPdf: true);
    try {
      await ClinicalPdfExportService.printOrPreviewPdf(context, state.summary);
      if (mounted) {
        state = state.copyWith(isExportingPdf: false);
      }
      return true;
    } catch (e) {
      debugPrint('Error previewing clinical summary PDF: $e');
      if (mounted) {
        state = state.copyWith(isExportingPdf: false, errorMessage: 'Failed to preview PDF: $e');
      }
      return false;
    }
  }

  void _setLoading(bool val) {
    if (mounted) {
      state = state.copyWith(isLoading: val);
    }
  }
}

final clinicalSummaryProvider =
    StateNotifierProvider<ClinicalSummaryNotifier, ClinicalSummaryState>((ref) {
  final repo = ref.watch(clinicalSummaryRepositoryProvider);
  return ClinicalSummaryNotifier(ref, repo);
});
