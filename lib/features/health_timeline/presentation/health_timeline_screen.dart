import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../models/timeline_entry.dart';
import 'widgets/body_systems_diagram_card.dart';
import 'widgets/interactive_human_body_diagram.dart';
import 'widgets/weekly_rhythm_diagram_card.dart';

class HealthTimelineScreen extends StatefulWidget {
  const HealthTimelineScreen({super.key});

  @override
  State<HealthTimelineScreen> createState() => _HealthTimelineScreenState();
}

class _HealthTimelineScreenState extends State<HealthTimelineScreen> {
  int _viewMode = 0; // 0: Diagram & Balance View, 1: Milestone Journey View
  TimelineCategory _selectedFilter = TimelineCategory.all;
  final List<TimelineEntry> _allEntries = TimelineEntry.getSampleEntries();

  void _showMilestoneDetails(TimelineEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
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
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(
                      label: entry.simplePillTag,
                      type: BadgeType.success,
                    ),
                    Text(
                      DateFormatter.formatDate(entry.timestamp),
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  entry.title,
                  style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  entry.description,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 16),
                // Non-technical Plain-English Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded,
                              size: 18, color: AppColors.secondaryDark),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'What this means for you (Simple takeaway)',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.secondaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.plainEnglishInsight,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.45,
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
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Got It', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredEntries = _selectedFilter == TimelineCategory.all
        ? _allEntries
        : _allEntries.where((e) => e.category == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Health'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_rounded, size: 14, color: AppColors.secondaryDark),
                const SizedBox(width: 5),
                Text(
                  'Vitals Calm',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Ergonomic View Switcher (Body Balance vs Milestone Journey)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _ErgonomicViewTab(
                        label: 'Body Anatomy & Diagrams',
                        icon: Icons.accessibility_new_rounded,
                        isSelected: _viewMode == 0,
                        onTap: () => setState(() => _viewMode = 0),
                      ),
                    ),
                    Expanded(
                      child: _ErgonomicViewTab(
                        label: 'Milestone Journey',
                        icon: Icons.timeline_rounded,
                        isSelected: _viewMode == 1,
                        onTap: () => setState(() => _viewMode = 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: _viewMode == 0
                  ? _buildDiagramView()
                  : _buildMilestoneJourneyView(filteredEntries),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. DIAGRAM & SIMPLE INSIGHTS VIEW ---
  Widget _buildDiagramView() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        // Daily Plain-English Takeaway Banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F1E3D), Color(0xFF132D5E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1E0B1B3D),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      'TODAY\'S TAKEAWAY',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.secondaryLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 9.5,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.check_circle_rounded, color: AppColors.accentEmerald, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'High Energy Window',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.accentEmerald,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Your body is operating in high harmony today.',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You had nearly 2 hours of restorative deep sleep, your heart is beating calmly with zero extra strain, and your blood checkups are clean. You have plenty of stamina for the day.',
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFFCBD5E1),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.water_drop_outlined, size: 14, color: AppColors.secondaryLight),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Action for today: Drink an extra glass of water around 3 PM to avoid late afternoon slumps.',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.secondaryLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Interactive Human Body Anatomy Diagram (Atlas + Heatmap + Regional Zones)
        const InteractiveHumanBodyDiagram(),
        const SizedBox(height: 18),

        // Interactive Body Systems Balance Diagram
        const BodySystemsDiagramCard(),
        const SizedBox(height: 18),

        // 7-Day Rhythm Diagram
        const WeeklyRhythmDiagramCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  // --- 2. ERGONOMIC MILESTONE JOURNEY VIEW ---
  Widget _buildMilestoneJourneyView(List<TimelineEntry> filteredEntries) {
    return Column(
      children: [
        // Category Filter Chips
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _FilterChipItem(
                label: 'All Milestones',
                isSelected: _selectedFilter == TimelineCategory.all,
                onTap: () => setState(() => _selectedFilter = TimelineCategory.all),
              ),
              _FilterChipItem(
                label: 'Sleep & Rest',
                isSelected: _selectedFilter == TimelineCategory.sleep,
                onTap: () => setState(() => _selectedFilter = TimelineCategory.sleep),
              ),
              _FilterChipItem(
                label: 'Walking & Cardio',
                isSelected: _selectedFilter == TimelineCategory.activity,
                onTap: () => setState(() => _selectedFilter = TimelineCategory.activity),
              ),
              _FilterChipItem(
                label: 'Lab & Doctor Scans',
                isSelected: _selectedFilter == TimelineCategory.reports,
                onTap: () => setState(() => _selectedFilter = TimelineCategory.reports),
              ),
              _FilterChipItem(
                label: 'Daily Routines',
                isSelected: _selectedFilter == TimelineCategory.medications,
                onTap: () => setState(() => _selectedFilter = TimelineCategory.medications),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Diagrammatic Journey List
        Expanded(
          child: filteredEntries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_toggle_off_rounded,
                          size: 54, color: AppColors.textTertiary),
                      const SizedBox(height: 12),
                      Text(
                        'No health entries in this category',
                        style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: filteredEntries.length,
                  itemBuilder: (context, index) {
                    final entry = filteredEntries[index];
                    final isLast = index == filteredEntries.length - 1;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Connected Flow Diagram Node Line
                          SizedBox(
                            width: 38,
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                if (!isLast)
                                  Positioned(
                                    top: 24,
                                    bottom: 0,
                                    child: Container(
                                      width: 2.5,
                                      color: entry.statusColor.withOpacity(0.25),
                                    ),
                                  ),
                                Container(
                                  margin: const EdgeInsets.only(top: 14),
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: entry.statusColor, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: entry.statusColor.withOpacity(0.25),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(entry.icon, size: 13, color: entry.statusColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Ergonomic Journey Card
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: GlassCard(
                                padding: const EdgeInsets.all(16),
                                onTap: () => _showMilestoneDetails(entry),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormatter.formatDate(entry.timestamp),
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.textTertiary,
                                            fontSize: 11,
                                          ),
                                        ),
                                        StatusBadge(
                                          label: entry.simplePillTag,
                                          type: BadgeType.success,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      entry.title,
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.plainEnglishInsight,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textPrimary,
                                        height: 1.4,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceSubtle,
                                            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                          ),
                                          child: Text(
                                            entry.metricValue,
                                            style: AppTypography.labelSmall.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Learn more',
                                              style: AppTypography.labelSmall.copyWith(
                                                color: AppColors.secondary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            const Icon(Icons.chevron_right_rounded,
                                                size: 16, color: AppColors.secondary),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ErgonomicViewTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ErgonomicViewTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 12,
        ),
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
      ),
    );
  }
}
