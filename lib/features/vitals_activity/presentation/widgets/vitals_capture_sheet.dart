import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medivision_app/core/constants/app_colors.dart';
import 'package:medivision_app/core/constants/app_dimensions.dart';
import 'package:medivision_app/core/constants/app_typography.dart';
import 'package:medivision_app/core/widgets/glass_card.dart';
import 'package:medivision_app/features/vitals_activity/presentation/widgets/live_activity_tracker_sheet.dart';
import 'package:medivision_app/features/vitals_activity/presentation/widgets/pulse_measurement_sheet.dart';
import 'package:medivision_app/features/vitals_activity/presentation/widgets/screen_time_sheet.dart';
import 'package:medivision_app/features/vitals_activity/presentation/widgets/sleep_log_sheet.dart';

class VitalsCaptureSheet extends ConsumerWidget {
  const VitalsCaptureSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VitalsCaptureSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusL)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
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
              const SizedBox(height: 14),

              Text(
                'Capture Real Health Data',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                'Record live vitals, movement, sleep, and physiological markers',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: 16),

              // Action 1: Live Activity & Steps Tracker
              _CaptureOptionTile(
                icon: Icons.directions_walk_rounded,
                iconColor: AppColors.secondary,
                backgroundColor: AppColors.secondaryContainer,
                title: 'Start Live Activity & Step Tracking',
                subtitle: 'Live stopwatch, continuous cadence & active calorie burn',
                badgeText: 'Live Sensor',
                badgeColor: AppColors.secondary,
                onTap: () {
                  Navigator.pop(context);
                  LiveActivityTrackerSheet.show(context);
                },
              ),
              const SizedBox(height: 10),

              // Action 2: Measure Pulse & Log Vitals
              _CaptureOptionTile(
                icon: Icons.monitor_heart_outlined,
                iconColor: AppColors.accentRose,
                backgroundColor: AppColors.accentRose.withValues(alpha: 0.12),
                title: 'Measure Heart Rate & Vitals',
                subtitle: 'Tap-to-tempo pulse detector, Blood Pressure & SpO2',
                badgeText: 'Interactive',
                badgeColor: AppColors.accentRose,
                onTap: () {
                  Navigator.pop(context);
                  PulseMeasurementSheet.show(context);
                },
              ),
              const SizedBox(height: 10),

              // Action 3: Log Sleep
              _CaptureOptionTile(
                icon: Icons.bedtime_rounded,
                iconColor: AppColors.accentIndigo,
                backgroundColor: AppColors.accentIndigo.withValues(alpha: 0.12),
                title: 'Log Sleep Duration & Quality',
                subtitle: 'Record last night\'s rest, deep sleep stages & score',
                badgeText: 'Sleep Log',
                badgeColor: AppColors.accentIndigo,
                onTap: () {
                  Navigator.pop(context);
                  SleepLogSheet.show(context);
                },
              ),
              const SizedBox(height: 10),

              // Action 4: Log Screen Time
              _CaptureOptionTile(
                icon: Icons.phone_android_rounded,
                iconColor: AppColors.accentAmber,
                backgroundColor: AppColors.accentAmber.withValues(alpha: 0.12),
                title: 'Record Screen Time',
                subtitle: 'Digital wellbeing duration and pre-sleep screen exposure',
                badgeText: 'Wellbeing',
                badgeColor: AppColors.accentAmber,
                onTap: () {
                  Navigator.pop(context);
                  ScreenTimeSheet.show(context);
                },
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaptureOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final VoidCallback onTap;

  const _CaptureOptionTile({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
        ],
      ),
    );
  }
}
