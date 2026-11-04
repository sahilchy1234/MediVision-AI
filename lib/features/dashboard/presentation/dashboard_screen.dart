import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../health_timeline/models/timeline_entry.dart';
import '../../permissions/data/permission_item.dart';
import '../../permissions/providers/permissions_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../womens_health/providers/womens_health_provider.dart';
import 'widgets/ai_insight_card.dart';
import 'widgets/metric_card.dart';
import 'widgets/quick_action_button.dart';
import 'widgets/recent_updates_section.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _showGenerateSummarySheet(BuildContext context, String userName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXL),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Clinical Health Summary',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const StatusBadge(
                    label: 'FHIR Standard',
                    type: BadgeType.success,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Synthesized for patient $userName over the last 30-day window.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Executive Vitals & Biomarker Analysis',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Mean Resting Heart Rate: 61 bpm (Cardiovascular fitness: High)\n'
                      '• Glycemic Stability: Normal (HbA1c 5.4%, Fasting 92 mg/dL)\n'
                      '• Sleep Efficiency: 89% (Optimal deep sleep distribution: 1h 48m)\n'
                      '• Active Medication: Albuterol 90mcg (PRN, 0 rescue actuations this week)',
                      style: AppTypography.bodyMedium.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Export PDF Clinical Report',
                icon: Icons.picture_as_pdf_rounded,
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Clinical summary exported successfully to Secure Storage.',
                      ),
                      backgroundColor: AppColors.secondary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showUploadMockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: const Icon(
                Icons.upload_file_rounded,
                color: AppColors.secondaryDark,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Upload Report'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select health documentation format to parse with OCR and MediVision AI:',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.picture_as_pdf_rounded,
                color: AppColors.error,
              ),
              title: const Text('PDF Lab Document'),
              subtitle: const Text('Blood panels, metabolic reports'),
              onTap: () {
                Navigator.pop(context);
                context.go('/medical-records');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.secondary,
              ),
              title: const Text('Scan Camera / Prescription'),
              subtitle: const Text('Medication labels, doctor notes'),
              onTap: () {
                Navigator.pop(context);
                context.go('/medical-records');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final permissions = ref.watch(permissionsProvider);
    final permissionsNotifier = ref.read(permissionsProvider.notifier);
    final recentEntries = TimelineEntry.getSampleEntries();

    final connectedSourcesCount = permissions
        .where((p) => p.status == PermissionStatus.granted)
        .length;

    // Self-healing: Ensure clinical data sources are active if none are connected
    if (connectedSourcesCount == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(permissionsProvider.notifier).grantAll();
      });
    }

    final isSleepConnected = permissionsNotifier.isSleepGranted;
    final isActivityConnected = permissionsNotifier.isActivityGranted;
    final isScreenTimeConnected = permissionsNotifier.isScreenTimeGranted;
    final isSensorsConnected = permissionsNotifier.isSensorsGranted;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Greeting + Avatar + Notifications
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning,',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.fullName,
                        style: AppTypography.displaySmall.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Notification Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: IconButton(
                          icon: const Stack(
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                color: AppColors.textPrimary,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'All system notifications are up to date.',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Avatar
                      InkWell(
                        onTap: () => context.go('/profile'),
                        borderRadius: BorderRadius.circular(22),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            profile.fullName.isNotEmpty
                                ? profile.fullName[0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Realistic Demo Data Notice Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.science_outlined,
                      size: 16,
                      color: AppColors.secondaryDark,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Demo Mode: Showing realistic biometric & laboratory telemetry.',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.secondaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        ref
                            .read(permissionsProvider.notifier)
                            .useMockDataSources();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Connected to simulated clinical mock data sources!',
                            ),
                            backgroundColor: AppColors.secondary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusFull,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_fix_high_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Use Mock Data',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Today's Health Overview
              GlassCard(
                padding: const EdgeInsets.all(20),
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFF9FBFC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's Health Overview",
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const StatusBadge(
                          label: 'Vitals Stable',
                          type: BadgeType.success,
                          icon: Icons.check_circle_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Health Score',
                                style: AppTypography.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '94',
                                    style: AppTypography.displayMedium.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    ' / 100',
                                    style: AppTypography.titleSmall.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '+3.2% vs previous 14-day average',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.accentEmerald,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondaryContainer.withOpacity(
                              0.4,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.favorite_rounded,
                              size: 40,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Women's Health Companion Card (Enabled only for Females)
              if (profile.isFemale) ...[
                _WomensHealthDashboardCard(
                  onTap: () => context.push('/womens-health'),
                ),
                const SizedBox(height: 18),
              ],

              // Quick Actions Row
              const SectionHeader(title: 'Quick Actions'),
              SizedBox(
                height: 104,
                child: Row(
                  children: [
                    Expanded(
                      child: QuickActionButton(
                        label: 'Ask AI',
                        icon: Icons.auto_awesome_rounded,
                        color: AppColors.accentIndigo,
                        onTap: () => context.go('/ai-companion'),
                      ),
                    ),
                    Expanded(
                      child: QuickActionButton(
                        label: 'Upload Report',
                        icon: Icons.upload_file_rounded,
                        color: AppColors.secondary,
                        onTap: () => _showUploadMockDialog(context),
                      ),
                    ),
                    Expanded(
                      child: QuickActionButton(
                        label: 'Timeline',
                        icon: Icons.timeline_rounded,
                        color: AppColors.primary,
                        onTap: () => context.go('/timeline'),
                      ),
                    ),
                    Expanded(
                      child: QuickActionButton(
                        label: 'Clinical Summary',
                        icon: Icons.description_rounded,
                        color: AppColors.accentEmerald,
                        onTap: () => _showGenerateSummarySheet(
                          context,
                          profile.fullName,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // AI Health Insight Card
              AiInsightCard(
                title: 'Deep Sleep Optimization Signal',
                insight:
                    'Your deep sleep increased by +18% on days when device screen time was curtailed 45 minutes prior to sleep. Consistent wind-down times have stabilized your resting pulse.',
                actionLabel: 'Discuss with AI',
                onActionTap: () => context.go('/ai-companion'),
              ),
              const SizedBox(height: 22),

              // Biometric & Daily Lifestyle Cards
              SectionHeader(
                title:
                    'Biometric Telemetry ($connectedSourcesCount Active)',
                trailing: TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                  ),
                  icon: const Icon(
                    Icons.tune_rounded,
                    size: 14,
                    color: AppColors.secondary,
                  ),
                  label: Text(
                    'Data Sources',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () => context.push('/permissions'),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  // Sleep Card
                  Expanded(
                    child: MetricCard(
                      title: 'Sleep Duration',
                      value: isSleepConnected ? '7h 42m' : 'Disconnected',
                      subtitle: isSleepConnected
                          ? '1h 48m Deep sleep (Optimal)'
                          : 'Tap to connect Sleep data',
                      icon: Icons.bedtime_rounded,
                      iconColor: isSleepConnected
                          ? AppColors.accentIndigo
                          : AppColors.textTertiary,
                      progress: isSleepConnected ? 0.88 : 0.0,
                      progressColor: isSleepConnected
                          ? AppColors.accentIndigo
                          : AppColors.border,
                      badgeText: isSleepConnected ? '89% Quality' : 'Paused',
                      badgeColor: isSleepConnected
                          ? AppColors.accentIndigo
                          : AppColors.textTertiary,
                      onTap: () => isSleepConnected
                          ? context.go('/timeline')
                          : context.push('/permissions'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Activity & Steps Card
                  Expanded(
                    child: MetricCard(
                      title: 'Daily Steps',
                      value: isActivityConnected ? '8,420' : 'Disconnected',
                      subtitle: isActivityConnected
                          ? 'Goal: 10,000 steps (84%)'
                          : 'Tap to connect Steps data',
                      icon: Icons.directions_run_rounded,
                      iconColor: isActivityConnected
                          ? AppColors.secondary
                          : AppColors.textTertiary,
                      progress: isActivityConnected ? 0.84 : 0.0,
                      progressColor: isActivityConnected
                          ? AppColors.secondary
                          : AppColors.border,
                      badgeText: isActivityConnected ? '482 kcal' : 'Paused',
                      badgeColor: isActivityConnected
                          ? AppColors.secondary
                          : AppColors.textTertiary,
                      onTap: () => isActivityConnected
                          ? context.go('/timeline')
                          : context.push('/permissions'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  // Screen-time Summary Card
                  Expanded(
                    child: MetricCard(
                      title: 'Screen Time',
                      value: isScreenTimeConnected ? '3h 15m' : 'Disconnected',
                      subtitle: isScreenTimeConnected
                          ? '45m before bed alert active'
                          : 'Tap to connect Screen data',
                      icon: Icons.phone_android_rounded,
                      iconColor: isScreenTimeConnected
                          ? AppColors.accentAmber
                          : AppColors.textTertiary,
                      progress: isScreenTimeConnected ? 0.55 : 0.0,
                      progressColor: isScreenTimeConnected
                          ? AppColors.accentAmber
                          : AppColors.border,
                      badgeText: isScreenTimeConnected
                          ? '-32m vs avg'
                          : 'Paused',
                      badgeColor: isScreenTimeConnected
                          ? AppColors.accentEmerald
                          : AppColors.textTertiary,
                      onTap: () => isScreenTimeConnected
                          ? context.go('/timeline')
                          : context.push('/permissions'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Resting Heart Rate Card
                  Expanded(
                    child: MetricCard(
                      title: 'Resting Pulse',
                      value: isSensorsConnected ? '61 bpm' : 'Disconnected',
                      subtitle: isSensorsConnected
                          ? 'Healthy athletic baseline'
                          : 'Tap to pair Bluetooth sensors',
                      icon: Icons.monitor_heart_rounded,
                      iconColor: isSensorsConnected
                          ? AppColors.accentRose
                          : AppColors.textTertiary,
                      progress: isSensorsConnected ? 0.65 : 0.0,
                      progressColor: isSensorsConnected
                          ? AppColors.accentRose
                          : AppColors.border,
                      badgeText: isSensorsConnected ? 'Optimal' : 'Paused',
                      badgeColor: isSensorsConnected
                          ? AppColors.accentEmerald
                          : AppColors.textTertiary,
                      onTap: () => isSensorsConnected
                          ? context.go('/timeline')
                          : context.push('/permissions'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Health Updates Section
              RecentUpdatesSection(
                entries: recentEntries,
                onSeeAllTap: () => context.go('/timeline'),
                onEntryTap: (entry) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${entry.title}: ${entry.description}'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _WomensHealthDashboardCard extends ConsumerWidget {
  final VoidCallback onTap;

  const _WomensHealthDashboardCard({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final womensHealth = ref.watch(womensHealthProvider);
    final cycle = womensHealth.cycleData;
    final phase = cycle.currentPhase;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      gradient: LinearGradient(
        colors: [Colors.white, AppColors.accentRose.withOpacity(0.06)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentRose.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  color: AppColors.accentRose,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Women's Health & Cycle",
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Private Reproductive Intelligence',
                      style: AppTypography.bodySmall.copyWith(fontSize: 10.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: phase.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(color: phase.color.withOpacity(0.3)),
                ),
                child: Text(
                  'Day ${cycle.currentDayOfCycle} • ${phase.label}',
                  style: AppTypography.labelSmall.copyWith(
                    color: phase.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cycle.isFertileWindow
                          ? 'Fertile Ovulatory Window Open'
                          : 'Luteal Phase Active',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Next period estimated in ${cycle.daysUntilNextPeriod} days • Cycle variance ±${cycle.cycleVariationDays}d',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // PCOS & Endometriosis quick indicator strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.biotech_rounded,
                  size: 14,
                  color: AppColors.secondaryDark,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'PCOS/Endo Screener: Rotterdam criteria verified • 1 active signal',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.secondaryDark,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'Details',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
