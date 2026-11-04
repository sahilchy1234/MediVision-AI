import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/models/user_profile_model.dart';
import '../providers/profile_provider.dart';
import '../../authentication/data/auth_service.dart';

class UserProfileSetupScreen extends ConsumerStatefulWidget {
  const UserProfileSetupScreen({super.key});

  @override
  ConsumerState<UserProfileSetupScreen> createState() =>
      _UserProfileSetupScreenState();
}

class _UserProfileSetupScreenState
    extends ConsumerState<UserProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _allergiesController;
  late TextEditingController _conditionsController;

  DateTime? _selectedDob = DateTime(1994, 6, 18);
  String _selectedGender = 'Non-binary';

  final List<String> _genderOptions = [
    'Female',
    'Male',
    'Non-binary',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    final current = ref.read(profileProvider);
    _nameController = TextEditingController(text: current.fullName);
    _heightController = TextEditingController(
      text: current.heightCm?.toStringAsFixed(0) ?? '175',
    );
    _weightController = TextEditingController(
      text: current.weightKg?.toStringAsFixed(1) ?? '68.5',
    );
    _allergiesController = TextEditingController(
      text: current.allergies.join(', '),
    );
    _conditionsController = TextEditingController(
      text: current.medicalConditions.join(', '),
    );
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
              primary: AppColors.secondary,
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
        title: Text(
          'Profile Setup',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _skip,
            child: const Text('Skip'),
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
                // Clean step indicator
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Text(
                  'Patient Profile',
                  style: AppTypography.displayMedium.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  'Calibrates physiological baseline intervals and medication safety.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 18),

                CustomTextField(
                  label: 'Full Name *',
                  hintText: 'Enter your name',
                  controller: _nameController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                Text(
                  'Date of Birth',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _selectDob,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      border: Border.all(color: AppColors.border, width: 1.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDob != null
                              ? DateFormatter.formatDate(_selectedDob!)
                              : 'Select date of birth',
                          style: AppTypography.bodyMedium.copyWith(
                            color: _selectedDob != null
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  'Gender',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _genderOptions.map((gender) {
                    final isSelected = _selectedGender == gender;
                    return ChoiceChip(
                      label: Text(gender),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedGender = gender);
                      },
                      selectedColor: AppColors.secondaryContainer,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 12,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.secondary : AppColors.border,
                        width: 0.8,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Height (cm)',
                        hintText: '175',
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Weight (kg)',
                        hintText: '68.5',
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  label: 'Allergies',
                  hintText: 'e.g. Penicillin, Sulfa (comma separated)',
                  controller: _allergiesController,
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  label: 'Medical Conditions',
                  hintText: 'e.g. Asthma, Hypertension (comma separated)',
                  controller: _conditionsController,
                ),
                const SizedBox(height: 20),

                PrimaryButton(
                  label: 'Save & Continue',
                  onPressed: _saveAndContinue,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
