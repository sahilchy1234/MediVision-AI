import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../medical_records/models/medical_record.dart';
import '../../medical_records/providers/medical_records_provider.dart';
import '../../vitals_activity/providers/vitals_provider.dart';
import '../models/condition_assessment_model.dart';
import '../providers/womens_health_provider.dart';
import 'condition_screening_screen.dart';
import 'edit_cycle_settings_sheet.dart';
import 'gynecology_consultation_sheet.dart';
import 'log_cycle_symptoms_sheet.dart';

class WomensHealthScreen extends ConsumerWidget {
  const WomensHealthScreen({super.key});

  void _openLogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LogCycleSymptomsSheet(),
    );
  }

  void _openConsultationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GynecologyConsultationSheet(),
    );
  }

  void _openCycleSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditCycleSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(womensHealthProvider);
    final recordsState = ref.watch(medicalRecordsProvider);
    final vitalsState = ref.watch(vitalsProvider);

    final cycle = state.cycleData;
    final phase = cycle.currentPhase;

    // Filter real reproductive imaging & lab records
    final reproductiveRecords = recordsState.records.where((record) {
      final title = record.title.toLowerCase();
      final summary = record.summary.toLowerCase();
      final cat = record.category;

      return title.contains('ultrasound') ||
          title.contains('pelvic') ||
          title.contains('hormone') ||
          title.contains('ovarian') ||
          title.contains('amh') ||
          title.contains('follicle') ||
          title.contains('endometri') ||
          title.contains('pap') ||
          title.contains('gynec') ||
          summary.contains('ovary') ||
          summary.contains('uterus') ||
          summary.contains('endometrium') ||
          cat == RecordCategory.xRays;
    }).toList();

    // Determine real basal temperature
    final tempValue = state.latestBasalTemp ?? vitalsState.snapshot.bodyTemperature;
    final tempStr = '${tempValue.toStringAsFixed(1)} °C';
    final tempCaption = tempValue >= 36.8 ? 'Luteal Shift' : 'Follicular';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Women's Health",
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              state.isPrivateVaultLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
              size: 20,
              color: state.isPrivateVaultLocked ? AppColors.accentRose : AppColors.secondary,
            ),
            tooltip: state.isPrivateVaultLocked ? 'Vault Locked' : 'Vault Active',
            onPressed: () {
              ref.read(womensHealthProvider.notifier).togglePrivateVaultLock();
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 20),
            tooltip: 'Cycle Parameters',
            onPressed: () => _openCycleSettingsSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.description_outlined, size: 20),
            tooltip: 'Gynecology Summary',
            onPressed: () => _openConsultationSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Private Vault Status Strip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 16,
                      color: state.isPrivateVaultLocked ? AppColors.accentRose : AppColors.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.isPrivateVaultLocked
                            ? 'Reproductive Vault Encrypted & Locked'
                            : 'On-Device Encrypted Reproductive Vault',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    StatusBadge(
                      label: state.isPrivateVaultLocked ? 'Locked' : 'Active',
                      type: state.isPrivateVaultLocked ? BadgeType.warning : BadgeType.success,
                      isPill: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Cycle Dial Card
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              phase.label,
                              style: AppTypography.titleLarge.copyWith(
                                color: phase.color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              cycle.isFertileWindow ? 'Fertile Window Active' : 'Low Conception Probability',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => _openCycleSettingsSheet(context),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          child: StatusBadge(
                            label: 'Day ${cycle.currentDayOfCycle} of ${cycle.averageCycleLength}',
                            type: BadgeType.neutral,
                            isPill: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Clean Cycle Progress Ring
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: (cycle.currentDayOfCycle / cycle.averageCycleLength).clamp(0.0, 1.0),
                            strokeWidth: 10,
                            backgroundColor: AppColors.surfaceSubtle,
                            valueColor: AlwaysStoppedAnimation<Color>(phase.color),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Day ${cycle.currentDayOfCycle}',
                              style: AppTypography.displayMedium.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${cycle.daysUntilNextPeriod}d to period',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Metrics Strip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _CycleMetricSnippet(
                          label: 'Variance',
                          value: '±${cycle.cycleVariationDays.toStringAsFixed(1)}d',
                          caption: cycle.cycleVariationDays <= 2.5 ? 'Regular' : 'Irregular',
                        ),
                        Container(width: 1, height: 24, color: AppColors.border),
                        _CycleMetricSnippet(
                          label: 'Avg Duration',
                          value: '${cycle.averagePeriodDuration}d',
                          caption: 'Typical',
                        ),
                        Container(width: 1, height: 24, color: AppColors.border),
                        _CycleMetricSnippet(
                          label: 'Basal Temp',
                          value: tempStr,
                          caption: tempCaption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                        ),
                      ),
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                      label: const Text('Log Today', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      onPressed: () => _openLogSheet(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.border, width: 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                        ),
                      ),
                      icon: const Icon(Icons.assessment_outlined, size: 18),
                      label: const Text('Assess Patterns', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ConditionScreeningScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Condition Screenings List
              SectionHeader(
                title: 'Screening Patterns',
                actionText: 'View All',
                onActionTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ConditionScreeningScreen()),
                  );
                },
              ),
              if (state.assessments.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No patterns evaluated yet. Log daily symptoms or tap below to synthesize.',
                          style: AppTypography.bodySmall,
                        ),
                      ),
                      TextButton(
                        onPressed: () => ref.read(womensHealthProvider.notifier).runAiScreeningAnalysis(),
                        child: const Text('Analyze'),
                      ),
                    ],
                  ),
                )
              else
                ...state.assessments.take(2).map((assessment) {
                  final risk = assessment.riskLevel;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: GlassCard(
                      padding: const EdgeInsets.all(14),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ConditionScreeningScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: risk.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.health_and_safety_outlined, color: risk.color, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        assessment.conditionName,
                                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${assessment.scorePercent.toInt()}%',
                                      style: AppTypography.labelSmall.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: risk.color,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  assessment.identifiedMarkers.isNotEmpty
                                      ? assessment.identifiedMarkers.first
                                      : 'No acute markers logged',
                                  style: AppTypography.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(
                            label: risk == AssessmentRiskLevel.lowRisk
                                ? 'Low'
                                : risk == AssessmentRiskLevel.moderateRisk
                                    ? 'Moderate'
                                    : 'High',
                            type: risk == AssessmentRiskLevel.lowRisk
                                ? BadgeType.success
                                : risk == AssessmentRiskLevel.moderateRisk
                                    ? BadgeType.warning
                                    : BadgeType.error,
                            isPill: true,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 10),

              // Specialized Medical Records (Real User Records)
              SectionHeader(
                title: 'Reproductive Imaging & Panels',
                actionText: 'Manage',
                onActionTap: () => context.push('/medical-records'),
              ),
              if (reproductiveRecords.isNotEmpty)
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Column(
                    children: [
                      for (int i = 0; i < reproductiveRecords.take(3).length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              reproductiveRecords[i].category.icon,
                              color: AppColors.secondary,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            reproductiveRecords[i].title,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                          subtitle: Text(
                            reproductiveRecords[i].summary.isNotEmpty
                                ? reproductiveRecords[i].summary
                                : 'Uploaded ${DateFormat('MMM d, yyyy').format(reproductiveRecords[i].date)}',
                            style: const TextStyle(fontSize: 11.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: StatusBadge(
                            label: reproductiveRecords[i].status,
                            type: reproductiveRecords[i].status.toLowerCase().contains('normal') ||
                                    reproductiveRecords[i].status.toLowerCase().contains('optimal')
                                ? BadgeType.success
                                : BadgeType.warning,
                            isPill: true,
                          ),
                          onTap: () => context.push('/medical-records'),
                        ),
                      ],
                    ],
                  ),
                )
              else
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.document_scanner_outlined, color: AppColors.secondaryDark, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No reproductive panels attached yet',
                                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Upload pelvic ultrasound or hormone panel reports to enhance clinical pattern screener.',
                                  style: AppTypography.bodySmall.copyWith(fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                          label: const Text('Add Ultrasound or Hormone Report'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          onPressed: () => context.push('/medical-records'),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CycleMetricSnippet extends StatelessWidget {
  final String label;
  final String value;
  final String caption;

  const _CycleMetricSnippet({
    required this.label,
    required this.value,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 1),
        Text(
          caption,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
