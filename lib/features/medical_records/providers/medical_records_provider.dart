import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../health_timeline/providers/timeline_provider.dart';
import '../data/medical_records_repository.dart';
import '../models/medical_record.dart';

final medicalRecordsRepositoryProvider = Provider<MedicalRecordsRepository>((ref) {
  return MedicalRecordsRepository();
});

class MedicalRecordsState {
  final List<MedicalRecordItem> records;
  final bool isLoading;
  final String? errorMessage;
  final RecordCategory? selectedCategory;
  final String searchQuery;

  const MedicalRecordsState({
    this.records = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedCategory,
    this.searchQuery = '',
  });

  MedicalRecordsState copyWith({
    List<MedicalRecordItem>? records,
    bool? isLoading,
    String? errorMessage,
    RecordCategory? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
  }) {
    return MedicalRecordsState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Get filtered list based on category filter and search query
  List<MedicalRecordItem> get filteredRecords {
    return records.where((record) {
      if (selectedCategory != null && record.category != selectedCategory) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchTitle = record.title.toLowerCase().contains(q);
        final matchProvider = record.providerName.toLowerCase().contains(q);
        final matchSummary = record.summary.toLowerCase().contains(q);
        final matchCategory = record.category.label.toLowerCase().contains(q);
        if (!matchTitle && !matchProvider && !matchSummary && !matchCategory) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}

class MedicalRecordsNotifier extends StateNotifier<MedicalRecordsState> {
  final MedicalRecordsRepository _repository;
  final Ref? _ref;

  MedicalRecordsNotifier(this._repository, [this._ref]) : super(const MedicalRecordsState()) {
    loadRecords();
  }

  Future<void> loadRecords() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final records = await _repository.loadRecords();
      state = state.copyWith(records: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load medical records: $e',
      );
    }
  }

  void selectCategory(RecordCategory? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  Future<bool> addRecord({
    required String title,
    required RecordCategory category,
    required String providerName,
    required DateTime date,
    required String fileSize,
    String? filePath,
    String? fileType,
    String? summary,
    String? notes,
  }) async {
    try {
      final newRecord = MedicalRecordItem(
        id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        category: category,
        date: date,
        providerName: providerName.isNotEmpty ? providerName : 'Uploaded Record',
        fileSize: fileSize.isNotEmpty ? fileSize : '1.2 MB',
        status: 'Uploaded',
        statusColor: const Color(0xFF0D9488),
        summary: summary?.isNotEmpty == true
            ? summary!
            : 'Clinical document successfully uploaded and encrypted in medical records vault.',
        filePath: filePath,
        fileType: fileType,
        notes: notes,
        createdAt: DateTime.now(),
      );

      final updatedList = [newRecord, ...state.records];
      state = state.copyWith(records: updatedList);

      // Persist locally
      await _repository.saveRecordsLocally(updatedList);

      // Background remote sync
      await _repository.addRecord(newRecord);
      _ref?.read(timelineProvider.notifier).refreshTimeline();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error saving record: $e');
      return false;
    }
  }

  Future<bool> deleteRecord(String id) async {
    try {
      final updatedList = state.records.where((r) => r.id != id).toList();
      state = state.copyWith(records: updatedList);

      await _repository.saveRecordsLocally(updatedList);
      await _repository.deleteRecord(id);
      _ref?.read(timelineProvider.notifier).refreshTimeline();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error deleting record: $e');
      return false;
    }
  }

  Future<bool> updateRecord(MedicalRecordItem updated) async {
    try {
      final updatedList = state.records.map((r) => r.id == updated.id ? updated : r).toList();
      state = state.copyWith(records: updatedList);

      await _repository.saveRecordsLocally(updatedList);
      await _repository.updateRecord(updated);
      _ref?.read(timelineProvider.notifier).refreshTimeline();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error updating record: $e');
      return false;
    }
  }

  Future<void> runAiAnalysis(String id) async {
    try {
      final record = state.records.firstWhere((r) => r.id == id);
      final analyzed = await _repository.analyzeRecordWithAi(record);

      final updatedList = state.records.map((r) => r.id == id ? analyzed : r).toList();
      state = state.copyWith(records: updatedList);

      await _repository.saveRecordsLocally(updatedList);
      _ref?.read(timelineProvider.notifier).refreshTimeline();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error running AI analysis: $e');
    }
  }
}

final medicalRecordsProvider =
    StateNotifierProvider<MedicalRecordsNotifier, MedicalRecordsState>((ref) {
  final repository = ref.watch(medicalRecordsRepositoryProvider);
  return MedicalRecordsNotifier(repository, ref);
});
