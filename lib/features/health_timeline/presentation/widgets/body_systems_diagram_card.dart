import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../ai_companion/providers/ai_companion_provider.dart';
import '../../../vitals_activity/providers/vitals_provider.dart';
import '../../models/physiological_systems_model.dart';
import '../../providers/physiological_systems_provider.dart';
import '../../providers/sensation_provider.dart';

class BodySystemsDiagramCard extends ConsumerStatefulWidget {
  const BodySystemsDiagramCard({super.key});

  @override
  ConsumerState<BodySystemsDiagramCard> createState() => _BodySystemsDiagramCardState();
}

class _BodySystemsDiagramCardState extends ConsumerState<BodySystemsDiagramCard> {
  HealthSystemType _selectedSystem = HealthSystemType.brainSleep;

  String _getSystemName(HealthSystemType type) {
    switch (type) {
      case HealthSystemType.brainSleep:
        return 'Sleep & Cognition';
      case HealthSystemType.heartPulse:
        return 'Cardiovascular';
      case HealthSystemType.staminaMovement:
        return 'Physical Activity';
      case HealthSystemType.bloodDefenses:
        return 'Hematology & Labs';
    }
  }

  Color _getSystemColor(HealthSystemType type) {
    switch (type) {
      case HealthSystemType.brainSleep:
        return AppColors.accentIndigo;
      case HealthSystemType.heartPulse:
        return AppColors.accentRose;
      case HealthSystemType.staminaMovement:
        return AppColors.secondary;
      case HealthSystemType.bloodDefenses:
        return AppColors.accentEmerald;
    }
  }

  IconData _getSystemIcon(HealthSystemType type) {
    switch (type) {
      case HealthSystemType.brainSleep:
        return Icons.psychology_outlined;
      case HealthSystemType.heartPulse:
        return Icons.monitor_heart_outlined;
      case HealthSystemType.staminaMovement:
        return Icons.directions_walk_rounded;
      case HealthSystemType.bloodDefenses:
        return Icons.shield_outlined;
    }
  }

  List<String> _getPresetSensations(HealthSystemType type) {
    switch (type) {
      case HealthSystemType.brainSleep:
        return [
          'Brain Fog',
          'Tension Headache',
          'Migraine Aura',
          'Insomnia / Restlessness',
          'Dizziness / Vertigo',
          'Mental Fatigue',
          'Grogginess',
          'Racing Thoughts',
        ];
      case HealthSystemType.heartPulse:
        return [
          'Chest Tightness',
          'Heart Palpitations',
          'Fluttering Sensation',
          'Rapid Heartbeat',
          'Shortness of Breath',
          'Chest Pressure / Discomfort',
          'Post-Exertion Fatigue',
        ];
      case HealthSystemType.staminaMovement:
        return [
          'Muscle Soreness',
          'Joint Stiffness',
          'Lower Back Tension',
          'Muscle Cramp',
          'Heavy / Fatigued Legs',
          'Neck & Trapezius Spasm',
          'Knee / Ankle Discomfort',
        ];
      case HealthSystemType.bloodDefenses:
        return [
          'Lethargy / Deep Fatigue',
          'Cold Chills',
          'Hot Flashes / Flushing',
          'Abdominal Bloating',
          'Nausea / Upset Stomach',
          'Dehydration Sensation',
          'Mild Feverish Feeling',
        ];
    }
  }

  String _getSystemBiomarkers(HealthSystemType type, dynamic vitals, [SystemClinicalData? data]) {
    if (data != null && data.keyPills.isNotEmpty) {
      return '${data.name}: ${data.keyPills.join(", ")}; Status: ${data.status} (${data.score}%); Clinical Note: ${data.headline}';
    }
    switch (type) {
      case HealthSystemType.brainSleep:
        return 'Sleep: ${vitals.formattedSleep}, Deep sleep: ${vitals.formattedDeepSleep}, Quality: ${vitals.sleepQualityScore}%';
      case HealthSystemType.heartPulse:
        return 'Resting HR: ${vitals.formattedPulse}, BP: ${vitals.formattedBP}, SpO2: ${vitals.bloodOxygenSpO2}%';
      case HealthSystemType.staminaMovement:
        return 'Steps walked: ${vitals.formattedSteps}, Active calories: ${vitals.activeCalories} kcal, Active minutes: ${vitals.activeMinutes}m';
      case HealthSystemType.bloodDefenses:
        return 'Oxygenation SpO2: ${vitals.bloodOxygenSpO2}%, Core Temp: ${vitals.bodyTemperature}°C';
    }
  }

  void _showSensationLogSheet(
    BuildContext context,
    HealthSystemType type,
    dynamic vitals, [
    SystemClinicalData? systemData,
  ]) {
    final systemName = _getSystemName(type);
    final systemColor = _getSystemColor(type);
    final systemIcon = _getSystemIcon(type);
    final presetSensations = _getPresetSensations(type);
    final biomarkerContext = _getSystemBiomarkers(type, vitals, systemData);

    String selectedSensation = presetSensations.first;
    final customController = TextEditingController();
    final notesController = TextEditingController();
    int severity = 3;
    final Set<String> selectedQualities = {};

    final qualityOptions = [
      'Dull Ache',
      'Sharp',
      'Throbbing',
      'Tightness',
      'Burning',
      'Tingling',
      'Spasm',
      'Stiffness',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final activeSensation = customController.text.trim().isNotEmpty
                ? customController.text.trim()
                : selectedSensation;

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusXL),
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
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
                      const SizedBox(height: 14),

                      // System Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: systemColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                            ),
                            child: Icon(systemIcon, color: systemColor, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Log Physiological Sensation',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Target: $systemName',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: systemColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Preset Sensation Chips
                      Text(
                        'Select Sensation / Symptom',
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: presetSensations.map((sens) {
                          final isSelected = selectedSensation == sens && customController.text.trim().isEmpty;
                          return ChoiceChip(
                            label: Text(sens),
                            selected: isSelected,
                            onSelected: (val) {
                              setSheetState(() {
                                selectedSensation = sens;
                                customController.clear();
                              });
                            },
                            selectedColor: systemColor.withValues(alpha: 0.18),
                            backgroundColor: AppColors.surfaceSubtle,
                            labelStyle: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? systemColor : AppColors.textPrimary,
                            ),
                            side: BorderSide(
                              color: isSelected ? systemColor : AppColors.border,
                              width: isSelected ? 1.2 : 0.8,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      // Custom Sensation Input
                      TextField(
                        controller: customController,
                        onChanged: (_) => setSheetState(() {}),
                        style: AppTypography.bodySmall,
                        decoration: InputDecoration(
                          hintText: 'Or type custom sensation...',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          prefixIcon: const Icon(Icons.edit_outlined, size: 16),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Severity Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Intensity / Strain Level',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: severity <= 3
                                  ? AppColors.secondary.withValues(alpha: 0.15)
                                  : (severity <= 6
                                      ? AppColors.warning.withValues(alpha: 0.15)
                                      : AppColors.error.withValues(alpha: 0.15)),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            ),
                            child: Text(
                              '$severity / 10 • ${severity <= 3 ? "Mild" : (severity <= 6 ? "Moderate" : "Severe")}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: severity <= 3
                                    ? AppColors.secondaryDark
                                    : (severity <= 6 ? AppColors.warning : AppColors.error),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: severity.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        activeColor: severity <= 3
                            ? AppColors.secondary
                            : (severity <= 6 ? AppColors.warning : AppColors.error),
                        onChanged: (val) {
                          setSheetState(() => severity = val.toInt());
                        },
                      ),
                      const SizedBox(height: 10),

                      // Sensation Characteristics Tags
                      Text(
                        'Sensation Characteristics',
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: qualityOptions.map((qual) {
                          final isSelected = selectedQualities.contains(qual);
                          return FilterChip(
                            label: Text(qual),
                            selected: isSelected,
                            onSelected: (val) {
                              setSheetState(() {
                                if (val) {
                                  selectedQualities.add(qual);
                                } else {
                                  selectedQualities.remove(qual);
                                }
                              });
                            },
                            selectedColor: AppColors.primary.withValues(alpha: 0.12),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Notes input
                      Text(
                        'Context / Notes (Optional)',
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: notesController,
                        maxLines: 2,
                        style: AppTypography.bodySmall,
                        decoration: InputDecoration(
                          hintText: 'e.g., Started after stairs, lasts ~10 mins...',
                          isDense: true,
                          contentPadding: const EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                ),
                              ),
                              onPressed: () {
                                ref.read(sensationProvider.notifier).addSensation(
                                      systemOrArea: systemName,
                                      sensation: activeSensation,
                                      severity: severity,
                                      qualityTags: selectedQualities.toList(),
                                      notes: notesController.text.trim().isNotEmpty
                                          ? notesController.text.trim()
                                          : null,
                                    );
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(
                                      'Logged $activeSensation ($severity/10) to $systemName timeline',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: const Text(
                                'Save Sensation',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                ),
                              ),
                              onPressed: () {
                                // 1. Save sensation
                                ref.read(sensationProvider.notifier).addSensation(
                                      systemOrArea: systemName,
                                      sensation: activeSensation,
                                      severity: severity,
                                      qualityTags: selectedQualities.toList(),
                                      notes: notesController.text.trim().isNotEmpty
                                          ? notesController.text.trim()
                                          : null,
                                    );
                                Navigator.pop(ctx);

                                // 2. Trigger real AI Clinical Companion
                                ref.read(aiCompanionProvider.notifier).sendSensationQuery(
                                      systemOrArea: systemName,
                                      sensation: activeSensation,
                                      severity: severity,
                                      qualityTags: selectedQualities.toList(),
                                      notes: notesController.text.trim().isNotEmpty
                                          ? notesController.text.trim()
                                          : null,
                                      biomarkerContext: biomarkerContext,
                                    );

                                // 3. Navigate directly to AI Companion
                                context.push('/ai-companion');
                              },
                              icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                              label: const Text(
                                'Ask Real AI',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _consultAiAboutSystem(
    BuildContext context,
    HealthSystemType type,
    dynamic vitals,
    SystemClinicalData data,
  ) {
    final systemName = _getSystemName(type);
    final biomarkerContext = _getSystemBiomarkers(type, vitals, data);

    ref.read(aiCompanionProvider.notifier).sendSensationQuery(
          systemOrArea: systemName,
          sensation: 'Physiological Overview: ${data.status}',
          severity: data.score < 80 ? 4 : 2,
          qualityTags: data.keyPills,
          notes: 'Clinical analysis of $systemName (${data.headline}). Recommendation: ${data.recommendation}',
          biomarkerContext: biomarkerContext,
        );

    context.push('/ai-companion');
  }

  @override
  Widget build(BuildContext context) {
    final vitals = ref.watch(vitalsProvider).snapshot;
    final sysState = ref.watch(physiologicalSystemsProvider);
    final assessment = sysState.assessment;
    final selectedSystemData = assessment.getSystem(_selectedSystem);

    final allSensations = ref.watch(sensationProvider);
    final selectedSystemName = _getSystemName(_selectedSystem);
    final systemSensations = allSensations
        .where((s) => s.systemOrArea.toLowerCase().contains(selectedSystemName.toLowerCase()))
        .toList();

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Physiological Systems',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: sysState.isLiveAi
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : AppColors.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 10,
                                color: sysState.isLiveAi ? AppColors.primary : AppColors.secondary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                sysState.isLiveAi ? 'AI FEED' : 'REAL DATA',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                  color: sysState.isLiveAi ? AppColors.primary : AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sysState.isLoading
                          ? 'AI is analyzing clinical telemetry & records...'
                          : 'Real patient vitals & lab biomarker synthesis',
                      style: AppTypography.bodySmall.copyWith(
                        color: sysState.isLoading ? AppColors.primary : AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      '${assessment.overallScore}% Optimal',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    tooltip: 'Refresh with Live AI',
                    onPressed: sysState.isLoading
                        ? null
                        : () {
                            ref
                                .read(physiologicalSystemsProvider.notifier)
                                .refreshAnalysis(forceAi: true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Feeding live vitals & records to MediVision AI...'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                    icon: sysState.isLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4-Node Interactive Diagram fed with real AI data
          Row(
            children: [
              Expanded(
                child: _DiagramNodeItem(
                  icon: Icons.psychology_outlined,
                  title: assessment.brainSleep.name,
                  score: '${assessment.brainSleep.score}%',
                  status: assessment.brainSleep.status,
                  color: AppColors.accentIndigo,
                  isSelected: _selectedSystem == HealthSystemType.brainSleep,
                  onTap: () => setState(() => _selectedSystem = HealthSystemType.brainSleep),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DiagramNodeItem(
                  icon: Icons.monitor_heart_outlined,
                  title: assessment.heartPulse.name,
                  score: '${assessment.heartPulse.score}%',
                  status: assessment.heartPulse.status,
                  color: AppColors.accentRose,
                  isSelected: _selectedSystem == HealthSystemType.heartPulse,
                  onTap: () => setState(() => _selectedSystem = HealthSystemType.heartPulse),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DiagramNodeItem(
                  icon: Icons.directions_walk_rounded,
                  title: assessment.staminaMovement.name,
                  score: '${assessment.staminaMovement.score}%',
                  status: assessment.staminaMovement.status,
                  color: AppColors.secondary,
                  isSelected: _selectedSystem == HealthSystemType.staminaMovement,
                  onTap: () => setState(() => _selectedSystem = HealthSystemType.staminaMovement),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DiagramNodeItem(
                  icon: Icons.shield_outlined,
                  title: assessment.bloodDefenses.name,
                  score: '${assessment.bloodDefenses.score}%',
                  status: assessment.bloodDefenses.status,
                  color: AppColors.accentEmerald,
                  isSelected: _selectedSystem == HealthSystemType.bloodDefenses,
                  onTap: () => setState(() => _selectedSystem = HealthSystemType.bloodDefenses),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Non-technical Plain-English AI Breakdown for selected system
          _buildSystemPlainExplanation(selectedSystemData, _getSystemColor(_selectedSystem)),
          const SizedBox(height: 12),

          // Log Sensation & Consult AI Action Bar
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _getSystemColor(_selectedSystem),
                    side: BorderSide(color: _getSystemColor(_selectedSystem), width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                  ),
                  onPressed: () => _showSensationLogSheet(
                    context,
                    _selectedSystem,
                    vitals,
                    selectedSystemData,
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                  label: const Text(
                    'Log Sensation',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                  ),
                  onPressed: () => _consultAiAboutSystem(
                    context,
                    _selectedSystem,
                    vitals,
                    selectedSystemData,
                  ),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 15),
                  label: const Text(
                    'Consult Real AI',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),

          // Logged Sensations for this system
          if (systemSensations.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent $selectedSystemName Sensations',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${systemSensations.length} logged',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...systemSensations.take(3).map((sens) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: sens.severityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${sens.severity}/10 ${sens.severityLabel}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: sens.severityColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sens.sensation,
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (sens.qualityTags.isNotEmpty)
                            Text(
                              sens.qualityTags.join(' • '),
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      DateFormatter.formatRelative(sens.timestamp),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.auto_awesome_rounded, size: 15, color: AppColors.primary),
                      tooltip: 'Ask AI',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      onPressed: () {
                        ref.read(aiCompanionProvider.notifier).sendSensationQuery(
                              systemOrArea: sens.systemOrArea,
                              sensation: sens.sensation,
                              severity: sens.severity,
                              qualityTags: sens.qualityTags,
                              notes: sens.notes,
                              biomarkerContext: _getSystemBiomarkers(
                                _selectedSystem,
                                vitals,
                                selectedSystemData,
                              ),
                            );
                        context.push('/ai-companion');
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemPlainExplanation(SystemClinicalData data, Color systemColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data.headline,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: systemColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  data.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: systemColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data.explanation,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          if (data.keyPills.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: data.keyPills.map((pill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    pill,
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (data.recommendation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.tips_and_updates_outlined,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      data.recommendation,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DiagramNodeItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String score;
  final String status;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _DiagramNodeItem({
    required this.icon,
    required this.title,
    required this.score,
    required this.status,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 18, color: color),
                Text(
                  score,
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            Text(
              status,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
