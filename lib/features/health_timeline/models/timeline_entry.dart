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
  final String plainEnglishInsight;
  final String simplePillTag;

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
    this.plainEnglishInsight = 'Everything is within your personal healthy range.',
    this.simplePillTag = 'Healthy',
  });

  static List<TimelineEntry> getSampleEntries() {
    final now = DateTime.now();
    return [
      TimelineEntry(
        id: 't1',
        title: 'Deep Sleep & Muscle Recovery',
        description: '7h 42m total sleep duration with 1h 48m deep sleep recorded.',
        timestamp: now.subtract(const Duration(hours: 3)),
        category: TimelineCategory.sleep,
        metricValue: '89% Sleep Quality',
        statusLabel: 'Great Rest',
        statusColor: const Color(0xFF10B981),
        icon: Icons.bedtime_rounded,
        plainEnglishInsight:
            'You spent almost 2 hours in deep sleep. This gave your muscles time to repair and cleared mental fatigue for today.',
        simplePillTag: 'Well Rested',
      ),
      TimelineEntry(
        id: 't2',
        title: 'Daily Movement & Walking',
        description: '8,420 steps logged. 42 minutes of brisk walking.',
        timestamp: now.subtract(const Duration(hours: 6)),
        category: TimelineCategory.activity,
        metricValue: '8,420 steps',
        statusLabel: 'Goal Met',
        statusColor: const Color(0xFF0D9488),
        icon: Icons.directions_walk_rounded,
        plainEnglishInsight:
            'You hit 84% of your daily movement goal without tiring your joints. Your heart got healthy aerobic exercise.',
        simplePillTag: 'Active Day',
      ),
      TimelineEntry(
        id: 't3',
        title: 'Blood Checkup & Lab Panel',
        description: 'Blood sugar, iron, and kidney filtration tested.',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        category: TimelineCategory.reports,
        metricValue: '18 Biomarkers',
        statusLabel: 'All Normal',
        statusColor: const Color(0xFF6366F1),
        icon: Icons.water_drop_rounded,
        plainEnglishInsight:
            'No warning signs found. Your fasting blood sugar is 92 (ideal) and your iron levels have recovered nicely.',
        simplePillTag: 'Safe & Clear',
      ),
      TimelineEntry(
        id: 't4',
        title: 'Morning Vitamin D & Omega-3',
        description: 'Morning maintenance supplements taken with breakfast.',
        timestamp: now.subtract(const Duration(days: 1, hours: 8)),
        category: TimelineCategory.medications,
        metricValue: '2,000 IU',
        statusLabel: 'Taken',
        statusColor: const Color(0xFF10B981),
        icon: Icons.medication_rounded,
        plainEnglishInsight:
            'Taking this with food ensures your bones and immune system absorb maximum vitamin D.',
        simplePillTag: 'Routine Complete',
      ),
      TimelineEntry(
        id: 't5',
        title: 'Mild Chest Tightness Logged',
        description: 'Slight shortness of breath logged after cold evening jog.',
        timestamp: now.subtract(const Duration(days: 3, hours: 4)),
        category: TimelineCategory.symptoms,
        metricValue: 'Mild (Scale 2/10)',
        statusLabel: 'Resolved',
        statusColor: const Color(0xFFF59E0B),
        icon: Icons.air_rounded,
        plainEnglishInsight:
            'Temporary cold-air response that settled quickly with rest. No rescue inhaler was required.',
        simplePillTag: 'Monitored',
      ),
      TimelineEntry(
        id: 't6',
        title: 'Chest X-Ray Imaging',
        description: 'Routine radiographic scan of lungs and heart.',
        timestamp: now.subtract(const Duration(days: 7)),
        category: TimelineCategory.reports,
        metricValue: 'Clear Lungs',
        statusLabel: 'Doctor Verified',
        statusColor: const Color(0xFF10B981),
        icon: Icons.document_scanner_rounded,
        plainEnglishInsight:
            'Lungs are clear and fully expanded with zero fluid or infection. Heart shape is completely normal.',
        simplePillTag: '100% Clear',
      ),
    ];
  }
}
