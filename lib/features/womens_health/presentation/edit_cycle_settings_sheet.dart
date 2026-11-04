import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/womens_health_provider.dart';

class EditCycleSettingsSheet extends ConsumerStatefulWidget {
  const EditCycleSettingsSheet({super.key});

  @override
  ConsumerState<EditCycleSettingsSheet> createState() => _EditCycleSettingsSheetState();
}

class _EditCycleSettingsSheetState extends ConsumerState<EditCycleSettingsSheet> {
  late DateTime _lastPeriodStartDate;
  late int _averageCycleLength;
  late int _averagePeriodDuration;

  @override
  void initState() {
    super.initState();
    final cycle = ref.read(womensHealthProvider).cycleData;
    _lastPeriodStartDate = cycle.lastPeriodStartDate;
    _averageCycleLength = cycle.averageCycleLength;
    _averagePeriodDuration = cycle.averagePeriodDuration;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodStartDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _lastPeriodStartDate = picked;
      });
    }
  }

  void _saveSettings() {
    ref.read(womensHealthProvider.notifier).updateCycleDetails(
          averageCycleLength: _averageCycleLength,
          averagePeriodDuration: _averagePeriodDuration,
          lastPeriodStartDate: _lastPeriodStartDate,
        );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menstrual cycle parameters saved and re-calculated.'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
      ),
      child: SafeArea(
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menstrual Cycle Parameters',
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Calibrates ovulatory predictions and pattern analysis',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 20),

            // Last Period Start Date
            Text(
              'Last Period Start Date',
              style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('EEEE, MMM d, yyyy').format(_lastPeriodStartDate),
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Icon(Icons.edit_calendar_outlined, size: 18, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Average Cycle Length
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Average Cycle Length',
                  style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '$_averageCycleLength Days',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: _averageCycleLength.toDouble(),
              min: 21,
              max: 45,
              divisions: 24,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.surfaceSubtle,
              label: '$_averageCycleLength days',
              onChanged: (val) {
                setState(() {
                  _averageCycleLength = val.toInt();
                });
              },
            ),
            const SizedBox(height: 12),

            // Period Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bleeding / Period Duration',
                  style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '$_averagePeriodDuration Days',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.accentRose,
                  ),
                ),
              ],
            ),
            Slider(
              value: _averagePeriodDuration.toDouble(),
              min: 2,
              max: 10,
              divisions: 8,
              activeColor: AppColors.accentRose,
              inactiveColor: AppColors.surfaceSubtle,
              label: '$_averagePeriodDuration days',
              onChanged: (val) {
                setState(() {
                  _averagePeriodDuration = val.toInt();
                });
              },
            ),
            const SizedBox(height: 20),

            PrimaryButton(
              label: 'Save Real Cycle Parameters',
              icon: Icons.check_circle_outline_rounded,
              onPressed: _saveSettings,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

