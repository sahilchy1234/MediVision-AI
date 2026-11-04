import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medivision_app/core/constants/app_colors.dart';
import 'package:medivision_app/core/constants/app_dimensions.dart';
import 'package:medivision_app/core/constants/app_typography.dart';
import 'package:medivision_app/core/widgets/custom_text_field.dart';
import 'package:medivision_app/core/widgets/primary_button.dart';
import 'package:medivision_app/features/vitals_activity/providers/vitals_provider.dart';

class PulseMeasurementSheet extends ConsumerStatefulWidget {
  const PulseMeasurementSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PulseMeasurementSheet(),
    );
  }

  @override
  ConsumerState<PulseMeasurementSheet> createState() => _PulseMeasurementSheetState();
}

class _PulseMeasurementSheetState extends ConsumerState<PulseMeasurementSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<DateTime> _tapTimestamps = [];
  int _calculatedBpm = 0;
  bool _isMeasuring = false;
  Timer? _idleTimer;

  // Manual entry controllers
  late TextEditingController _bpmController;
  late TextEditingController _sysController;
  late TextEditingController _diaController;
  late TextEditingController _spo2Controller;
  late TextEditingController _tempController;

  @override
  void initState() {
    super.initState();
    final snapshot = ref.read(vitalsProvider).snapshot;
    _calculatedBpm = snapshot.restingHeartRate;
    _bpmController = TextEditingController(text: '${snapshot.restingHeartRate}');
    _sysController = TextEditingController(text: '${snapshot.bloodPressureSystolic}');
    _diaController = TextEditingController(text: '${snapshot.bloodPressureDiastolic}');
    _spo2Controller = TextEditingController(text: '${snapshot.bloodOxygenSpO2}');
    _tempController = TextEditingController(text: '${snapshot.bodyTemperature}');

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _idleTimer?.cancel();
    _bpmController.dispose();
    _sysController.dispose();
    _diaController.dispose();
    _spo2Controller.dispose();
    _tempController.dispose();
    super.dispose();
  }

  void _onPulseTap() {
    final now = DateTime.now();
    _animController.forward(from: 0.0);

    setState(() {
      _isMeasuring = true;
      _tapTimestamps.add(now);

      // Keep last 10 taps for accurate moving average
      if (_tapTimestamps.length > 10) {
        _tapTimestamps.removeAt(0);
      }

      if (_tapTimestamps.length >= 2) {
        double totalDiffSeconds = 0;
        for (int i = 1; i < _tapTimestamps.length; i++) {
          totalDiffSeconds += _tapTimestamps[i].difference(_tapTimestamps[i - 1]).inMilliseconds / 1000.0;
        }
        final avgInterval = totalDiffSeconds / (_tapTimestamps.length - 1);
        if (avgInterval > 0.25 && avgInterval < 2.0) {
          final bpm = (60.0 / avgInterval).round().clamp(45, 180);
          _calculatedBpm = bpm;
          _bpmController.text = '$bpm';
        }
      }
    });

    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isMeasuring = false;
        });
      }
    });
  }

  void _saveVitals() {
    final bpm = int.tryParse(_bpmController.text) ?? _calculatedBpm;
    final sys = int.tryParse(_sysController.text);
    final dia = int.tryParse(_diaController.text);
    final spo2 = int.tryParse(_spo2Controller.text);
    final temp = double.tryParse(_tempController.text);

    ref.read(vitalsProvider.notifier).recordPulse(
      bpm: bpm,
      systolic: sys,
      diastolic: dia,
      spO2: spo2,
      temperature: temp,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vitals updated: $bpm bpm • ${sys ?? 120}/${dia ?? 80} mmHg • SpO2 ${spo2 ?? 98}%'),
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
                        'Measure & Log Vitals',
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap sensor or enter latest readings',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentRose.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite_rounded, size: 14, color: AppColors.accentRose),
                        const SizedBox(width: 4),
                        Text(
                          '$_calculatedBpm BPM',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.accentRose,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Interactive Tap-to-Measure Pulse Sensor
              Center(
                child: GestureDetector(
                  onTap: _onPulseTap,
                  child: AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      final scale = 1.0 + (_animController.value * 0.12);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.accentRose.withValues(alpha: _isMeasuring ? 0.3 : 0.15),
                                AppColors.accentRose.withValues(alpha: 0.05),
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.accentRose.withValues(alpha: _isMeasuring ? 0.8 : 0.3),
                              width: _isMeasuring ? 3 : 1.5,
                            ),
                            boxShadow: _isMeasuring
                                ? [
                                    BoxShadow(
                                      color: AppColors.accentRose.withValues(alpha: 0.25),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fingerprint_rounded,
                                size: 42,
                                color: _isMeasuring ? AppColors.accentRose : AppColors.textTertiary,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _isMeasuring ? 'Tap with Pulse' : 'Tap to Measure',
                                style: AppTypography.labelSmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _isMeasuring ? AppColors.accentRose : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _tapTimestamps.length < 2
                      ? 'Place your finger on your wrist or neck pulse and tap in sync.'
                      : 'Detecting rhythm... ${_tapTimestamps.length} beats recorded',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 18),

              // Clinical Inputs Grid
              Text(
                'Clinical Values',
                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _bpmController,
                      label: 'Heart Rate',
                      hintText: '60-100',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.monitor_heart_outlined, size: 18, color: AppColors.textTertiary),
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Center(widthFactor: 1, child: Text('bpm', style: TextStyle(color: AppColors.textTertiary, fontSize: 12))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _spo2Controller,
                      label: 'Blood Oxygen',
                      hintText: '95-100',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.water_drop_outlined, size: 18, color: AppColors.textTertiary),
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Center(widthFactor: 1, child: Text('%', style: TextStyle(color: AppColors.textTertiary, fontSize: 12))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _sysController,
                      label: 'Systolic BP',
                      hintText: '110-120',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.speed_rounded, size: 18, color: AppColors.textTertiary),
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Center(widthFactor: 1, child: Text('mmHg', style: TextStyle(color: AppColors.textTertiary, fontSize: 12))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _diaController,
                      label: 'Diastolic BP',
                      hintText: '70-80',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.speed_rounded, size: 18, color: AppColors.textTertiary),
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Center(widthFactor: 1, child: Text('mmHg', style: TextStyle(color: AppColors.textTertiary, fontSize: 12))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _tempController,
                      label: 'Body Temp',
                      hintText: '36.5 - 37.2',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: const Icon(Icons.thermostat_rounded, size: 18, color: AppColors.textTertiary),
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Center(widthFactor: 1, child: Text('°C', style: TextStyle(color: AppColors.textTertiary, fontSize: 12))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              PrimaryButton(
                label: 'Save Vitals to Medical History',
                icon: Icons.check_circle_outline_rounded,
                onPressed: _saveVitals,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
