import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../models/medical_record.dart';
import '../providers/medical_records_provider.dart';

class MedicalRecordsScreen extends ConsumerStatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  ConsumerState<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends ConsumerState<MedicalRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  BadgeType _badgeTypeForStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('analyzed') || s.contains('optimal') || s.contains('verified')) {
      return BadgeType.success;
    }
    if (s.contains('active')) {
      return BadgeType.info;
    }
    if (s.contains('archived')) {
      return BadgeType.neutral;
    }
    if (s.contains('alert') || s.contains('high') || s.contains('abnormal')) {
      return BadgeType.warning;
    }
    return BadgeType.info;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showRecordDetails(MedicalRecordItem record) {
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadge(
                        label: record.status,
                        type: _badgeTypeForStatus(record.status),
                      ),
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        record.category.icon,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${record.category.label} • ${record.providerName} • ${DateFormatter.formatDate(record.date)}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Summary Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(color: AppColors.border, width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              size: 15,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Clinical Summary & AI Findings',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          record.summary.isNotEmpty
                              ? record.summary
                              : 'No summary recorded yet. Use MediVision AI analysis below to extract clinical observations.',
                          style: AppTypography.bodyMedium.copyWith(height: 1.45),
                        ),
                      ],
                    ),
                  ),

                  if (record.notes != null && record.notes!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        border: Border.all(color: AppColors.border, width: 1.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patient / Doctor Notes',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(record.notes!, style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                  ],

                  if (record.filePath != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Stored locally on device: ${record.filePath!.split(Platform.pathSeparator).last}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 18),

                  // View Document Button
                  PrimaryButton(
                    label: 'View Document',
                    icon: Icons.description_outlined,
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _viewDocument(record);
                    },
                  ),
                  const SizedBox(height: 8),

                  // AI Analysis Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: AppColors.secondary, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                    ),
                    icon: const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 18),
                    label: const Text(
                      'Run MediVision AI Analysis',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Analyzing record biomarkers with AI...'),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      await ref.read(medicalRecordsProvider.notifier).runAiAnalysis(record.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('AI Analysis updated in health records.'),
                            backgroundColor: AppColors.secondary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  // Delete Record Button
                  Center(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accentRose,
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Delete Medical Record'),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _confirmDelete(record);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _viewDocument(MedicalRecordItem record) {
    if (record.filePath != null && File(record.filePath!).existsSync()) {
      final isImage = record.filePath!.endsWith('.jpg') ||
          record.filePath!.endsWith('.jpeg') ||
          record.filePath!.endsWith('.png') ||
          record.filePath!.endsWith('.webp');

      if (isImage) {
        showDialog(
          context: context,
          builder: (dialogCtx) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Colors.black,
                    child: Image.file(
                      File(record.filePath!),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(dialogCtx),
                ),
              ],
            ),
          ),
        );
        return;
      }
    }

    // Modal preview for PDFs and documents
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.verified_user_rounded, color: AppColors.secondary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                record.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provider: ${record.providerName}', style: AppTypography.bodySmall),
            Text('Date: ${DateFormatter.formatDate(record.date)}', style: AppTypography.bodySmall),
            Text('File Size: ${record.fileSize}', style: AppTypography.bodySmall),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                record.filePath != null
                    ? 'Encrypted local document saved on device storage.\nPath: ${record.filePath}'
                    : 'Encrypted clinical record stored in patient records vault.',
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(MedicalRecordItem record) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Record?'),
        content: Text(
          'Are you sure you want to permanently delete "${record.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRose,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await ref
                  .read(medicalRecordsProvider.notifier)
                  .deleteRecord(record.id);

              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Record "${record.title}" deleted.'),
                    backgroundColor: AppColors.textPrimary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showUploadSourceSheet() {
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
                Text(
                  'Add Medical Record',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload clinical files, diagnostic scans, or prescriptions into your encrypted health vault.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 16),

                // Option 1: PDF or Document
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
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'Pick Document / PDF Report',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  subtitle: const Text(
                    'Lab panels, metabolic tests, discharge summaries (.pdf, .doc)',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickDocumentFile();
                  },
                ),
                const Divider(height: 1),

                // Option 2: Camera Capture
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
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'Take Photo with Camera',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  subtitle: const Text(
                    'Scan physical prescription slip, lab receipt, or doctor memo',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickFromCamera();
                  },
                ),
                const Divider(height: 1),

                // Option 3: Image from Gallery
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'Choose Photo from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  subtitle: const Text(
                    'X-Ray imaging photo, MRI scan screenshot, or medical slip',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickFromGallery();
                  },
                ),
                const Divider(height: 1),

                // Option 4: Manual Entry
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'Enter Record Details Manually',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  subtitle: const Text(
                    'Create an indexed entry without an attached physical file',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openUploadForm(
                      initialTitle: '',
                      initialCategory: RecordCategory.bloodReports,
                      fileSize: 'Manual Entry',
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

  Future<void> _pickDocumentFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'csv', 'png', 'jpg'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final cleanTitle = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
        final formattedSize = _formatFileSize(file.size);

        RecordCategory category = RecordCategory.bloodReports;
        final lower = file.name.toLowerCase();
        if (lower.contains('xray') || lower.contains('mri') || lower.contains('scan')) {
          category = RecordCategory.xRays;
        } else if (lower.contains('rx') || lower.contains('prescription') || lower.contains('med')) {
          category = RecordCategory.prescriptions;
        }

        _openUploadForm(
          initialTitle: cleanTitle,
          initialCategory: category,
          pickedFilePath: file.path,
          originalFileName: file.name,
          fileSize: '$formattedSize ${file.extension?.toUpperCase() ?? 'DOC'}',
          fileType: file.extension ?? 'pdf',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file picker: $e')),
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        final length = await photo.length();
        final formattedSize = _formatFileSize(length);
        final defaultTitle = 'Clinical Scan ${DateFormatter.formatDate(DateTime.now())}';

        _openUploadForm(
          initialTitle: defaultTitle,
          initialCategory: RecordCategory.prescriptions,
          pickedFilePath: photo.path,
          originalFileName: photo.name,
          fileSize: '$formattedSize JPG',
          fileType: 'image',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access camera: $e')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final length = await image.length();
        final formattedSize = _formatFileSize(length);
        final cleanTitle = image.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');

        _openUploadForm(
          initialTitle: cleanTitle.isNotEmpty ? cleanTitle : 'Medical Imaging Scan',
          initialCategory: RecordCategory.xRays,
          pickedFilePath: image.path,
          originalFileName: image.name,
          fileSize: '$formattedSize IMG',
          fileType: 'image',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open gallery: $e')),
        );
      }
    }
  }

  void _openUploadForm({
    required String initialTitle,
    required RecordCategory initialCategory,
    String? pickedFilePath,
    String? originalFileName,
    required String fileSize,
    String? fileType,
  }) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: initialTitle);
    final providerController = TextEditingController(text: 'Metropolitan Clinical Center');
    final summaryController = TextEditingController();
    final notesController = TextEditingController();
    RecordCategory selectedCategory = initialCategory;
    DateTime selectedDate = DateTime.now();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (formContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusL),
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
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
                            Text(
                              'Save New Record',
                              style: AppTypography.titleLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (pickedFilePath != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.attach_file_rounded, size: 14, color: AppColors.secondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      fileSize,
                                      style: const TextStyle(
                                        color: AppColors.secondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Title Field
                        TextFormField(
                          controller: titleController,
                          style: AppTypography.bodyMedium,
                          decoration: const InputDecoration(
                            labelText: 'Record Title *',
                            hintText: 'e.g. Complete Blood Count & Lipid Panel',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.title_rounded, size: 20),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a title for this record';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Category Dropdown
                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category_outlined, size: 20),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<RecordCategory>(
                              value: selectedCategory,
                              isDense: true,
                              items: RecordCategory.values.map((cat) {
                                return DropdownMenuItem(
                                  value: cat,
                                  child: Row(
                                    children: [
                                      Icon(cat.icon, size: 16, color: AppColors.secondary),
                                      const SizedBox(width: 8),
                                      Text(cat.label, style: AppTypography.bodyMedium),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => selectedCategory = val);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Provider Field
                        TextFormField(
                          controller: providerController,
                          style: AppTypography.bodyMedium,
                          decoration: const InputDecoration(
                            labelText: 'Healthcare Provider / Diagnostic Lab',
                            hintText: 'e.g. Dr. Sarah Lin, Quest Diagnostics',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.local_hospital_outlined, size: 20),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Date Selector
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          leading: const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.secondary),
                          title: const Text('Record Date', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          subtitle: Text(
                            DateFormatter.formatDate(selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                          trailing: const Icon(Icons.arrow_drop_down),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(1980),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setModalState(() => selectedDate = picked);
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // Clinical Summary Field
                        TextFormField(
                          controller: summaryController,
                          maxLines: 2,
                          style: AppTypography.bodyMedium,
                          decoration: const InputDecoration(
                            labelText: 'Document Summary / Clinical Notes',
                            hintText: 'Key findings, doctor advice, or lab remarks...',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Save Button
                        PrimaryButton(
                          label: isSaving ? 'Securing & Saving...' : 'Save & Index Record',
                          icon: Icons.check_circle_outline_rounded,
                          isLoading: isSaving,
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(formContext);

                            setModalState(() => isSaving = true);

                            String? permanentFilePath;
                            if (pickedFilePath != null) {
                              final repo = ref.read(medicalRecordsRepositoryProvider);
                              permanentFilePath = await repo.copyFileToAppStorage(
                                pickedFilePath,
                                originalFileName ?? 'record_file',
                              );
                            }

                            final title = titleController.text.trim();
                            final provider = providerController.text.trim();
                            final summary = summaryController.text.trim();
                            final notes = notesController.text.trim();

                            final success = await ref
                                .read(medicalRecordsProvider.notifier)
                                .addRecord(
                                  title: title,
                                  category: selectedCategory,
                                  providerName: provider,
                                  date: selectedDate,
                                  fileSize: fileSize,
                                  filePath: permanentFilePath ?? pickedFilePath,
                                  fileType: fileType,
                                  summary: summary.isNotEmpty ? summary : null,
                                  notes: notes.isNotEmpty ? notes : null,
                                );

                            navigator.pop();
                            if (success) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Medical record "$title" permanently saved.'),
                                  backgroundColor: AppColors.secondary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 8),
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicalRecordsProvider);
    final notifier = ref.read(medicalRecordsProvider.notifier);
    final filtered = state.filteredRecords;

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
            icon: const Icon(Icons.add_rounded, size: 24),
            tooltip: 'Add Record',
            onPressed: _showUploadSourceSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Upload Record', style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: _showUploadSourceSheet,
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
                  suffixIcon: state.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            notifier.setSearchQuery('');
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
                onChanged: (val) => notifier.setSearchQuery(val),
              ),
              const SizedBox(height: 10),

              // Categories Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Documents'),
                      selected: state.selectedCategory == null,
                      onSelected: (_) => notifier.selectCategory(null),
                      selectedColor: AppColors.secondaryContainer,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: state.selectedCategory == null
                            ? AppColors.secondary
                            : AppColors.textSecondary,
                        fontWeight: state.selectedCategory == null
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 11.5,
                      ),
                      side: BorderSide(
                        color: state.selectedCategory == null
                            ? AppColors.secondary
                            : AppColors.border,
                        width: 0.8,
                      ),
                    ),
                    const SizedBox(width: 6),
                    ...RecordCategory.values.map((cat) {
                      final isSelected = state.selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: FilterChip(
                          label: Text(cat.label),
                          selected: isSelected,
                          onSelected: (_) => notifier.selectCategory(cat),
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

              // Total count & status summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filtered.length} ${filtered.length == 1 ? 'Record' : 'Records'} Indexed',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (state.isLoading)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Documents List
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.secondary,
                  onRefresh: () => notifier.loadRecords(),
                  child: filtered.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: AppColors.surfaceSubtle,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.folder_open_outlined,
                                    size: 40,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  state.searchQuery.isNotEmpty
                                      ? 'No records matching "${state.searchQuery}"'
                                      : 'No medical records found',
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Upload lab reports, prescriptions, or imaging scans to keep them encrypted and accessible.',
                                  style: AppTypography.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: const Text('Add First Record'),
                                  onPressed: _showUploadSourceSheet,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
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
                                    width: 38,
                                    height: 38,
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
                                      size: 19,
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
                                              type: _badgeTypeForStatus(item.status),
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
                                            if (item.filePath != null) ...[
                                              const SizedBox(width: 6),
                                              const Icon(
                                                Icons.attachment_rounded,
                                                size: 13,
                                                color: AppColors.secondary,
                                              ),
                                            ],
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
