import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../permissions/providers/permissions_provider.dart';
import '../../profile/data/models/user_profile_model.dart';
import '../../profile/providers/profile_provider.dart';
import '../data/auth_service.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _termsAccepted = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the privacy terms to continue.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (result.success) {
        if (result.user != null) {
          ref.read(profileProvider.notifier).updateProfile(
                UserProfileModel.fromJson(result.user!),
              );
          final userPerms =
              result.user!['permissions'] as Map<String, dynamic>?;
          if (userPerms != null && userPerms.isNotEmpty) {
            ref.read(permissionsProvider.notifier).syncFromMap(userPerms);
          } else {
            ref.read(permissionsProvider.notifier).grantAll();
          }
        } else {
          ref.read(permissionsProvider.notifier).grantAll();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.isOfflineFallback
                ? AppColors.primary
                : AppColors.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/profile-setup');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Patient Profile',
                  style: AppTypography.displayMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'End-to-end encrypted medical memory with zero cloud disclosure.',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 24),

                CustomTextField(
                  label: 'Full Legal Name',
                  hintText: 'e.g. Alex Morgan',
                  controller: _nameController,
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter your full name'
                      : null,
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  label: 'Email Address',
                  hintText: 'alex.morgan@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!val.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  label: 'Master Password',
                  hintText: 'Minimum 8 characters with numbers',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (val) => val == null || val.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  label: 'Confirm Master Password',
                  hintText: 'Re-enter your password',
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  validator: (val) {
                    if (val != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      activeColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (val) =>
                          setState(() => _termsAccepted = val ?? false),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'I acknowledge that MediVision provides educational clinical guidance and not certified medical diagnosis. All telemetry is encrypted.',
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                PrimaryButton(
                  label: 'Create Encrypted Account',
                  isLoading: _isLoading,
                  onPressed: _handleSignup,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: AppTypography.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Sign In',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
