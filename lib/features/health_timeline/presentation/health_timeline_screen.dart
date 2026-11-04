import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../models/timeline_entry.dart';
import '../providers/timeline_provider.dart';

class HealthTimelineScreen extends ConsumerStatefulWidget {
  const HealthTimelineScreen({super.key});

  @override
  ConsumerState<HealthTimelineScreen> createState() => _HealthTimelineScreenState();
}

class _HealthTimelineScreenState extends ConsumerState<HealthTimelineScreen> {
  TimelineCategory _selectedFilter = TimelineCategory.all;

  void _showMilestoneDetails(TimelineEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Clinical Context',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (entry.source != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                _sourceLabel(entry.source!),
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 10,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                        ],
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
                if (entry.source == 'medical_records') ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                        ),
                      ),
                      icon: const Icon(Icons.folder_shared_outlined, size: 18),
                      label: const Text('Open Medical Records Vault'),
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/medical-records');
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    if (entry.source != 'medical_records') ...[
                      IconButton(
                        tooltip: 'Delete Event',
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Timeline Entry?'),
                              content: Text('Remove "${entry.title}" from your personal health timeline?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            Navigator.pop(sheetContext);
                            await ref.read(timelineProvider.notifier).deleteEntry(entry.id);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
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
              ],
            ),
          ),
        );
      },
    );
  }

  String _sourceLabel(String source) {
    switch (source) {
      case 'medical_records':
        return 'Medical Records Vault';
      case 'activity':
      case 'vitals_activity':
        return 'Activity Sensor / GPS';
      case 'vitals_log':
        return 'Vitals Telemetry';
      default:
        return 'Patient Recorded';
    }
  }

  void _showAddEventSheet() {
    final titleController = TextEditingController();
    final metricController = TextEditingController();
    final descriptionController = TextEditingController();
    final insightController = TextEditingController();
    TimelineCategory chosenCategory = TimelineCategory.medications;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radiusL),
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
                            Text(
                              'Log Health Event',
                              style: AppTypography.titleLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Preset shortcuts
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _presetPill(
                                label: '💊 Medication',
                                onTap: () {
                                  setSheetState(() {
                                    chosenCategory = TimelineCategory.medications;
                                    titleController.text = 'Medication Dose';
                                    metricController.text = 'Taken with food';
                                    insightController.text = 'Maintained scheduled clinical dosing routine.';
                                  });
                                },
                              ),
                              _presetPill(
                                label: '🩹 Sensation / Symptom',
                                onTap: () {
                                  setSheetState(() {
                                    chosenCategory = TimelineCategory.symptoms;
                                    titleController.text = 'Mild Headache';
                                    metricController.text = 'Scale 2/10';
                                    insightController.text = 'Symptom logged for clinical correlation with vitals.';
                                  });
                                },
                              ),
                              _presetPill(
                                label: '🏃 Movement',
                                onTap: () {
                                  setSheetState(() {
                                    chosenCategory = TimelineCategory.activity;
                                    titleController.text = 'Brisk Outdoor Walk';
                                    metricController.text = '5,000 steps';
                                    insightController.text = 'Cardiovascular stimulation and aerobic movement.';
                                  });
                                },
                              ),
                              _presetPill(
                                label: '🩺 Clinical Note',
                                onTap: () {
                                  setSheetState(() {
                                    chosenCategory = TimelineCategory.reports;
                                    titleController.text = 'Doctor Consultation';
                                    metricController.text = 'In-Person Visit';
                                    insightController.text = 'Review of clinical markers and treatment plan.';
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Category Chips
                        Text('Category', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: [
                            _categoryChoiceChip(
                              label: 'Medications',
                              selected: chosenCategory == TimelineCategory.medications,
                              onSelected: () => setSheetState(() => chosenCategory = TimelineCategory.medications),
                            ),
                            _categoryChoiceChip(
                              label: 'Symptoms',
                              selected: chosenCategory == TimelineCategory.symptoms,
                              onSelected: () => setSheetState(() => chosenCategory = TimelineCategory.symptoms),
                            ),
                            _categoryChoiceChip(
                              label: 'Activity',
                              selected: chosenCategory == TimelineCategory.activity,
                              onSelected: () => setSheetState(() => chosenCategory = TimelineCategory.activity),
                            ),
                            _categoryChoiceChip(
                              label: 'Sleep',
                              selected: chosenCategory == TimelineCategory.sleep,
                              onSelected: () => setSheetState(() => chosenCategory = TimelineCategory.sleep),
                            ),
                            _categoryChoiceChip(
                              label: 'Reports / Notes',
                              selected: chosenCategory == TimelineCategory.reports,
                              onSelected: () => setSheetState(() => chosenCategory = TimelineCategory.reports),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Title
                        Text('Event Title', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: 'e.g. Vitamin D3 & Omega-3, Mild Spasm, Blood Pressure',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Metric / Reading
                        Text('Metric / Dosage / Measurement', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: metricController,
                          decoration: InputDecoration(
                            hintText: 'e.g. 2,000 IU, 120/80 mmHg, 8,000 steps, Scale 3/10',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text('Description / Notes (Optional)', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: descriptionController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'e.g. Taken with breakfast. No adverse symptoms.',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Action button
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
                            onPressed: () async {
                              final title = titleController.text.trim();
                              if (title.isEmpty) return;

                              final metric = metricController.text.trim();
                              final desc = descriptionController.text.trim().isNotEmpty
                                  ? descriptionController.text.trim()
                                  : (metric.isNotEmpty ? metric : 'Personal health milestone recorded.');
                              final insight = insightController.text.trim().isNotEmpty
                                  ? insightController.text.trim()
                                  : 'Documented in your longitudinal health record.';

                              IconData icon = Icons.history_rounded;
                              Color color = AppColors.secondary;
                              String tag = 'Logged';

                              switch (chosenCategory) {
                                case TimelineCategory.medications:
                                  icon = Icons.medication_rounded;
                                  color = const Color(0xFF10B981);
                                  tag = 'Medication';
                                  break;
                                case TimelineCategory.symptoms:
                                  icon = Icons.healing_rounded;
                                  color = const Color(0xFFF59E0B);
                                  tag = 'Symptom';
                                  break;
                                case TimelineCategory.activity:
                                  icon = Icons.directions_walk_rounded;
                                  color = AppColors.secondary;
                                  tag = 'Movement';
                                  break;
                                case TimelineCategory.sleep:
                                  icon = Icons.bedtime_rounded;
                                  color = const Color(0xFF6366F1);
                                  tag = 'Sleep';
                                  break;
                                case TimelineCategory.reports:
                                  icon = Icons.document_scanner_rounded;
                                  color = const Color(0xFF0D9488);
                                  tag = 'Clinical Note';
                                  break;
                                case TimelineCategory.all:
                                  break;
                              }

                              await ref.read(timelineProvider.notifier).addEntry(
                                    title: title,
                                    description: desc,
                                    category: chosenCategory,
                                    metricValue: metric.isNotEmpty ? metric : 'Recorded',
                                    icon: icon,
                                    statusLabel: tag,
                                    statusColor: color,
                                    plainEnglishInsight: insight,
                                    simplePillTag: tag,
                                    source: 'user_log',
                                  );

                              if (context.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Health event saved to your timeline.'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: const Text('Save to Timeline', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _presetPill({required String label, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ActionChip(
        label: Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
        onPressed: onTap,
        backgroundColor: AppColors.surfaceSubtle,
        side: const BorderSide(color: AppColors.border, width: 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
    );
  }

  Widget _categoryChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.secondaryContainer,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? AppColors.secondary : AppColors.border,
        width: 0.8,
      ),
      labelStyle: AppTypography.labelSmall.copyWith(
        color: selected ? AppColors.secondary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 11,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allEntries = ref.watch(timelineProvider);
    final filteredEntries = _selectedFilter == TimelineCategory.all
        ? allEntries
        : allEntries.where((e) => e.category == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Health Timeline',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Log Health Event',
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
            onPressed: _showAddEventSheet,
          ),
          IconButton(
            tooltip: 'Refresh Timeline',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(timelineProvider.notifier).refreshTimeline(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Health Event', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(timelineProvider.notifier).refreshTimeline(),
          child: _buildTimelineView(filteredEntries, allEntries.isNotEmpty),
        ),
      ),
    );
  }

  // --- TIMELINE HISTORY VIEW ---
  Widget _buildTimelineView(List<TimelineEntry> filteredEntries, bool hasAnyEntries) {
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
              ? _buildEmptyState(hasAnyEntries)
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 80),
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

  Widget _buildEmptyState(bool hasAnyEntries) {
    if (!hasAnyEntries) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  size: 32,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your Health Timeline is Live',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Upload lab tests or scans in Medical Records, track activity in Vitals, or log your medications and symptoms below to build your clinical history.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.45),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                    ),
                    icon: const Icon(Icons.upload_file_rounded, size: 16),
                    label: const Text('Upload Record'),
                    onPressed: () => context.push('/medical-records'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Log Health Event'),
                    onPressed: _showAddEventSheet,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
              'No records in "${_selectedFilter.label}"',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => _selectedFilter = TimelineCategory.all),
              child: const Text('Show All Events'),
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
