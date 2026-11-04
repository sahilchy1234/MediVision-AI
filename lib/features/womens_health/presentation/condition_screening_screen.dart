import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
            // Legal Disclaimer
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
                          'Clinical Evidence-Based Companion',
                          style: AppTypography.labelLarge.copyWith(
                            color: const Color(0xFFB45309),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This module is not a substitute for clinical diagnosis by a licensed gynecologist. It analyzes cycle fluctuations, dysmenorrhea severity, hyperandrogenic signs, and ultrasound/lab records against established diagnostic criteria (Rotterdam, ASRM).',
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
            const SizedBox(height: 16),

            // AI Status & Re-evaluate Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: state.isAnalyzing
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondaryDark),
                          )
                        : const Icon(Icons.auto_awesome, color: AppColors.secondaryDark, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.isAnalyzing ? 'Analyzing Real Data with AI...' : 'Real AI Clinical Synthesis',
                          style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          state.lastAnalyzedAt != null
                              ? 'Last evaluated ${DateFormat('MMM d, h:mm a').format(state.lastAnalyzedAt!)}'
                              : 'Real-time inference active',
                          style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      ),
                    ),
                    icon: state.isAnalyzing
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.refresh_rounded, size: 14),
                    label: Text(
                      state.isAnalyzing ? 'Analyzing' : 'Re-evaluate',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    onPressed: state.isAnalyzing
                        ? null
                        : () => ref.read(womensHealthProvider.notifier).runAiScreeningAnalysis(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

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
                    value: (assessment.scorePercent / 100).clamp(0.0, 1.0),
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
              'Observed Markers from Real Tracking & Reports:',
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
              'Reassuring / Protective Factors:',
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
          if (assessment.recommendedLabTests.isNotEmpty) ...[
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
            const SizedBox(height: 12),
          ],

          // Discussion points
          if (assessment.physicianDiscussionPoints.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.question_answer_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Questions to Ask Your Doctor:',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...assessment.physicianDiscussionPoints.map((q) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          '• $q',
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 11.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
