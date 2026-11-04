import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medivision_app/core/constants/app_colors.dart';
import 'package:medivision_app/core/constants/app_dimensions.dart';
import 'package:medivision_app/core/constants/app_typography.dart';
import 'package:medivision_app/core/widgets/primary_button.dart';
import 'package:medivision_app/features/vitals_activity/providers/vitals_provider.dart';

class LiveActivityTrackerSheet extends ConsumerStatefulWidget {
  const LiveActivityTrackerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LiveActivityTrackerSheet(),
    );
  }

  @override
  ConsumerState<LiveActivityTrackerSheet> createState() => _LiveActivityTrackerSheetState();
}

class _LiveActivityTrackerSheetState extends ConsumerState<LiveActivityTrackerSheet> {
  String _selectedType = 'Walking';
  final TextEditingController _manualStepsController = TextEditingController();

  final List<String> _activityTypes = ['Walking', 'Running', 'Cardio', 'Cycling'];

  @override
  void dispose() {
    _manualStepsController.dispose();
    super.dispose();
  }

  void _finishSession() async {
    final session = await ref.read(vitalsProvider.notifier).finishLiveTracking();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Activity saved: ${session.steps} steps • ${session.calories} kcal • ${session.durationMinutes} min'),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vitalsState = ref.watch(vitalsProvider);
    final notifier = ref.read(vitalsProvider.notifier);
    final isActive = vitalsState.isLiveTrackingActive;
    final isPaused = vitalsState.isLiveTrackingPaused;

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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Activity Tracker',
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Capture real movement & exercise in real time',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPaused
                            ? AppColors.accentAmber.withValues(alpha: 0.15)
                            : AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isPaused ? AppColors.accentAmber : AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isPaused ? 'PAUSED' : 'RECORDING',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: isPaused ? AppColors.accentAmber : AppColors.secondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Activity Type Selector
              if (!isActive) ...[
                Text(
                  'Select Workout Mode',
                  style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _activityTypes.map((type) {
                    final isSelected = _selectedType == type;
                    IconData icon = Icons.directions_walk_rounded;
                    if (type == 'Running') icon = Icons.directions_run_rounded;
                    if (type == 'Cardio') icon = Icons.fitness_center_rounded;
                    if (type == 'Cycling') icon = Icons.directions_bike_rounded;

                    return ChoiceChip(
                      avatar: Icon(
                        icon,
                        size: 16,
                        color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                      ),
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedType = type);
                      },
                      selectedColor: AppColors.secondaryContainer,
                      labelStyle: TextStyle(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.secondaryDark : AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Main Live Dashboard Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.surfaceSubtle,
                      AppColors.primaryContainer.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      isActive ? vitalsState.liveTrackerType.toUpperCase() : _selectedType.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      vitalsState.formattedLiveDuration,
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _LiveMetricColumn(
                          label: 'STEPS',
                          value: '${vitalsState.liveSteps}',
                          unit: 'steps',
                          icon: Icons.directions_walk_rounded,
                        ),
                        Container(width: 1, height: 36, color: AppColors.border),
                        _LiveMetricColumn(
                          label: 'CALORIES',
                          value: '${vitalsState.liveCalories}',
                          unit: 'kcal',
                          icon: Icons.local_fire_department_rounded,
                        ),
                        Container(width: 1, height: 36, color: AppColors.border),
                        _LiveMetricColumn(
                          label: 'DISTANCE',
                          value: vitalsState.liveDistanceKm.toStringAsFixed(2),
                          unit: 'km',
                          icon: Icons.route_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Interactive Step Simulator / Tap Buttons during active session
              if (isActive) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        onPressed: () => notifier.addManualLiveSteps(25),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('+25 Steps'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        onPressed: () => notifier.addManualLiveSteps(100),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('+100 Steps'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Controls Action Buttons
              if (!isActive)
                PrimaryButton(
                  label: 'Start Live Activity',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () {
                    notifier.startLiveTracking(type: _selectedType);
                  },
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isPaused ? AppColors.secondary : AppColors.accentAmber,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          ),
                        ),
                        onPressed: () {
                          if (isPaused) {
                            notifier.resumeLiveTracking();
                          } else {
                            notifier.pauseLiveTracking();
                          }
                        },
                        icon: Icon(
                          isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          color: isPaused ? AppColors.secondary : AppColors.accentAmber,
                        ),
                        label: Text(
                          isPaused ? 'Resume' : 'Pause',
                          style: TextStyle(
                            color: isPaused ? AppColors.secondary : AppColors.accentAmber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          ),
                        ),
                        onPressed: _finishSession,
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text(
                          'Finish & Save',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),

              if (isActive) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {
                      notifier.cancelLiveTracking();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Discard Session',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveMetricColumn extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;

  const _LiveMetricColumn({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 10,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        Text(
          unit,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 11,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
