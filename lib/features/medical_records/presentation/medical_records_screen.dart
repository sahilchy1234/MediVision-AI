import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../models/medical_record.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  RecordCategory? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  final List<MedicalRecordItem> _records = MedicalRecordItem.getSampleRecords();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRecordDetails(MedicalRecordItem record) {
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
                    StatusBadge(label: record.status, type: BadgeType.success),
                    Text(record.fileSize, style: AppTypography.bodySmall),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  record.title,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${record.providerName} • ${DateFormatter.formatDate(record.date)}',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(color: AppColors.border, width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Document Summary',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        record.summary,
                        style: AppTypography.bodyMedium.copyWith(height: 1.45),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'View Original Document',
                  icon: Icons.description_outlined,
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Viewing document: ${record.title}'),
                        backgroundColor: AppColors.secondary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUploadDialog() {
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
                Text(
                  'Add Record',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload clinical files or prescriptions to index into your health timeline.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'PDF Diagnostic Report',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  subtitle: const Text(
                    'Lab panels, metabolic tests, discharge notes',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _simulateNewUpload(
                      'Lipid Panel Nov 2026.pdf',
                      RecordCategory.bloodReports,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.document_scanner_outlined,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'X-Ray / DICOM Study',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  subtitle: const Text(
                    'Chest radiographs, MRI, or CT imaging',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _simulateNewUpload(
                      'Spine Radiograph DICOM.dcm',
                      RecordCategory.xRays,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Prescription or Doctor Order',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  subtitle: const Text(
                    'Medication order or prescription photo',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _simulateNewUpload(
                      'Prescription Slip.jpg',
                      RecordCategory.prescriptions,
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _simulateNewUpload(String name, RecordCategory category) {
    setState(() {
      _records.insert(
        0,
        MedicalRecordItem(
          id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
          title: name,
          category: category,
          date: DateTime.now(),
          providerName: 'Uploaded Document',
          fileSize: '1.4 MB',
          status: 'Indexed',
          statusColor: AppColors.secondary,
          summary: 'Newly uploaded clinical document indexed into health timeline.',
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Document "$name" saved to records.'),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _records.where((item) {
      final matchesCategory =
          _selectedCategory == null || item.category == _selectedCategory;
      final matchesQuery =
          _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.providerName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Medical Records',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 22),
            tooltip: 'Add Record',
            onPressed: _showUploadDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input Bar
              const SizedBox(height: 6),
              TextField(
                controller: _searchController,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search records, providers, labs...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              ),
              const SizedBox(height: 10),

              // Categories Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Documents'),
                      selected: _selectedCategory == null,
                      onSelected: (_) => setState(() => _selectedCategory = null),
                      selectedColor: AppColors.secondaryContainer,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _selectedCategory == null
                            ? AppColors.secondary
                            : AppColors.textSecondary,
                        fontWeight: _selectedCategory == null
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 11.5,
                      ),
                      side: BorderSide(
                        color: _selectedCategory == null
                            ? AppColors.secondary
                            : AppColors.border,
                        width: 0.8,
                      ),
                    ),
                    const SizedBox(width: 6),
                    ...RecordCategory.values.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: FilterChip(
                          label: Text(cat.label),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                          selectedColor: AppColors.secondaryContainer,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 11.5,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.border,
                            width: 0.8,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Documents List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.folder_open_outlined,
                              size: 40,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No medical records found',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = filtered[index];

                          return GlassCard(
                            onTap: () => _showRecordDetails(item),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSubtle,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Icon(
                                    item.category.icon,
                                    color: AppColors.secondary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: AppTypography.titleSmall.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.providerName} • ${DateFormatter.formatDate(item.date)}',
                                        style: AppTypography.bodySmall.copyWith(
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          StatusBadge(
                                            label: item.status,
                                            type: BadgeType.neutral,
                                            isPill: true,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            item.fileSize,
                                            style: AppTypography.labelSmall.copyWith(
                                              fontSize: 10,
                                              color: AppColors.textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: AppColors.textTertiary,
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
      ),
    );
  }
}
