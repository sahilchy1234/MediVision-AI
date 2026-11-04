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

  String get codeName {
    switch (this) {
      case RecordCategory.bloodReports:
        return 'bloodReports';
      case RecordCategory.xRays:
        return 'xRays';
      case RecordCategory.prescriptions:
        return 'prescriptions';
      case RecordCategory.other:
        return 'other';
    }
  }

  static RecordCategory fromString(String? val) {
    if (val == null) return RecordCategory.other;
    switch (val.toLowerCase().trim()) {
      case 'bloodreports':
      case 'blood reports':
      case 'blood_reports':
      case 'blood':
        return RecordCategory.bloodReports;
      case 'xrays':
      case 'x-rays & imaging':
      case 'imaging':
      case 'x-rays':
      case 'x_rays':
        return RecordCategory.xRays;
      case 'prescriptions':
      case 'prescription':
      case 'rx':
        return RecordCategory.prescriptions;
      default:
        return RecordCategory.other;
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
  final String? filePath;
  final String? fileType;
  final String? notes;
  final DateTime? createdAt;

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
    this.filePath,
    this.fileType,
    this.notes,
    this.createdAt,
  });

  MedicalRecordItem copyWith({
    String? id,
    String? title,
    RecordCategory? category,
    DateTime? date,
    String? providerName,
    String? fileSize,
    String? status,
    Color? statusColor,
    String? summary,
    String? filePath,
    String? fileType,
    String? notes,
    DateTime? createdAt,
  }) {
    return MedicalRecordItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      providerName: providerName ?? this.providerName,
      fileSize: fileSize ?? this.fileSize,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      summary: summary ?? this.summary,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category.codeName,
      'date': date.toIso8601String(),
      'providerName': providerName,
      'fileSize': fileSize,
      'status': status,
      'statusColor': statusColor.toARGB32(),
      'summary': summary,
      'filePath': filePath,
      'fileType': fileType,
      'notes': notes,
      'createdAt': (createdAt ?? date).toIso8601String(),
    };
  }

  factory MedicalRecordItem.fromJson(Map<String, dynamic> json) {
    Color parseColor(dynamic c) {
      if (c is int) return Color(c);
      if (c is String) {
        final parsed = int.tryParse(c.replaceFirst('#', ''), radix: 16);
        if (parsed != null) {
          if (c.length <= 7) return Color(0xFF000000 | parsed);
          return Color(parsed);
        }
      }
      return const Color(0xFF0D9488);
    }

    return MedicalRecordItem(
      id: json['id'] as String? ?? 'rec_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Untitled Record',
      category: RecordCategoryExtension.fromString(json['category'] as String?),
      date: json['date'] != null
          ? (DateTime.tryParse(json['date'] as String) ?? DateTime.now())
          : DateTime.now(),
      providerName: json['providerName'] as String? ?? 'Healthcare Provider',
      fileSize: json['fileSize'] as String? ?? '1.0 MB',
      status: json['status'] as String? ?? 'Indexed',
      statusColor: parseColor(json['statusColor']),
      summary: json['summary'] as String? ?? '',
      filePath: json['filePath'] as String?,
      fileType: json['fileType'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  static List<MedicalRecordItem> getSampleRecords() {
    return [];
  }
}
