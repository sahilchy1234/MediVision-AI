import 'package:flutter/material.dart';

enum TimelineCategory { all, sleep, activity, symptoms, reports, medications }

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
  });

  static List<TimelineEntry> getSampleEntries() {
    final now = DateTime.now();
    return [
      TimelineEntry(
        id: 't1',
        title: 'Deep Sleep & Recovery Restored',
        description: '7h 42m total sleep duration with 1h 48m deep sleep recorded.',
        timestamp: now.subtract(const Duration(hours: 3)),
        category: TimelineCategory.sleep,
        metricValue: '89 / 100 Quality',
        statusLabel: 'Optimal',
        statusColor: const Color(0xFF10B981),
        icon: Icons.bedtime_rounded,
      ),
      TimelineEntry(
        id: 't2',
        title: 'Cardio Target Achieved',
        description: '8,420 steps logged. 42 minutes in Zone 2 cardiovascular threshold.',
        timestamp: now.subtract(const Duration(hours: 6)),
        category: TimelineCategory.activity,
        metricValue: '8,420 steps',
        statusLabel: 'Goal Met',
        statusColor: const Color(0xFF0D9488),
        icon: Icons.directions_run_rounded,
      ),
      TimelineEntry(
        id: 't3',
        title: 'Comprehensive Metabolic Panel (CMP)',
        description: 'Automated OCR parsed 18 blood biomarkers. Fasting glucose and ferritin verified.',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        category: TimelineCategory.reports,
        metricValue: '18 Biomarkers',
        statusLabel: 'AI Analyzed',
        statusColor: const Color(0xFF6366F1),
        icon: Icons.biotech_rounded,
      ),
      TimelineEntry(
        id: 't4',
        title: 'Vitamin D3 & Omega-3 Logged',
        description: 'Morning maintenance supplement regimen confirmed.',
        timestamp: now.subtract(const Duration(days: 1, hours: 8)),
        category: TimelineCategory.medications,
        metricValue: '2,000 IU',
        statusLabel: 'Taken',
        statusColor: const Color(0xFF10B981),
        icon: Icons.medication_rounded,
      ),
      TimelineEntry(
        id: 't5',
        title: 'Mild Respiratory Wheeze',
        description: 'User reported slight tightness post evening run during cold weather.',
        timestamp: now.subtract(const Duration(days: 3, hours: 4)),
        category: TimelineCategory.symptoms,
        metricValue: 'Mild (Scale 2/10)',
        statusLabel: 'Resolved',
        statusColor: const Color(0xFFF59E0B),
        icon: Icons.healing_rounded,
      ),
      TimelineEntry(
        id: 't6',
        title: 'Chest X-Ray (PA & Lateral)',
        description: 'Clear lung fields bilaterally. Normal cardiac silhouette.',
        timestamp: now.subtract(const Duration(days: 7)),
        category: TimelineCategory.reports,
        metricValue: 'Normal',
        statusLabel: 'Physician Verified',
        statusColor: const Color(0xFF10B981),
        icon: Icons.document_scanner_rounded,
      ),
    ];
  }
}

