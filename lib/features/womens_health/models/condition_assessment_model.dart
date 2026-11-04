import 'package:flutter/material.dart';

enum AssessmentRiskLevel {
  lowRisk,
  moderateRisk,
  highRisk,
  requiresImmediateConsultation;

  String get label {
    switch (this) {
      case AssessmentRiskLevel.lowRisk:
        return 'Low Clinical Probability';
      case AssessmentRiskLevel.moderateRisk:
        return 'Moderate Pattern Correlation';
      case AssessmentRiskLevel.highRisk:
        return 'High Pattern Correlation';
      case AssessmentRiskLevel.requiresImmediateConsultation:
        return 'Urgent Medical Attention Advised';
    }
  }

  Color get color {
    switch (this) {
      case AssessmentRiskLevel.lowRisk:
        return const Color(0xFF10B981); // Emerald
      case AssessmentRiskLevel.moderateRisk:
        return const Color(0xFFF59E0B); // Amber
      case AssessmentRiskLevel.highRisk:
        return const Color(0xFFF43F5E); // Rose
      case AssessmentRiskLevel.requiresImmediateConsultation:
        return const Color(0xFFDC2626); // Red
    }
  }

  static AssessmentRiskLevel fromString(String? val) {
    switch (val) {
      case 'moderateRisk':
        return AssessmentRiskLevel.moderateRisk;
      case 'highRisk':
        return AssessmentRiskLevel.highRisk;
      case 'requiresImmediateConsultation':
        return AssessmentRiskLevel.requiresImmediateConsultation;
      case 'lowRisk':
      default:
        return AssessmentRiskLevel.lowRisk;
    }
  }
}

class ConditionAssessment {
  final String id;
  final String conditionName;
  final String category;
  final String subtitle;
  final AssessmentRiskLevel riskLevel;
  final double scorePercent; // 0 to 100
  final List<String> identifiedMarkers;
  final List<String> negativeMarkers;
  final List<String> recommendedLabTests;
  final List<String> physicianDiscussionPoints;
  final String clinicalRationale;

  const ConditionAssessment({
    required this.id,
    required this.conditionName,
    required this.category,
    required this.subtitle,
    required this.riskLevel,
    required this.scorePercent,
    required this.identifiedMarkers,
    required this.negativeMarkers,
    required this.recommendedLabTests,
    required this.physicianDiscussionPoints,
    required this.clinicalRationale,
  });

  ConditionAssessment copyWith({
    String? id,
    String? conditionName,
    String? category,
    String? subtitle,
    AssessmentRiskLevel? riskLevel,
    double? scorePercent,
    List<String>? identifiedMarkers,
    List<String>? negativeMarkers,
    List<String>? recommendedLabTests,
    List<String>? physicianDiscussionPoints,
    String? clinicalRationale,
  }) {
    return ConditionAssessment(
      id: id ?? this.id,
      conditionName: conditionName ?? this.conditionName,
      category: category ?? this.category,
      subtitle: subtitle ?? this.subtitle,
      riskLevel: riskLevel ?? this.riskLevel,
      scorePercent: scorePercent ?? this.scorePercent,
      identifiedMarkers: identifiedMarkers ?? this.identifiedMarkers,
      negativeMarkers: negativeMarkers ?? this.negativeMarkers,
      recommendedLabTests: recommendedLabTests ?? this.recommendedLabTests,
      physicianDiscussionPoints:
          physicianDiscussionPoints ?? this.physicianDiscussionPoints,
      clinicalRationale: clinicalRationale ?? this.clinicalRationale,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conditionName': conditionName,
        'category': category,
        'subtitle': subtitle,
        'riskLevel': riskLevel.name,
        'scorePercent': scorePercent,
        'identifiedMarkers': identifiedMarkers,
        'negativeMarkers': negativeMarkers,
        'recommendedLabTests': recommendedLabTests,
        'physicianDiscussionPoints': physicianDiscussionPoints,
        'clinicalRationale': clinicalRationale,
      };

  factory ConditionAssessment.fromJson(Map<String, dynamic> json) {
    return ConditionAssessment(
      id: json['id']?.toString() ?? 'assessment',
      conditionName: json['conditionName']?.toString() ?? 'Reproductive Pattern',
      category: json['category']?.toString() ?? 'Reproductive Health',
      subtitle: json['subtitle']?.toString() ?? 'Clinical Pattern Screening',
      riskLevel: AssessmentRiskLevel.fromString(json['riskLevel']?.toString()),
      scorePercent: (json['scorePercent'] as num?)?.toDouble() ?? 20.0,
      identifiedMarkers: (json['identifiedMarkers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      negativeMarkers: (json['negativeMarkers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      recommendedLabTests: (json['recommendedLabTests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      physicianDiscussionPoints:
          (json['physicianDiscussionPoints'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
      clinicalRationale: json['clinicalRationale']?.toString() ?? '',
    );
  }
}
