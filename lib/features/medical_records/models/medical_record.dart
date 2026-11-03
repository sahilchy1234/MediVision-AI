import 'package:flutter/material.dart';

enum RecordCategory { bloodReports, xRays, prescriptions, other }

extension RecordCategoryExtension on RecordCategory {
  String get label {
    switch (this) {
      case RecordCategory.bloodReports:
        return 'Blood Reports';
      case RecordCategory.xRays:
        return 'X-Rays & Imaging';
      case RecordCategory.prescriptions:
        return 'Prescriptions';
      case RecordCategory.other:
        return 'Other Records';
    }
  }

  IconData get icon {
    switch (this) {
      case RecordCategory.bloodReports:
        return Icons.water_drop_rounded;
      case RecordCategory.xRays:
        return Icons.medical_services_rounded;
      case RecordCategory.prescriptions:
        return Icons.receipt_long_rounded;
      case RecordCategory.other:
        return Icons.folder_open_rounded;
    }
  }
}

class MedicalRecordItem {
  final String id;
  final String title;
  final RecordCategory category;
  final DateTime date;
  final String providerName;
  final String fileSize;
  final String status;
  final Color statusColor;
  final String summary;

  const MedicalRecordItem({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.providerName,
    required this.fileSize,
    required this.status,
    required this.statusColor,
    required this.summary,
  });

  static List<MedicalRecordItem> getSampleRecords() {
    return [
      MedicalRecordItem(
        id: 'rec_1',
        title: 'Complete Blood Count & Ferritin Panel',
        category: RecordCategory.bloodReports,
        date: DateTime.now().subtract(const Duration(days: 9)),
        providerName: 'St. Jude Diagnostics Lab',
        fileSize: '1.4 MB PDF',
        status: 'Analyzed by AI',
        statusColor: const Color(0xFF0D9488),
        summary: '18 Biomarkers extracted. Serum ferritin 42 ng/mL. All values within normal clinical range.',
      ),
      MedicalRecordItem(
        id: 'rec_2',
        title: 'Lipid Profile & Cardio Biomarkers',
        category: RecordCategory.bloodReports,
        date: DateTime.now().subtract(const Duration(days: 28)),
        providerName: 'BioHealth Diagnostic Center',
        fileSize: '820 KB PDF',
        status: 'Optimal Range',
        statusColor: const Color(0xFF10B981),
        summary: 'HDL 62 mg/dL, LDL 94 mg/dL. Triglycerides well within safe cardioprotective threshold.',
      ),
      MedicalRecordItem(
        id: 'rec_3',
        title: 'Chest Radiograph (PA & Lateral)',
        category: RecordCategory.xRays,
        date: DateTime.now().subtract(const Duration(days: 45)),
        providerName: 'Metropolitan Imaging Institute',
        fileSize: '14.2 MB DICOM',
        status: 'Verified Clear',
        statusColor: const Color(0xFF10B981),
        summary: 'No acute cardiopulmonary disease. Costophrenic angles sharp. Lungs hyperinflation absent.',
      ),
      MedicalRecordItem(
        id: 'rec_4',
        title: 'Albuterol Sulfate Inhaler Rx',
        category: RecordCategory.prescriptions,
        date: DateTime.now().subtract(const Duration(days: 60)),
        providerName: 'Dr. Sarah Lin, MD (Pulmonology)',
        fileSize: '340 KB PDF',
        status: 'Active Rx',
        statusColor: const Color(0xFF3B82F6),
        summary: '90 mcg/actuation. 2 puffs every 4–6 hours as needed for exercise-induced bronchospasm.',
      ),
      MedicalRecordItem(
        id: 'rec_5',
        title: 'Annual Comprehensive Physical Summary',
        category: RecordCategory.other,
        date: DateTime.now().subtract(const Duration(days: 95)),
        providerName: 'City Health Family Practice',
        fileSize: '2.1 MB PDF',
        status: 'Archived',
        statusColor: const Color(0xFF64748B),
        summary: 'Full executive health checkup. Blood pressure 118/76 mmHg. Resting ECG normal sinus rhythm.',
      ),
    ];
  }
}

