import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medivision_app/core/constants/app_colors.dart';
import 'package:medivision_app/core/constants/app_dimensions.dart';
import 'package:medivision_app/core/constants/app_typography.dart';
import 'package:medivision_app/core/widgets/custom_text_field.dart';
import 'package:medivision_app/core/widgets/primary_button.dart';
import 'package:medivision_app/features/vitals_activity/providers/vitals_provider.dart';

class ScreenTimeSheet extends ConsumerStatefulWidget {
  const ScreenTimeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ScreenTimeSheet(),
    );
  }

  @override
  ConsumerState<ScreenTimeSheet> createState() => _ScreenTimeSheetState();
}

class _ScreenTimeSheetState extends ConsumerState<ScreenTimeSheet> {
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  late TextEditingController _pickupsController;

  @override
  void initState() {
    super.initState();
    final snapshot = ref.read(vitalsProvider).snapshot;
    _hoursController = TextEditingController(text: '${snapshot.screenTimeMinutes ~/ 60}');
    _minutesController = TextEditingController(text: '${snapshot.screenTimeMinutes % 60}');
    _pickupsController = TextEditingController(text: '${snapshot.screenPickups}');
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _pickupsController.dispose();
    super.dispose();
  }

  void _saveScreenTime() {
    final h = int.tryParse(_hoursController.text) ?? 3;
    final m = int.tryParse(_minutesController.text) ?? 15;
    final p = int.tryParse(_pickupsController.text) ?? 48;

    final totalMin = (h * 60) + m;

    ref.read(vitalsProvider.notifier).recordScreenTime(
      minutes: totalMin,
      pickups: p,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Screen time updated: ${h}h ${m}m ($p device pickups)'),
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
                        'Screen Time & Wellbeing',
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Digital exposure and pre-sleep blue light impact',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentAmber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: const Icon(Icons.phone_android_rounded, size: 18, color: AppColors.accentAmber),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Text(
                'Total Screen Exposure Today',
                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _hoursController,
                      label: 'Hours',
                      hintText: '3',
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
                      hintText: '15',
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
              const SizedBox(height: 14),

              CustomTextField(
                controller: _pickupsController,
                label: 'Device Pickups / Checks',
                hintText: '40',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.touch_app_outlined, size: 18, color: AppColors.textTertiary),
                suffixIcon: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Center(widthFactor: 1, child: Text('times', style: TextStyle(color: AppColors.textTertiary, fontSize: 12))),
                ),
              ),
              const SizedBox(height: 18),

              PrimaryButton(
                label: 'Save Screen Time',
                icon: Icons.check_circle_outline_rounded,
                onPressed: _saveScreenTime,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
