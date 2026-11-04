import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/models/user_profile_model.dart';
import '../providers/profile_provider.dart';
import '../../authentication/data/auth_service.dart';

class UserProfileSetupScreen extends ConsumerStatefulWidget {
  const UserProfileSetupScreen({super.key});

  @override
  ConsumerState<UserProfileSetupScreen> createState() => _UserProfileSetupScreenState();
}

class _UserProfileSetupScreenState extends ConsumerState<UserProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _allergiesController;
  late TextEditingController _conditionsController;

  DateTime? _selectedDob = DateTime(1994, 6, 18);
  String _selectedGender = 'Non-binary';

  final List<String> _genderOptions = ['Female', 'Male', 'Non-binary', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    final current = ref.read(profileProvider);
    _nameController = TextEditingController(text: current.fullName);
    _heightController = TextEditingController(text: current.heightCm?.toStringAsFixed(0) ?? '175');
    _weightController = TextEditingController(text: current.weightKg?.toStringAsFixed(1) ?? '68.5');
    _allergiesController = TextEditingController(text: current.allergies.join(', '));
    _conditionsController = TextEditingController(text: current.medicalConditions.join(', '));
    if (current.gender != null) {
      _selectedGender = current.gender!;
    }
    if (current.dateOfBirth != null) {
      _selectedDob = current.dateOfBirth;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  Future<void> _selectDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  void _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final allergies = _allergiesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final conditions = _conditionsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final updatedProfile = UserProfileModel(
      fullName: _nameController.text.trim().isEmpty
          ? 'Health Member'
          : _nameController.text.trim(),
      dateOfBirth: _selectedDob,
      gender: _selectedGender,
      heightCm: double.tryParse(_heightController.text.trim()),
      weightKg: double.tryParse(_weightController.text.trim()),
      allergies: allergies,
      medicalConditions: conditions,
      enableWomensHealth: _selectedGender.toLowerCase() == 'female',
    );

    ref.read(profileProvider.notifier).updateProfile(updatedProfile);

    // Save directly to the real backend database
    await AuthService.updateProfile(updatedProfile);

    if (mounted) {
      context.go('/storage-selection');
    }
  }

  void _skip() {
    context.go('/storage-selection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clinical Profile Setup'),
        actions: [
          TextButton(
            onPressed: _skip,
            child: Text(
              'Skip for now',
              style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Progress indicator
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Text(
                  'Tell Us About Yourself',
                  style: AppTypography.displaySmall.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'This baseline data allows the MediVision AI companion to calculate personalized metabolic ratios and clinical normal ranges.',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Full Name
                CustomTextField(
                  label: 'Full Name *',
                  hintText: 'Enter your name',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Date of Birth
                Text(
                  'Date of Birth',
                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDob,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(color: AppColors.border, width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDob != null
                                  ? DateFormatter.formatDate(_selectedDob!)
                                  : 'Select date of birth',
                              style: AppTypography.bodyLarge.copyWith(
                                color: _selectedDob != null
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Gender Chips (Optional)
                Text(
                  'Gender (Optional)',
                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _genderOptions.map((gender) {
                    final isSelected = _selectedGender == gender;
                    return ChoiceChip(
                      label: Text(gender),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedGender = gender);
                        }
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Physical Biometrics (Height & Weight)
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Height (cm)',
                        hintText: '175',
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.height_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: CustomTextField(
                        label: 'Weight (kg)',
                        hintText: '68.5',
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: const Icon(Icons.monitor_weight_outlined, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Known Allergies
                CustomTextField(
                  label: 'Known Allergies (Optional)',
                  hintText: 'e.g. Penicillin, Peanuts, Sulfa (comma separated)',
                  controller: _allergiesController,
                  prefixIcon: const Icon(Icons.warning_amber_rounded, size: 20),
                ),
                const SizedBox(height: 18),

                // Medical Conditions
                CustomTextField(
                  label: 'Existing Medical Conditions (Optional)',
                  hintText: 'e.g. Mild Asthma, Hypertension, Diabetes Type 2',
                  controller: _conditionsController,
                  maxLines: 2,
                  prefixIcon: const Icon(Icons.medical_information_outlined, size: 20),
                ),
                const SizedBox(height: 24),

                GlassCard(
                  backgroundColor: AppColors.secondaryContainer.withOpacity(0.4),
                  borderColor: AppColors.secondaryLight.withOpacity(0.3),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_rounded, size: 20, color: AppColors.secondaryDark),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your profile fields are encrypted on-device and will never be shared without explicit consent.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.secondaryDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                PrimaryButton(
                  label: 'Continue to Storage Mode',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _saveAndContinue,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

