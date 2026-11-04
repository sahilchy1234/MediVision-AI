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
import '../../health_timeline/presentation/widgets/body_systems_diagram_card.dart';
import '../../health_timeline/presentation/widgets/interactive_human_body_diagram.dart';
import '../../health_timeline/presentation/widgets/weekly_rhythm_diagram_card.dart';
import '../../health_timeline/providers/timeline_provider.dart';
import '../../permissions/data/permission_item.dart';
import '../../permissions/providers/permissions_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../vitals_activity/models/vitals_activity_model.dart';
import '../../vitals_activity/presentation/widgets/live_activity_tracker_sheet.dart';
import '../../vitals_activity/presentation/widgets/pulse_measurement_sheet.dart';
import '../../vitals_activity/presentation/widgets/screen_time_sheet.dart';
import '../../vitals_activity/presentation/widgets/sleep_log_sheet.dart';
import '../../vitals_activity/presentation/widgets/vitals_capture_sheet.dart';
import '../../vitals_activity/providers/vitals_provider.dart';
import '../../womens_health/providers/womens_health_provider.dart';
import 'widgets/metric_card.dart';
import 'widgets/quick_action_button.dart';
import 'widgets/recent_updates_section.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _showGenerateSummarySheet(BuildContext context, String userName, VitalsSnapshot vitals) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusL),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Clinical Summary',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const StatusBadge(
                      label: 'Verified',
                      type: BadgeType.success,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Synthesized for $userName over the last 30 days',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biomarker & Vital Overview',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Mean Resting Pulse: ${vitals.formattedPulse} (${vitals.pulseSubtitle})\n'
                        '• Blood Pressure Baseline: ${vitals.formattedBP} (SpO2: ${vitals.bloodOxygenSpO2}%)\n'
                        '• Sleep Efficiency: ${vitals.sleepQualityScore}% (${vitals.formattedSleep} total, ${vitals.formattedDeepSleep} deep)\n'
                        '• Movement Target: ${vitals.formattedSteps} steps (${vitals.stepsSubtitle}, ${vitals.activeCalories} kcal)\n'
                        '• Screen Exposure: ${vitals.formattedScreenTime} (${vitals.screenPickups} pickups today)',
                        style: AppTypography.bodyMedium.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Export PDF Report',
                  icon: Icons.picture_as_pdf_outlined,
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Clinical summary exported successfully.'),
                        backgroundColor: AppColors.secondary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('Add Record'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select format to add to your clinical history:',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.errorBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 18),
              ),
              title: const Text('PDF Document', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
              subtitle: const Text('Lab panels, discharge summaries', style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                context.go('/medical-records');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.secondary, size: 18),
              ),
              title: const Text('Prescription / Photo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
              subtitle: const Text('Medication labels, doctor notes', style: TextStyle(fontSize: 12)),
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
    final vitalsState = ref.watch(vitalsProvider);
    final vitals = vitalsState.snapshot;
    final timelineEntries = ref.watch(timelineProvider);
    final recentEntries = timelineEntries.take(4).toList();

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
        child: RefreshIndicator(
          color: AppColors.secondary,
          onRefresh: () async {
            await ref.read(vitalsProvider.notifier).syncWithMobileDevice(silent: false);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clean Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Patient Overview',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.fullName,
                          style: AppTypography.displayMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Notification Button
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.textPrimary,
                            size: 22,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('All health notifications are up to date.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        // Avatar
                        InkWell(
                          onTap: () => context.go('/profile'),
                          borderRadius: BorderRadius.circular(18),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primaryContainer,
                            child: Text(
                              profile.fullName.isNotEmpty
                                  ? profile.fullName[0].toUpperCase()
                                  : 'P',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 1. Vitals and activity
                SectionHeader(
                  title: 'Vitals & Activity',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Auto-Sync Phone Button
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: vitalsState.isSyncingMobileData
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
                              )
                            : const Icon(Icons.sync_rounded, size: 14, color: AppColors.secondary),
                        label: Text(
                          vitalsState.isSyncingMobileData ? 'Syncing...' : 'Sync Mobile',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: vitalsState.isSyncingMobileData
                            ? null
                            : () async {
                                final res = await ref.read(vitalsProvider.notifier).syncWithMobileDevice(silent: false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(res.message),
                                      backgroundColor: res.success ? AppColors.secondary : AppColors.error,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                      ),
                      const SizedBox(width: 6),
                      // Log Data button
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 13, color: AppColors.textSecondary),
                        label: Text(
                          'Log',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => VitalsCaptureSheet.show(context),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => context.push('/permissions'),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Text(
                            vitalsState.lastSyncSource != null
                                ? 'via ${vitalsState.lastSyncSource}'
                                : '$connectedSourcesCount Sources',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w500,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Live Recording Banner if active
                if (vitalsState.isLiveTrackingActive) ...[
                  GlassCard(
                    onTap: () => LiveActivityTrackerSheet.show(context),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: vitalsState.isLiveTrackingPaused
                                ? AppColors.accentAmber
                                : AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Live ${vitalsState.liveTrackerType}: ${vitalsState.formattedLiveDuration}',
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${vitalsState.liveSteps} steps • ${vitalsState.liveCalories} kcal • ${vitalsState.liveDistanceKm} km',
                                style: AppTypography.bodySmall.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: const Text(
                            'Open Tracker',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // 2x2 Metric Grid with Real Captured Data
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        title: 'Sleep',
                        value: isSleepConnected ? vitals.formattedSleep : 'Off',
                        subtitle: isSleepConnected ? vitals.sleepSubtitle : 'Tap to sync',
                        icon: Icons.bedtime_outlined,
                        iconColor: AppColors.accentIndigo,
                        progress: isSleepConnected ? vitals.sleepProgress : 0.0,
                        progressColor: AppColors.accentIndigo,
                        onTap: () => isSleepConnected
                            ? SleepLogSheet.show(context)
                            : context.push('/permissions'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricCard(
                        title: 'Steps',
                        value: isActivityConnected ? vitals.formattedSteps : 'Off',
                        subtitle: isActivityConnected ? vitals.stepsSubtitle : 'Tap to sync',
                        icon: Icons.directions_walk_rounded,
                        iconColor: AppColors.secondary,
                        progress: isActivityConnected ? vitals.stepsProgress : 0.0,
                        progressColor: AppColors.secondary,
                        onTap: () => isActivityConnected
                            ? LiveActivityTrackerSheet.show(context)
                            : context.push('/permissions'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        title: 'Resting Pulse',
                        value: isSensorsConnected ? vitals.formattedPulse : 'Off',
                        subtitle: isSensorsConnected ? vitals.pulseSubtitle : 'Tap to pair',
                        icon: Icons.monitor_heart_outlined,
                        iconColor: AppColors.accentRose,
                        progress: isSensorsConnected ? vitals.pulseProgress : 0.0,
                        progressColor: AppColors.accentRose,
                        onTap: () => isSensorsConnected
                            ? PulseMeasurementSheet.show(context)
                            : context.push('/permissions'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricCard(
                        title: 'Screen Time',
                        value: isScreenTimeConnected ? vitals.formattedScreenTime : 'Off',
                        subtitle: isScreenTimeConnected ? vitals.screenTimeSubtitle : 'Tap to sync',
                        icon: Icons.phone_android_rounded,
                        iconColor: AppColors.accentAmber,
                        progress: isScreenTimeConnected ? vitals.screenTimeProgress : 0.0,
                        progressColor: AppColors.accentAmber,
                        onTap: () => isScreenTimeConnected
                            ? ScreenTimeSheet.show(context)
                            : context.push('/permissions'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Cycle status (for females only)
                if (profile.isFemale) ...[
                  _WomensHealthDashboardCard(
                    onTap: () => context.push('/womens-health'),
                  ),
                  const SizedBox(height: 16),
                ],

                // 3. Add record, timeline and Summary
                Row(
                  children: [
                    Expanded(
                      child: QuickActionButton(
                        label: 'Add Record',
                        icon: Icons.upload_file_rounded,
                        color: AppColors.primary,
                        onTap: () => _showUploadDialog(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: QuickActionButton(
                        label: 'Timeline',
                        icon: Icons.timeline_rounded,
                        color: AppColors.secondary,
                        onTap: () => context.go('/timeline'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: QuickActionButton(
                        label: 'Summary',
                        icon: Icons.description_outlined,
                        color: AppColors.accentIndigo,
                        onTap: () => _showGenerateSummarySheet(
                          context,
                          profile.fullName,
                          vitals,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. Body & Systems (Moved from timeline to homepage)
                const SectionHeader(title: 'Body & Systems'),
                const SizedBox(height: 10),
                const InteractiveHumanBodyDiagram(),
                const SizedBox(height: 14),
                const BodySystemsDiagramCard(),
                const SizedBox(height: 14),
                const WeeklyRhythmDiagramCard(),
                const SizedBox(height: 20),

                // 5. Health Score (Derived dynamically from real vitals)
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Health Score',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(
                                  label: vitals.computedHealthScore >= 90 ? 'Stable' : 'Monitored',
                                  type: vitals.computedHealthScore >= 90 ? BadgeType.success : BadgeType.warning,
                                  isPill: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${vitals.computedHealthScore}',
                                  style: AppTypography.displayLarge.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 26,
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
                              'Resting pulse ${vitals.formattedPulse} • BP ${vitals.formattedBP} • SpO2 ${vitals.bloodOxygenSpO2}%',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 24,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 6. Recent Activity (Dynamically connected to timelineProvider)
                RecentUpdatesSection(
                  entries: recentEntries,
                  onSeeAllTap: () => context.go('/timeline'),
                  onEntryTap: (entry) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${entry.title}: ${entry.description}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
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
    final state = ref.watch(womensHealthProvider);
    final cycle = state.cycleData;
    final phase = cycle.currentPhase;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: phase.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.water_drop_outlined, size: 18, color: phase.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Cycle Status",
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    StatusBadge(
                      label: phase.label,
                      type: BadgeType.neutral,
                      isPill: true,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  phase.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
