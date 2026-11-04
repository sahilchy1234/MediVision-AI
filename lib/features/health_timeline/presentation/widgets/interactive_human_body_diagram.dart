import 'package:flutter/material.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart';
import 'package:bodychart_heatmap/bodychart_heatmap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';

enum BodyDiagramSubMode {
  muscleAtlas,
  heatmap,
  regionalZones,
}

class InteractiveHumanBodyDiagram extends StatefulWidget {
  const InteractiveHumanBodyDiagram({super.key});

  @override
  State<InteractiveHumanBodyDiagram> createState() =>
      _InteractiveHumanBodyDiagramState();
}

class _InteractiveHumanBodyDiagramState
    extends State<InteractiveHumanBodyDiagram> {
  BodyDiagramSubMode _subMode = BodyDiagramSubMode.muscleAtlas;

  // Muscle Atlas state
  AtlasAsset _atlasView = AtlasAsset.musclesFront;
  MuscleInfo? _selectedMuscle;

  // Default highlighted muscles (e.g. from active recovery / posture tracking)
  final Set<String> _engagedMuscleIds = {
    'pectoralis_major_l',
    'pectoralis_major_r',
    'rectus_abdominis_1',
    'rectus_abdominis_2',
    'biceps_brachii_caput_longum_l',
    'biceps_brachii_caput_longum_r',
  };

  // Body Heatmap state (0 = calm, 1-10 = strain/fatigue level)
  final Map<String, int> _heatmapValues = {
    'neck': 2,
    'shoulder': 6,
    'chest': 1,
    'arm': 3,
    'abs': 1,
    'back': 5,
    'butt': 2,
    'leg': 4,
  };

  // Regional Zones selection state
  final Set<String> _selectedRegions = {'shoulder', 'back'};
  BodyViewType _bodyViewType = BodyViewType.both;

  @override
  void initState() {
    super.initState();
    // Default selected muscle: chest or trapezius
    _selectedMuscle = MuscleCatalog.tryById('pectoralis_major_l');
  }

  void _onAtlasTapped(MuscleInfo muscle) {
    setState(() {
      _selectedMuscle = muscle;
    });
  }

  void _toggleRegion(String regionKey) {
    setState(() {
      if (regionKey == 'full body') {
        if (_selectedRegions.contains('full body')) {
          _selectedRegions.clear();
        } else {
          _selectedRegions.addAll([
            'neck',
            'shoulder',
            'chest',
            'arm',
            'abs',
            'leg',
            'butt',
            'back',
            'full body',
          ]);
        }
      } else {
        if (_selectedRegions.contains(regionKey)) {
          _selectedRegions.remove(regionKey);
          _selectedRegions.remove('full body');
        } else {
          _selectedRegions.add(regionKey);
        }
      }
    });
  }

  void _showQuickLogDialog(String bodyAreaName) {
    int severity = 3;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusXL),
                ),
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusM,
                            ),
                          ),
                          child: const Icon(
                            Icons.accessibility_new_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Log Sensation / Strain',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Target Area: $bodyAreaName',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.secondaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'How does this area feel right now?',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1 - Barely noticeable',
                            style: AppTypography.labelSmall),
                        Text('10 - Intense pain',
                            style: AppTypography.labelSmall),
                      ],
                    ),
                    Slider(
                      value: severity.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: severity > 6
                          ? AppColors.error
                          : (severity > 3
                              ? AppColors.warning
                              : AppColors.secondary),
                      label: '$severity / 10',
                      onChanged: (val) {
                        setSheetState(() => severity = val.toInt());
                      },
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            severity > 6
                                ? Icons.warning_amber_rounded
                                : Icons.info_outline_rounded,
                            size: 18,
                            color: severity > 6
                                ? AppColors.error
                                : AppColors.secondaryDark,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              severity <= 3
                                  ? 'Mild stiffness or standard post-exercise tension.'
                                  : (severity <= 6
                                      ? 'Noticeable strain. Rest, gentle stretching, or warm compress recommended.'
                                      : 'High discomfort. Monitor closely; consult a clinician if persistent.'),
                              style: AppTypography.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusM),
                          ),
                        ),
                        onPressed: () {
                          // Update local heatmap if key matches
                          final lower = bodyAreaName.toLowerCase();
                          for (final key in _heatmapValues.keys) {
                            if (lower.contains(key)) {
                              setState(() {
                                _heatmapValues[key] = severity;
                              });
                              break;
                            }
                          }
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                'Logged $severity/10 tension for $bodyAreaName',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text('Save Sensation Log',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Prevent unlaid-out background rendering when this tab is offstage in IndexedStack
    if (!TickerMode.of(context)) {
      return const SizedBox.shrink();
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: AppDimensions.radiusXL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: const Icon(
                  Icons.accessibility_new_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interactive Human Body',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Tap any region to examine muscle balance, strain, and non-technical advice',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sub-Mode Switcher Pills (Muscle Atlas | Strain Heatmap | Regional Zones)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSubTab(
                    label: 'Muscle Atlas',
                    icon: Icons.grain_rounded,
                    isSelected: _subMode == BodyDiagramSubMode.muscleAtlas,
                    onTap: () => setState(
                        () => _subMode = BodyDiagramSubMode.muscleAtlas),
                  ),
                ),
                Expanded(
                  child: _buildSubTab(
                    label: 'Heatmap',
                    icon: Icons.local_fire_department_rounded,
                    isSelected: _subMode == BodyDiagramSubMode.heatmap,
                    onTap: () =>
                        setState(() => _subMode = BodyDiagramSubMode.heatmap),
                  ),
                ),
                Expanded(
                  child: _buildSubTab(
                    label: 'Body Zones',
                    icon: Icons.layers_outlined,
                    isSelected: _subMode == BodyDiagramSubMode.regionalZones,
                    onTap: () => setState(
                        () => _subMode = BodyDiagramSubMode.regionalZones),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // View Controls (Front / Back / Both)
          _buildViewAngleControls(),
          const SizedBox(height: 16),

          // Interactive Visual Canvas Container
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 330),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: _buildVisualBodyWidget(),
            ),
          ),
          const SizedBox(height: 16),

          // Ergonomic Non-Technical Insight Card
          _buildInsightCard(),
        ],
      ),
    );
  }

  Widget _buildSubTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAngleControls() {
    if (_subMode == BodyDiagramSubMode.muscleAtlas) {
      final isFront = _atlasView == AtlasAsset.musclesFront;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSmallPill(
                label: 'Front View',
                isSelected: isFront,
                onTap: () => setState(() {
                  _atlasView = AtlasAsset.musclesFront;
                }),
              ),
              const SizedBox(width: 8),
              _buildSmallPill(
                label: 'Back View',
                isSelected: !isFront,
                onTap: () => setState(() {
                  _atlasView = AtlasAsset.musclesBack;
                }),
              ),
            ],
          ),
          if (_selectedMuscle != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                _selectedMuscle!.displayName,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      );
    } else if (_subMode == BodyDiagramSubMode.regionalZones) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSmallPill(
                label: 'Front',
                isSelected: _bodyViewType == BodyViewType.front,
                onTap: () =>
                    setState(() => _bodyViewType = BodyViewType.front),
              ),
              const SizedBox(width: 6),
              _buildSmallPill(
                label: 'Back',
                isSelected: _bodyViewType == BodyViewType.back,
                onTap: () =>
                    setState(() => _bodyViewType = BodyViewType.back),
              ),
              const SizedBox(width: 6),
              _buildSmallPill(
                label: 'Both',
                isSelected: _bodyViewType == BodyViewType.both,
                onTap: () =>
                    setState(() => _bodyViewType = BodyViewType.both),
              ),
            ],
          ),
          Text(
            '${_selectedRegions.length} selected',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else {
      // Heatmap view
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Live Strain & Recovery Gradient',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Text(
              'Intensity Scale: 1–10',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildSmallPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary
              : AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildVisualBodyWidget() {
    switch (_subMode) {
      case BodyDiagramSubMode.muscleAtlas:
        final colorMap = <MuscleInfo, Color>{};

        // Engaged / active recovery muscle highlights
        for (final id in _engagedMuscleIds) {
          final m = MuscleCatalog.tryById(id);
          if (m != null) {
            colorMap[m] = const Color(0xFF64748B); // neutral steel
          }
        }

        // Selected muscle highlighted in vibrant teal
        if (_selectedMuscle != null) {
          colorMap[_selectedMuscle!] = AppColors.secondary;
        }

        return SizedBox(
          width: 300,
          height: 330,
          child: ExcludeSemantics(
            child: BodyAtlasView<MuscleInfo>(
              view: _atlasView,
              resolver: const MuscleResolver(),
              colorMapping: colorMap,
              onTapElement: _onAtlasTapped,
            ),
          ),
        );

      case BodyDiagramSubMode.heatmap:
        return Column(
          children: [
            BodyHeatmap(
              selectedParts: _heatmapValues,
              baseColor: AppColors.secondary,
              unselectedColor: const Color(0xFFE2E8F0),
              width: 280,
              showLegend: true,
              legendTextStyle: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              legendAlignment: MainAxisAlignment.center,
              intensityLevels: 3,
            ),
            const SizedBox(height: 12),
            // Quick taps for heat areas
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: _heatmapValues.entries.map((entry) {
                final isStrained = entry.value >= 5;
                return ActionChip(
                  avatar: CircleAvatar(
                    radius: 5,
                    backgroundColor: isStrained
                        ? AppColors.error
                        : AppColors.secondary,
                  ),
                  label: Text('${entry.key.toUpperCase()} (${entry.value}/10)'),
                  labelStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: isStrained
                      ? const Color(0xFFFFEDEC)
                      : AppColors.surfaceSubtle,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                    side: BorderSide(
                      color: isStrained
                          ? AppColors.error.withOpacity(0.3)
                          : AppColors.border,
                    ),
                  ),
                  onPressed: () => _showQuickLogDialog(entry.key),
                );
              }).toList(),
            ),
          ],
        );

      case BodyDiagramSubMode.regionalZones:
        return Column(
          children: [
            BodyChart(
              selectedParts: _selectedRegions,
              selectedColor: AppColors.secondary,
              unselectedColor: const Color(0xFFE2E8F0),
              viewType: _bodyViewType,
              width: _bodyViewType == BodyViewType.both ? 250 : 170,
            ),
            const SizedBox(height: 14),
            // Interactive regional chips to multi-select or single-select
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                'neck',
                'shoulder',
                'chest',
                'arm',
                'abs',
                'back',
                'butt',
                'leg',
                'full body'
              ].map((region) {
                final isSelected = _selectedRegions.contains(region);
                return FilterChip(
                  label: Text(region.toUpperCase()),
                  selected: isSelected,
                  selectedColor: AppColors.secondaryContainer,
                  checkmarkColor: AppColors.secondaryDark,
                  labelStyle: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.secondaryDark
                        : AppColors.textPrimary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                    side: BorderSide(
                      color:
                          isSelected ? AppColors.secondary : AppColors.border,
                    ),
                  ),
                  onSelected: (_) => _toggleRegion(region),
                );
              }).toList(),
            ),
          ],
        );
    }
  }

  Widget _buildInsightCard() {
    String title;
    String regionName;
    String plainEnglishSummary;
    String tip;

    if (_subMode == BodyDiagramSubMode.muscleAtlas) {
      if (_selectedMuscle != null) {
        regionName = _selectedMuscle!.displayName;
        final group = _selectedMuscle!.group.id.toUpperCase();
        title = '$regionName ($group)';
        plainEnglishSummary = _getMuscleExplanation(_selectedMuscle!);
        tip = _getMuscleErgonomicTip(_selectedMuscle!);
      } else {
        regionName = 'No muscle selected';
        title = 'Select a Muscle on the Atlas';
        plainEnglishSummary =
            'Tap any muscle on the anatomical diagram above to inspect how it functions, check its balance score, and get personalized recommendations.';
        tip = 'Try tapping the chest, shoulders, or legs to inspect them.';
      }
    } else if (_subMode == BodyDiagramSubMode.heatmap) {
      regionName = 'Whole Body Strain Profile';
      title = 'Fatigue & Muscle Soreness Heatmap';
      plainEnglishSummary =
          'Your neck and lower back are showing moderate fatigue (6/10), typical of extended desk posture or screen focus. Your legs and core are fully rested and energized.';
      tip =
          'Recommended: Take a 3-minute walking break every 90 minutes and do gentle shoulder shrugs.';
    } else {
      if (_selectedRegions.isEmpty) {
        regionName = 'No region selected';
        title = 'Select Body Regions';
        plainEnglishSummary =
            'Select any body area (like shoulders, back, or legs) using the diagram or chips above to see focused health insights.';
        tip = 'You can select multiple zones at once to check related areas.';
      } else {
        regionName = _selectedRegions.join(', ').toUpperCase();
        title = 'Targeted Areas: $regionName';
        plainEnglishSummary =
            'Focusing on ${_selectedRegions.length} anatomical zone(s). Healthy blood flow and good mobility recorded with zero critical clinical flags.';
        tip =
            'Regular active mobility keeps these areas flexible and reduces everyday tension.';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            plainEnglishSummary,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: AppColors.secondaryDark,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ergonomic Tip: $tip',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.secondaryDark,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusM),
                    ),
                  ),
                  onPressed: () => _showQuickLogDialog(regionName),
                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                  label: const Text(
                    'Log Sensation',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusM),
                    ),
                  ),
                  onPressed: () {
                    // Navigate to AI companion with context
                    context.push('/ai-companion');
                  },
                  icon: const Icon(Icons.auto_awesome, size: 15),
                  label: const Text(
                    'Ask AI Companion',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMuscleExplanation(MuscleInfo muscle) {
    final name = muscle.displayName.toLowerCase();
    if (name.contains('pectoralis') || name.contains('chest')) {
      return 'The chest muscles assist with pushing and deep breathing. Your heart and respiratory rates show smooth resting rhythms with zero chest constriction.';
    } else if (name.contains('abdominis') || name.contains('oblique')) {
      return 'Your core muscles provide spine stability and posture. Steady abdominal wall tone supports healthy digestion and spine alignment.';
    } else if (name.contains('biceps') || name.contains('triceps') || name.contains('brachii')) {
      return 'Your upper arm muscles facilitate lifting and reach. Muscle coordination is fluid with zero reported nerve pinching or joint numbness.';
    } else if (name.contains('trapezius') || name.contains('deltoid')) {
      return 'Shoulder and neck stabilizers. These are the most common muscles to tighten during sustained computer work or emotional stress.';
    } else if (name.contains('latissimus') || name.contains('back')) {
      return 'The large back muscles support pulling movements and upright spine posture. Maintaining back strength prevents lumbar stiffness.';
    } else if (name.contains('femoris') || name.contains('gastrocnemius') || name.contains('quadriceps') || name.contains('tibialis')) {
      return 'Lower extremity muscles powering your daily steps and cadence. Strong circulation here keeps leg swelling and fatigue away.';
    }
    return '${muscle.displayName} is part of the ${muscle.group.id} muscle group. Operating under normal parameters with balanced physical tone.';
  }

  String _getMuscleErgonomicTip(MuscleInfo muscle) {
    final name = muscle.displayName.toLowerCase();
    if (name.contains('pectoralis') || name.contains('chest')) {
      return 'Do doorway chest stretches to counteract rounded shoulders from sitting.';
    } else if (name.contains('abdominis') || name.contains('oblique')) {
      return 'Engage your core gently when standing up from your desk to protect your lower back.';
    } else if (name.contains('trapezius') || name.contains('deltoid')) {
      return 'Drop your shoulders away from your ears and tilt your head gently side to side.';
    } else if (name.contains('femoris') || name.contains('gastrocnemius')) {
      return 'Stand up and perform 10 calf raises to pump oxygenated blood back up to your heart.';
    }
    return 'Maintain balanced hydration and stretch for 2 minutes every couple of hours.';
  }
}

