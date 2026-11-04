import 'package:flutter/material.dart';

class SensationLog {
  final String id;
  final String systemOrArea;
  final String sensation;
  final int severity; // 1-10
  final List<String> qualityTags;
  final String? notes;
  final DateTime timestamp;

  const SensationLog({
    required this.id,
    required this.systemOrArea,
    required this.sensation,
    required this.severity,
    this.qualityTags = const [],
    this.notes,
    required this.timestamp,
  });

  String get severityLabel {
    if (severity <= 3) return 'Mild';
    if (severity <= 6) return 'Moderate';
    return 'Severe';
  }

  Color get severityColor {
    if (severity <= 3) return const Color(0xFF0D9488); // Teal/Emerald
    if (severity <= 6) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Rose/Red
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'systemOrArea': systemOrArea,
        'sensation': sensation,
        'severity': severity,
        'qualityTags': qualityTags,
        'notes': notes,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SensationLog.fromJson(Map<String, dynamic> json) => SensationLog(
        id: json['id'] as String,
        systemOrArea: json['systemOrArea'] as String,
        sensation: json['sensation'] as String,
        severity: (json['severity'] as num).toInt(),
        qualityTags: (json['qualityTags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        notes: json['notes'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  static List<SensationLog> getInitialSampleLogs() {
    final now = DateTime.now();
    return [
      SensationLog(
        id: 'sens_1',
        systemOrArea: 'Sleep & Cognition',
        sensation: 'Mental Fatigue & Grogginess',
        severity: 3,
        qualityTags: const ['Brain Fog', 'Dull'],
        notes: 'Noticeable after 4 hours of screen time.',
        timestamp: now.subtract(const Duration(hours: 4)),
      ),
      SensationLog(
        id: 'sens_2',
        systemOrArea: 'Physical Activity',
        sensation: 'Hamstring & Calf Tightness',
        severity: 4,
        qualityTags: const ['Stiffness', 'Aching'],
        notes: 'Following morning 5k brisk walk.',
        timestamp: now.subtract(const Duration(hours: 7)),
      ),
      SensationLog(
        id: 'sens_3',
        systemOrArea: 'Cardiovascular',
        sensation: 'Mild Palpitation Flutters',
        severity: 2,
        qualityTags: const ['Fluttering'],
        notes: 'Occurred briefly after black coffee.',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
      ),
    ];
  }
}
