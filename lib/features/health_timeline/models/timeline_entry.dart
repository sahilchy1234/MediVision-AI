import 'package:flutter/material.dart';

enum TimelineCategory { all, sleep, activity, symptoms, reports, medications }

extension TimelineCategoryExtension on TimelineCategory {
  String get label {
    switch (this) {
      case TimelineCategory.all:
        return 'All Activity';
      case TimelineCategory.sleep:
        return 'Sleep';
      case TimelineCategory.activity:
        return 'Activity';
      case TimelineCategory.symptoms:
        return 'Symptoms';
      case TimelineCategory.reports:
        return 'Reports';
      case TimelineCategory.medications:
        return 'Medications';
    }
  }

  static TimelineCategory fromString(String? val) {
    if (val == null) return TimelineCategory.all;
    final lower = val.toLowerCase().trim();
    return TimelineCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == lower,
      orElse: () => TimelineCategory.all,
    );
  }
}

class TimelineEntry {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final TimelineCategory category;
  final String metricValue;
  final String? statusLabel;
  final Color statusColor;
  final IconData icon;
  final String plainEnglishInsight;
  final String simplePillTag;
  final String? source; // e.g. 'medical_records', 'vitals_activity', 'user_log'

  const TimelineEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
    required this.metricValue,
    this.statusLabel,
    this.statusColor = const Color(0xFF0D9488),
    required this.icon,
    this.plainEnglishInsight = 'Recorded in your personal health record.',
    this.simplePillTag = 'Healthy',
    this.source,
  });

  TimelineEntry copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    TimelineCategory? category,
    String? metricValue,
    String? statusLabel,
    Color? statusColor,
    IconData? icon,
    String? plainEnglishInsight,
    String? simplePillTag,
    String? source,
  }) {
    return TimelineEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      metricValue: metricValue ?? this.metricValue,
      statusLabel: statusLabel ?? this.statusLabel,
      statusColor: statusColor ?? this.statusColor,
      icon: icon ?? this.icon,
      plainEnglishInsight: plainEnglishInsight ?? this.plainEnglishInsight,
      simplePillTag: simplePillTag ?? this.simplePillTag,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'category': category.name,
      'metricValue': metricValue,
      'statusLabel': statusLabel,
      'statusColor': statusColor.value,
      'icon': _iconToName(icon),
      'plainEnglishInsight': plainEnglishInsight,
      'simplePillTag': simplePillTag,
      'source': source,
    };
  }

  factory TimelineEntry.fromJson(Map<String, dynamic> json) {
    Color parsedColor = const Color(0xFF0D9488);
    if (json['statusColor'] is int) {
      parsedColor = Color(json['statusColor'] as int);
    } else if (json['statusColor'] is String) {
      final hex = int.tryParse(json['statusColor'] as String);
      if (hex != null) parsedColor = Color(hex);
    }

    DateTime parsedDate;
    if (json['timestamp'] is String) {
      parsedDate = DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return TimelineEntry(
      id: json['id'] as String? ?? 'tl_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Health Event',
      description: json['description'] as String? ?? '',
      timestamp: parsedDate,
      category: TimelineCategoryExtension.fromString(json['category'] as String?),
      metricValue: json['metricValue'] as String? ?? '',
      statusLabel: json['statusLabel'] as String?,
      statusColor: parsedColor,
      icon: _iconFromName(json['icon'] as String?),
      plainEnglishInsight: json['plainEnglishInsight'] as String? ??
          'Recorded in your personal health record.',
      simplePillTag: json['simplePillTag'] as String? ?? 'Logged',
      source: json['source'] as String?,
    );
  }

  static String _iconToName(IconData icon) {
    if (icon == Icons.bedtime_rounded || icon == Icons.bedtime) return 'bedtime';
    if (icon == Icons.directions_walk_rounded || icon == Icons.directions_walk) return 'directions_walk';
    if (icon == Icons.directions_run_rounded || icon == Icons.directions_run) return 'directions_run';
    if (icon == Icons.monitor_heart_outlined || icon == Icons.monitor_heart) return 'monitor_heart';
    if (icon == Icons.water_drop_rounded || icon == Icons.water_drop) return 'water_drop';
    if (icon == Icons.medication_rounded || icon == Icons.medication) return 'medication';
    if (icon == Icons.document_scanner_rounded || icon == Icons.document_scanner) return 'document_scanner';
    if (icon == Icons.healing_rounded || icon == Icons.healing) return 'healing';
    if (icon == Icons.sync_rounded || icon == Icons.sync) return 'sync';
    if (icon == Icons.air_rounded) return 'air';
    return 'history';
  }

  static IconData _iconFromName(String? name) {
    switch (name) {
      case 'bedtime':
        return Icons.bedtime_rounded;
      case 'directions_walk':
        return Icons.directions_walk_rounded;
      case 'directions_run':
        return Icons.directions_run_rounded;
      case 'monitor_heart':
        return Icons.monitor_heart_outlined;
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'medication':
        return Icons.medication_rounded;
      case 'document_scanner':
        return Icons.document_scanner_rounded;
      case 'healing':
        return Icons.healing_rounded;
      case 'sync':
        return Icons.sync_rounded;
      case 'air':
        return Icons.air_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  /// Empty list by default to guarantee only real user health timeline data is displayed.
  static List<TimelineEntry> getSampleEntries() {
    return const [];
  }
}
