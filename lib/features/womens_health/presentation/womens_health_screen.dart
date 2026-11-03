import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../ai_companion/providers/ai_companion_provider.dart';
import '../models/condition_assessment_model.dart';
import '../providers/womens_health_provider.dart';
import 'condition_screening_screen.dart';
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

  void _askAi(BuildContext context, WidgetRef ref, String prompt) {
    ref.read(aiCompanionProvider.notifier).sendMessage(prompt);
    context.go('/ai-companion');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(womensHealthProvider);
    final cycle = state.cycleData;
    final phase = cycle.currentPhase;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Women's Health Companion"),
        actions: [
          IconButton(
            icon: Icon(
              state.isPrivateVaultLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
              color: state.isPrivateVaultLocked ? AppColors.accentRose : AppColors.secondary,
            ),
            tooltip: 'Reproductive Vault Privacy',
            onPressed: () {
              ref.read(womensHealthProvider.notifier).togglePrivateVaultLock();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.isPrivateVaultLocked
                      ? 'Private Reproductive Vault unlocked.'
                      : 'Private Reproductive Vault locked & encrypted on-device.'),
                  backgroundColor: AppColors.secondary,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.assignment_outlined),
            tooltip: 'Gynecologist Summary',
            onPressed: () => _openConsultationSheet(context),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Private Vault Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppDimensions.cardShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.shield_rounded, size: 16, color: AppColors.secondaryDark),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Private Reproductive Health Vault',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Zero-Knowledge On-Device Storage • Never Shared',
                            style: AppTypography.bodySmall.copyWith(fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      label: state.isPrivateVaultLocked ? 'Locked' : 'Secured',
                      type: state.isPrivateVaultLocked ? BadgeType.warning : BadgeType.success,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Interactive Cycle Dial Card
              GlassCard(
                padding: const EdgeInsets.all(22),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    phase.color.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              cycle.isFertileWindow ? 'High Conception Probability' : 'Low Conception Window',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: phase.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            border: Border.all(color: phase.color.withOpacity(0.4)),
                          ),
                          child: Text(
                            'Day ${cycle.currentDayOfCycle} of ${cycle.averageCycleLength}',
                            style: AppTypography.labelSmall.copyWith(
                              color: phase.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Central Visual Cycle Progress Ring
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 170,
                          height: 170,
                          child: CircularProgressIndicator(
                            value: (cycle.currentDayOfCycle / cycle.averageCycleLength).clamp(0.0, 1.0),
                            strokeWidth: 14,
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
                                letterSpacing: -0.8,
                              ),
                            ),
                            Text(
                              '${cycle.daysUntilNextPeriod} days to period',
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: cycle.isFertileWindow ? AppColors.secondaryContainer : AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                cycle.isFertileWindow ? 'FERTILE WINDOW' : 'LUTEAL REST',
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: cycle.isFertileWindow ? AppColors.secondaryDark : AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Metrics Strip: Cycle variance & period length
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _CycleMetricSnippet(
                          label: 'Cycle Variance',
                          value: '±${cycle.cycleVariationDays}d',
                          caption: 'Regular (Rotterdam OK)',
                        ),
                        Container(width: 1, height: 28, color: AppColors.border),
                        _CycleMetricSnippet(
                          label: 'Avg Period',
                          value: '${cycle.averagePeriodDuration} days',
                          caption: 'Medium Flow',
                        ),
                        Container(width: 1, height: 28, color: AppColors.border),
                        const _CycleMetricSnippet(
                          label: 'Basal Temp',
                          value: '36.7 °C',
                          caption: 'Post-Ovulatory',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Primary Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentRose,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                      ),
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                      label: const Text('Log Today', style: TextStyle(fontWeight: FontWeight.w700)),
                      onPressed: () => _openLogSheet(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.border, width: 1.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                      ),
                      icon: const Icon(Icons.biotech_outlined, size: 20),
                      label: const Text('Screen Conditions', style: TextStyle(fontWeight: FontWeight.w700)),
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
              const SizedBox(height: 22),

              // Phase Insights & Lifestyle recommendations
              const SectionHeader(
                title: 'Hormonal & Lifestyle Guidance',
                subtitle: 'Adaptive insights tailored to your current phase',
              ),
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: phase.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          ),
                          child: Icon(Icons.auto_awesome, color: phase.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Biological Rhythm: ${phase.label}',
                                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'Estrogen peaks • Luteinizing Hormone (LH) surge underway',
                                style: AppTypography.bodySmall.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      phase.description,
                      style: AppTypography.bodyMedium.copyWith(height: 1.45),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.restaurant_rounded, size: 16, color: AppColors.secondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Nutrition pacing: Prioritize leafy greens, magnesium, and hydration to support estrogen metabolism.',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Condition Screening Highlights
              SectionHeader(
                title: 'Condition Pattern Assessment',
                subtitle: 'Evaluates PCOS, Endometriosis & Fertility markers',
                actionText: 'View All (5)',
                onActionTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ConditionScreeningScreen()),
                  );
                },
              ),
              ...state.assessments.take(2).map((assessment) {
                final risk = assessment.riskLevel;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ConditionScreeningScreen()),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: risk.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          ),
                          child: Icon(Icons.health_and_safety_rounded, color: risk.color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                assessment.conditionName,
                                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                assessment.identifiedMarkers.isNotEmpty
                                    ? assessment.identifiedMarkers.first
                                    : 'No alert signals logged',
                                style: AppTypography.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
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
                  ),
                );
              }),
              const SizedBox(height: 18),

              // Reproductive Health Medical Records
              SectionHeader(
                title: 'Reproductive Records & Ultrasounds',
                subtitle: 'Specialized imaging and hormone panels',
                actionText: 'Manage',
                onActionTap: () => context.go('/medical-records'),
              ),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                        child: const Icon(Icons.document_scanner_rounded, color: AppColors.secondaryDark),
                      ),
                      title: const Text('Pelvic Ultrasound (Transvaginal)', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text('Clear bilateral ovaries. Antral follicle count: 8 (Normal). Endometrium: 8.2mm'),
                      trailing: const StatusBadge(label: 'Verified', type: BadgeType.success),
                    ),
                    const Divider(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                        child: const Icon(Icons.water_drop_rounded, color: AppColors.primary),
                      ),
                      title: const Text('Day 3 Hormone & Ovarian Reserve Panel', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text('AMH: 2.8 ng/mL • LH: 4.2 IU/L • FSH: 5.1 IU/L (LH/FSH ratio < 1.0)'),
                      trailing: const StatusBadge(label: 'Optimal', type: BadgeType.success),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // AI Reproductive Companion Prompts
              const SectionHeader(
                title: 'Ask MediVision AI Companion',
                subtitle: 'Explore clinical explanations for your patterns',
              ),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _AiPromptChip(
                      label: 'Are my cycle variations indicative of PCOS?',
                      onTap: () => _askAi(context, ref, 'Are my cycle variations indicative of PCOS?'),
                    ),
                    _AiPromptChip(
                      label: 'Explain my pelvic ultrasound report.',
                      onTap: () => _askAi(context, ref, 'Explain my pelvic ultrasound report and antral follicle count.'),
                    ),
                    _AiPromptChip(
                      label: 'What should I ask my gynecologist about cramps?',
                      onTap: () => _askAi(context, ref, 'What should I ask my gynecologist about severe Day 1 cramps?'),
                    ),
                    _AiPromptChip(
                      label: 'How does the luteal phase impact sleep & anxiety?',
                      onTap: () => _askAi(context, ref, 'How does the luteal phase impact sleep and mood?'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
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
        Text(value, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 1),
        Text(
          caption,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.secondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _AiPromptChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AiPromptChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        avatar: const Icon(Icons.auto_awesome, size: 14, color: AppColors.accentIndigo),
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.border),
        label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        onPressed: onTap,
      ),
    );
  }
}
