import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../models/timeline_entry.dart';

class HealthTimelineScreen extends StatefulWidget {
  const HealthTimelineScreen({super.key});

  @override
  State<HealthTimelineScreen> createState() => _HealthTimelineScreenState();
}

class _HealthTimelineScreenState extends State<HealthTimelineScreen> {
  TimelineCategory _selectedFilter = TimelineCategory.all;
  final List<TimelineEntry> _allEntries = TimelineEntry.getSampleEntries();

  void _showMilestoneDetails(TimelineEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusL),
            ),
          ),
          child: SafeArea(
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
                const SizedBox(height: 16),
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
                const SizedBox(height: 10),
                Text(
                  entry.title,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  entry.description,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clinical Context',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
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
        title: Text(
          'Health Timeline',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: _buildTimelineView(filteredEntries),
      ),
    );
  }

  // --- TIMELINE HISTORY VIEW ---
  Widget _buildTimelineView(List<TimelineEntry> filteredEntries) {
    return Column(
      children: [
        // Category Filter Chips
        Container(
          height: 38,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _FilterChipItem(
                label: 'All Activity',
                isSelected: _selectedFilter == TimelineCategory.all,
                onTap: () => setState(() => _selectedFilter = TimelineCategory.all),
              ),
              _FilterChipItem(
                label: 'Sleep',
                isSelected: _selectedFilter == TimelineCategory.sleep,
                onTap: () => setState(() => _selectedFilter = TimelineCategory.sleep),
              ),
              _FilterChipItem(
                label: 'Activity',
                isSelected: _selectedFilter == TimelineCategory.activity,
                onTap: () => setState(() => _selectedFilter = TimelineCategory.activity),
              ),
              _FilterChipItem(
                label: 'Symptoms',
                isSelected: _selectedFilter == TimelineCategory.symptoms,
                onTap: () => setState(() => _selectedFilter = TimelineCategory.symptoms),
              ),
              _FilterChipItem(
                label: 'Reports',
                isSelected: _selectedFilter == TimelineCategory.reports,
                onTap: () => setState(() => _selectedFilter = TimelineCategory.reports),
              ),
              _FilterChipItem(
                label: 'Medications',
                isSelected: _selectedFilter == TimelineCategory.medications,
                onTap: () => setState(() => _selectedFilter = TimelineCategory.medications),
              ),
            ],
          ),
        ),

        // Timeline Items List
        Expanded(
          child: filteredEntries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.history_rounded,
                        size: 40,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No records found in this category',
                        style: AppTypography.bodySmall,
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
                          // Connected timeline line
                          SizedBox(
                            width: 30,
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                if (!isLast)
                                  Positioned(
                                    top: 18,
                                    bottom: 0,
                                    child: Container(
                                      width: 1.5,
                                      color: AppColors.border,
                                    ),
                                  ),
                                Container(
                                  margin: const EdgeInsets.only(top: 14),
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: entry.statusColor, width: 2.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Clean Timeline Card
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GlassCard(
                                padding: const EdgeInsets.all(14),
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
                                          type: BadgeType.neutral,
                                          isPill: true,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      entry.title,
                                      style: AppTypography.titleSmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      entry.description,
                                      style: AppTypography.bodySmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceSubtle,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            entry.metricValue,
                                            style: AppTypography.labelSmall.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          size: 16,
                                          color: AppColors.textTertiary,
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
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.secondaryContainer,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: isSelected ? AppColors.secondary : AppColors.border,
          width: 0.8,
        ),
        labelStyle: AppTypography.labelSmall.copyWith(
          color: isSelected ? AppColors.secondary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
    );
  }
}
