import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../models/condition_assessment_model.dart';
import '../providers/womens_health_provider.dart';
import 'gynecology_consultation_sheet.dart';

class ConditionScreeningScreen extends ConsumerWidget {
  const ConditionScreeningScreen({super.key});

  void _openConsultationSummary(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GynecologyConsultationSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(womensHealthProvider);
    final assessments = state.assessments;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clinical Condition Screener'),
        actions: [
          IconButton(
            icon: const Icon(Icons.description_outlined),
            tooltip: 'Gynecologist Summary',
            onPressed: () => _openConsultationSummary(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          children: [
            // Prominent Medical Legal Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warningBackground,
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                border: Border.all(color: AppColors.warning.withOpacity(0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.warning, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clinical Information & Tracking Companion',
                          style: AppTypography.labelLarge.copyWith(
                            color: const Color(0xFFB45309),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This module is not a substitute for clinical diagnosis by a licensed gynecologist. It aggregates cycle fluctuations, dysmenorrhea severity, hyperandrogenic signs, and ultrasound/lab records to help you prepare evidence-based questions for your doctor.',
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0xFF92400E),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Header Overview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Condition Risk & Patterns',
                      style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Evaluated across ${state.symptomLogs.length} logged checkpoints',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                  label: const Text('Doctor Summary'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () => _openConsultationSummary(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Condition Cards List
            ...assessments.map((assessment) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: _ConditionDetailCard(assessment: assessment),
              );
            }),

            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Export Gynecologist Consultation Brief',
              icon: Icons.assignment_rounded,
              onPressed: () => _openConsultationSummary(context, ref),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ConditionDetailCard extends StatelessWidget {
  final ConditionAssessment assessment;

  const _ConditionDetailCard({required this.assessment});

  @override
  Widget build(BuildContext context) {
    final risk = assessment.riskLevel;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: Title + Risk Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Text(
                        assessment.category.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      assessment.conditionName,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      assessment.subtitle,
                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: risk.label,
                type: risk == AssessmentRiskLevel.lowRisk
                    ? BadgeType.success
                    : risk == AssessmentRiskLevel.moderateRisk
                        ? BadgeType.warning
                        : BadgeType.error,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Score Indicator
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: assessment.scorePercent / 100,
                    minHeight: 7,
                    backgroundColor: AppColors.surfaceSubtle,
                    valueColor: AlwaysStoppedAnimation<Color>(risk.color),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${assessment.scorePercent.toInt()}% Match',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: risk.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Clinical Rationale
          Text(
            assessment.clinicalRationale,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),

          // Identified Signs
          if (assessment.identifiedMarkers.isNotEmpty) ...[
            Text(
              'Observed Markers from Tracking & Reports:',
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            ...assessment.identifiedMarkers.map((marker) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.arrow_right_rounded, size: 18, color: AppColors.accentRose),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          marker,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 12),
          ],

          // Negative / Protective Signs
          if (assessment.negativeMarkers.isNotEmpty) ...[
            Text(
              'Reassuring / Absence of Symptoms:',
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.accentEmerald,
              ),
            ),
            const SizedBox(height: 6),
            ...assessment.negativeMarkers.map((neg) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_rounded, size: 16, color: AppColors.accentEmerald),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          neg,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 14),
          ],

          // Recommended Laboratory Investigations to Ask Gynecologist
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_hospital_outlined, size: 16, color: AppColors.secondaryDark),
                    const SizedBox(width: 6),
                    Text(
                      'Diagnostic Tests to Request from Doctor:',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ...assessment.recommendedLabTests.map((test) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        '• $test',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
