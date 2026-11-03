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

  @override
  Widget build(BuildContext context) {
    final filteredEntries = _selectedFilter == TimelineCategory.all
        ? _allEntries
        : _allEntries.where((e) => e.category == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clinical Health Timeline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filter options',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chronological filter applied: Newest to Oldest.')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Chips Bar
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    label: 'Medical Reports',
                    isSelected: _selectedFilter == TimelineCategory.reports,
                    onTap: () => setState(() => _selectedFilter = TimelineCategory.reports),
                  ),
                  _FilterChipItem(
                    label: 'Medications',
                    isSelected: _selectedFilter == TimelineCategory.medications,
                    onTap: () => setState(() => _selectedFilter = TimelineCategory.medications),
                  ),
                  _FilterChipItem(
                    label: 'Symptoms',
                    isSelected: _selectedFilter == TimelineCategory.symptoms,
                    onTap: () => setState(() => _selectedFilter = TimelineCategory.symptoms),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Timeline List View
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
                            'No timeline events in this category',
                            style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: filteredEntries.length,
                      itemBuilder: (context, index) {
                        final entry = filteredEntries[index];
                        final isLast = index == filteredEntries.length - 1;

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Left Timeline Pillar (Dot + Vertical Line)
                              SizedBox(
                                width: 36,
                                child: Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    if (!isLast)
                                      Positioned(
                                        top: 22,
                                        bottom: 0,
                                        child: Container(
                                          width: 2,
                                          color: AppColors.border,
                                        ),
                                      ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 14),
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: entry.statusColor, width: 3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: entry.statusColor.withOpacity(0.2),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Timeline Event Card
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: GlassCard(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(entry.icon, size: 16, color: entry.statusColor),
                                                const SizedBox(width: 6),
                                                Text(
                                                  DateFormatter.formatDate(entry.timestamp),
                                                  style: AppTypography.labelSmall.copyWith(
                                                    color: AppColors.textTertiary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (entry.statusLabel != null)
                                              StatusBadge(
                                                label: entry.statusLabel!,
                                                type: BadgeType.info,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          entry.title,
                                          style: AppTypography.titleMedium.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          entry.description,
                                          style: AppTypography.bodyMedium,
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceSubtle,
                                            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                          ),
                                          child: Text(
                                            'Metric: ${entry.metricValue}',
                                            style: AppTypography.labelSmall.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
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
