import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/timeline_repository.dart';
import '../models/timeline_entry.dart';

final timelineRepositoryProvider = Provider<TimelineRepository>((ref) {
  return TimelineRepository();
});

class TimelineNotifier extends StateNotifier<List<TimelineEntry>> {
  final TimelineRepository _repository;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  TimelineNotifier(this._repository) : super(const []) {
    loadTimeline();
  }

  /// Load real persistent timeline entries from storage, medical records, vitals, and backend
  Future<void> loadTimeline() async {
    _isLoading = true;
    try {
      final entries = await _repository.loadTimeline();
      if (mounted) {
        state = entries;
      }
    } catch (e) {
      debugPrint('Error loading timeline: $e');
    } finally {
      _isLoading = false;
    }
  }

  /// Add a newly captured vital, medication, symptom, or activity event to the timeline
  Future<TimelineEntry> addEntry({
    required String title,
    required String description,
    required TimelineCategory category,
    required String metricValue,
    required IconData icon,
    DateTime? timestamp,
    String? statusLabel,
    Color statusColor = const Color(0xFF0D9488),
    String plainEnglishInsight = 'Recorded in your personal health record.',
    String simplePillTag = 'New Entry',
    String? source,
  }) async {
    final newEntry = TimelineEntry(
      id: 'timeline_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      timestamp: timestamp ?? DateTime.now(),
      category: category,
      metricValue: metricValue,
      statusLabel: statusLabel,
      statusColor: statusColor,
      icon: icon,
      plainEnglishInsight: plainEnglishInsight,
      simplePillTag: simplePillTag,
      source: source ?? 'user_log',
    );

    // Prepend to top of timeline
    final updated = [newEntry, ...state];
    state = updated;

    // Persist locally & sync to backend
    await _repository.saveTimelineLocally(updated);
    await _repository.addEntry(newEntry);

    return newEntry;
  }

  /// Delete a timeline entry
  Future<void> deleteEntry(String id) async {
    final updated = state.where((e) => e.id != id).toList();
    state = updated;

    await _repository.saveTimelineLocally(updated);
    await _repository.deleteEntry(id);
  }

  /// Refresh timeline from all real data sources
  Future<void> refreshTimeline() async {
    await loadTimeline();
  }
}

final timelineProvider =
    StateNotifierProvider<TimelineNotifier, List<TimelineEntry>>((ref) {
  final repository = ref.watch(timelineRepositoryProvider);
  return TimelineNotifier(repository);
});
