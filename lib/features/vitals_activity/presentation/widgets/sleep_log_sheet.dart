import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medivision_app/core/constants/app_colors.dart';
import 'package:medivision_app/core/constants/app_dimensions.dart';
import 'package:medivision_app/core/constants/app_typography.dart';
import 'package:medivision_app/core/widgets/custom_text_field.dart';
import 'package:medivision_app/core/widgets/primary_button.dart';
import 'package:medivision_app/features/vitals_activity/providers/vitals_provider.dart';

class SleepLogSheet extends ConsumerStatefulWidget {
  const SleepLogSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SleepLogSheet(),
    );
  }

  @override
  ConsumerState<SleepLogSheet> createState() => _SleepLogSheetState();
}

class _SleepLogSheetState extends ConsumerState<SleepLogSheet> {
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  late TextEditingController _deepHoursController;
  late TextEditingController _deepMinutesController;
  int _qualityScore = 89;

  @override
  void initState() {
    super.initState();
    final snapshot = ref.read(vitalsProvider).snapshot;
    final totalH = snapshot.sleepDurationMinutes ~/ 60;
    final totalM = snapshot.sleepDurationMinutes % 60;
    final deepH = snapshot.deepSleepMinutes ~/ 60;
    final deepM = snapshot.deepSleepMinutes % 60;

    _hoursController = TextEditingController(text: '$totalH');
    _minutesController = TextEditingController(text: '$totalM');
    _deepHoursController = TextEditingController(text: '$deepH');
    _deepMinutesController = TextEditingController(text: '$deepM');
    _qualityScore = snapshot.sleepQualityScore;
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _deepHoursController.dispose();
    _deepMinutesController.dispose();
    super.dispose();
  }

  void _saveSleep() {
    final h = int.tryParse(_hoursController.text) ?? 7;
    final m = int.tryParse(_minutesController.text) ?? 42;
    final dh = int.tryParse(_deepHoursController.text) ?? 1;
    final dm = int.tryParse(_deepMinutesController.text) ?? 48;

    final totalMin = (h * 60) + m;
    final deepMin = (dh * 60) + dm;

    ref.read(vitalsProvider.notifier).recordSleep(
      totalMinutes: totalMin,
      deepSleepMinutes: deepMin,
      qualityScore: _qualityScore,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sleep logged: ${h}h ${m}m (${dh}h ${dm}m Deep Sleep)'),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + keyboardPadding),
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
                        'Log Sleep Record',
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Record last night\'s rest & deep recovery stages',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentIndigo.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: const Icon(Icons.bedtime_rounded, size: 18, color: AppColors.accentIndigo),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Text(
                'Total Sleep Duration',
                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _hoursController,
                      label: 'Hours',
                      hintText: '7',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.schedule_rounded, size: 18, color: AppColors.textTertiary),
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Center(widthFactor: 1, child: Text('hrs', style: TextStyle(color: AppColors.textTertiary, fontSize: 12))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _minutesController,
                      label: 'Minutes',
                      hintText: '30',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.timer_outlined, size: 18, color: AppColors.textTertiary),
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Center(widthFactor: 1, child: Text('mins', style: TextStyle(color: AppColors.textTertiary, fontSize: 12))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Deep Sleep (Physical & Tissue Repair)',
                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _deepHoursController,
                      label: 'Deep Hours',
                      hintText: '1',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.nightlight_round, size: 18, color: AppColors.textTertiary),
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Center(widthFactor: 1, child: Text('hrs', style: TextStyle(color: AppColors.textTertiary, fontSize: 12))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _deepMinutesController,
                      label: 'Deep Minutes',
                      hintText: '45',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.timer_outlined, size: 18, color: AppColors.textTertiary),
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Center(widthFactor: 1, child: Text('mins', style: TextStyle(color: AppColors.textTertiary, fontSize: 12))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Sleep Quality Score: $_qualityScore%',
                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.accentIndigo,
                  thumbColor: AppColors.accentIndigo,
                  inactiveTrackColor: AppColors.border,
                ),
                child: Slider(
                  value: _qualityScore.toDouble(),
                  min: 40,
                  max: 100,
                  divisions: 60,
                  onChanged: (val) {
                    setState(() => _qualityScore = val.round());
                  },
                ),
              ),
              const SizedBox(height: 16),

              PrimaryButton(
                label: 'Save Sleep Record',
                icon: Icons.check_circle_outline_rounded,
                onPressed: _saveSleep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
