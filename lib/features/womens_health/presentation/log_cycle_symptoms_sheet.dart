import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../models/cycle_data_model.dart';
import '../models/symptom_log_model.dart';
import '../providers/womens_health_provider.dart';

class LogCycleSymptomsSheet extends ConsumerStatefulWidget {
  const LogCycleSymptomsSheet({super.key});

  @override
  ConsumerState<LogCycleSymptomsSheet> createState() => _LogCycleSymptomsSheetState();
}

class _LogCycleSymptomsSheetState extends ConsumerState<LogCycleSymptomsSheet> {
  PeriodFlow _flow = PeriodFlow.none;
  double _crampsSeverity = 0;
  double _pelvicPainSeverity = 0;
  String _mood = 'Calm';
  final Set<String> _selectedSymptoms = {};
  final Set<String> _selectedPcosObservations = {};
  late TextEditingController _tempController;
  String _cervicalMucus = 'Egg-white (Fertile)';
  late TextEditingController _notesController;
  bool _isPeriodStart = false;

  final List<String> _moodOptions = [
    'Calm',
    'Energetic',
    'Sensitive',
    'Irritable',
    'Anxious',
    'Low / Sad',
    'Fatigued',
  ];

  final List<String> _symptomOptions = [
    'Mild Bloating',
    'Severe Bloating',
    'Headache',
    'Tender Breasts',
    'Lower Back Pain',
    'Nausea',
    'Hot Flashes',
    'Fatigue',
    'Sleep Disruption',
  ];

  final List<String> _pcosOptionList = [
    'Jawline / Cystic Breakout',
    'Facial / Body Hair Coarseness',
    'Scalp Hair Thinning',
    'Intense Sugar / Carb Cravings',
    'Post-Meal Sluggishness',
  ];

  final List<String> _mucusOptions = [
    'Dry',
    'Sticky',
    'Creamy',
    'Egg-white (Fertile)',
    'Watery',
  ];

  @override
  void initState() {
    super.initState();
    final todayLog = ref.read(womensHealthProvider).todayLog;
    if (todayLog != null) {
      _flow = todayLog.flow;
      _crampsSeverity = todayLog.crampsSeverity.toDouble();
      _pelvicPainSeverity = todayLog.pelvicPainSeverity.toDouble();
      _mood = todayLog.mood;
      _selectedSymptoms.addAll(todayLog.physicalSymptoms);
      _selectedPcosObservations.addAll(todayLog.pcosObservations);
      _tempController = TextEditingController(
        text: todayLog.basalBodyTemp != null ? todayLog.basalBodyTemp!.toStringAsFixed(1) : '',
      );
      _cervicalMucus = todayLog.cervicalMucus ?? 'Egg-white (Fertile)';
      _notesController = TextEditingController(text: todayLog.notes ?? '');
    } else {
      _tempController = TextEditingController(text: '');
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _tempController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveLog() async {
    final log = DailySymptomLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      flow: _flow,
      crampsSeverity: _crampsSeverity.toInt(),
      pelvicPainSeverity: _pelvicPainSeverity.toInt(),
      mood: _mood,
      physicalSymptoms: _selectedSymptoms.toList(),
      pcosObservations: _selectedPcosObservations.toList(),
      basalBodyTemp: double.tryParse(_tempController.text),
      cervicalMucus: _cervicalMucus,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    await ref.read(womensHealthProvider.notifier).logDailySymptoms(
          log,
          isPeriodStart: _isPeriodStart,
        );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Today\'s symptoms and reproductive indicators securely saved.'),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
      ),
      child: Column(
        children: [
          // Drag handle
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Reproductive Log',
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Real-time hormonal, fertility & clinical tracking',
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
          const Divider(),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Period Flow
                  Text(
                    'Menstrual Flow',
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: PeriodFlow.values.map((flow) {
                      final isSelected = _flow == flow;
                      return ChoiceChip(
                        label: Text(flow.label),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _flow = flow;
                              if (flow == PeriodFlow.heavy || flow == PeriodFlow.medium) {
                                _isPeriodStart = true;
                              }
                            });
                          }
                        },
                        selectedColor: AppColors.accentRose,
                        backgroundColor: AppColors.surfaceSubtle,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.accentRose : AppColors.border,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),

                  // Period Start Switch
                  if (_flow != PeriodFlow.none)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.water_drop_rounded, size: 18, color: AppColors.accentRose),
                              const SizedBox(width: 8),
                              Text(
                                'Mark as Day 1 of Period',
                                style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isPeriodStart,
                            activeColor: AppColors.accentRose,
                            onChanged: (val) => setState(() => _isPeriodStart = val),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 2. Dysmenorrhea Cramps Scale (0 to 5)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Menstrual Cramps Severity',
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${_crampsSeverity.toInt()} / 5 (${_crampsSeverity >= 4 ? "Severe" : _crampsSeverity >= 2 ? "Moderate" : _crampsSeverity > 0 ? "Mild" : "None"})',
                        style: AppTypography.labelSmall.copyWith(
                          color: _crampsSeverity >= 4 ? AppColors.accentRose : AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _crampsSeverity,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    activeColor: _crampsSeverity >= 4 ? AppColors.accentRose : AppColors.secondary,
                    onChanged: (val) => setState(() => _crampsSeverity = val),
                  ),
                  const SizedBox(height: 14),

                  // 3. Chronic / Non-Menstrual Pelvic Pain (Endometriosis screening)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Non-Menstrual Pelvic Pain',
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${_pelvicPainSeverity.toInt()} / 5',
                        style: AppTypography.labelSmall.copyWith(
                          color: _pelvicPainSeverity >= 3 ? AppColors.accentRose : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _pelvicPainSeverity,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    activeColor: AppColors.accentIndigo,
                    onChanged: (val) => setState(() => _pelvicPainSeverity = val),
                  ),
                  const SizedBox(height: 16),

                  // 4. Mood & Emotional State
                  Text(
                    'Mood & Emotional State',
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _moodOptions.map((mood) {
                      final isSelected = _mood == mood;
                      return ChoiceChip(
                        label: Text(mood),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => _mood = mood);
                        },
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceSubtle,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 5. Physical Symptoms
                  Text(
                    'Physical Symptoms',
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _symptomOptions.map((sym) {
                      final isSelected = _selectedSymptoms.contains(sym);
                      return FilterChip(
                        label: Text(sym),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _selectedSymptoms.add(sym);
                            } else {
                              _selectedSymptoms.remove(sym);
                            }
                          });
                        },
                        selectedColor: AppColors.secondary,
                        backgroundColor: AppColors.surfaceSubtle,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.secondary : AppColors.border,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 6. PCOS / Androgenic Screening Observations
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.biotech_rounded, size: 18, color: AppColors.secondaryDark),
                            const SizedBox(width: 8),
                            Text(
                              'PCOS & Hyperandrogenism Indicators',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.secondaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select any signs observed today (used to assess Rotterdam androgenic patterns):',
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _pcosOptionList.map((pcos) {
                            final isSelected = _selectedPcosObservations.contains(pcos);
                            return FilterChip(
                              label: Text(pcos),
                              selected: isSelected,
                              onSelected: (val) {
                                setState(() {
                                  if (val) {
                                    _selectedPcosObservations.add(pcos);
                                  } else {
                                    _selectedPcosObservations.remove(pcos);
                                  }
                                });
                              },
                              selectedColor: AppColors.secondaryDark,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                fontSize: 12,
                              ),
                              side: BorderSide(
                                color: isSelected ? AppColors.secondaryDark : AppColors.border,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 7. Basal Body Temperature & Cervical Mucus (Fertility / Ovulation Tracking)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Basal Temp (°C)',
                              style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _tempController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: 'e.g. 36.6',
                                prefixIcon: const Icon(Icons.thermostat_rounded, size: 20),
                                filled: true,
                                fillColor: AppColors.surfaceSubtle,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cervical Fluid',
                              style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _cervicalMucus,
                              items: _mucusOptions.map((opt) {
                                return DropdownMenuItem(value: opt, child: Text(opt, style: const TextStyle(fontSize: 13)));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _cervicalMucus = val);
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.surfaceSubtle,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 8. Personal Clinical Note
                  Text(
                    'Notes / Gynecological Observations',
                    style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    style: AppTypography.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Any medication taken, mid-cycle twinge, or specific observations...',
                      filled: true,
                      fillColor: AppColors.surfaceSubtle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          PrimaryButton(
            label: 'Save Reproductive Log',
            icon: Icons.check_circle_outline_rounded,
            onPressed: _saveLog,
          ),
        ],
      ),
    );
  }
}
