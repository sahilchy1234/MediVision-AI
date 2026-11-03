import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../shared/models/storage_mode.dart';
import '../providers/storage_provider.dart';

class StorageSelectionScreen extends ConsumerWidget {
  const StorageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMode = ref.watch(storageSelectionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Architecture & Privacy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar (Step 2 of 3)
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
                ],
              ),
              const SizedBox(height: 20),

              Text(
                'Select Storage Architecture',
                style: AppTypography.displaySmall.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Decide where your medical memory and clinical summaries reside. You can modify these preferences at any time in Settings.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _StorageOptionCard(
                      mode: StorageMode.local,
                      tag: 'LOCAL STORAGE',
                      title: 'Local On-Device Storage',
                      explanation:
                          'Your health data stays entirely on your device. Zero cloud server transmissions. The most secure and private configuration.',
                      icon: Icons.phonelink_lock_rounded,
                      accentColor: AppColors.primary,
                      isSelected: selectedMode == StorageMode.local,
                      onTap: () {
                        ref.read(storageSelectionProvider.notifier).setStorageMode(StorageMode.local);
                      },
                    ),
                    const SizedBox(height: 16),
                    _StorageOptionCard(
                      mode: StorageMode.cloud,
                      tag: 'CLOUD STORAGE',
                      title: 'Encrypted Cloud Storage',
                      explanation:
                          'Your authorized data is securely synchronized to your account using zero-knowledge encryption across all your mobile and desktop devices.',
                      icon: Icons.cloud_sync_rounded,
                      accentColor: AppColors.secondary,
                      isSelected: selectedMode == StorageMode.cloud,
                      onTap: () {
                        ref.read(storageSelectionProvider.notifier).setStorageMode(StorageMode.cloud);
                      },
                    ),
                    const SizedBox(height: 16),
                    _StorageOptionCard(
                      mode: StorageMode.hybrid,
                      tag: 'HYBRID STORAGE',
                      title: 'Hybrid Split Storage',
                      explanation:
                          'Choose which data categories stay local (e.g. imaging & raw logs) and which synchronize (e.g. medication reminders & AI summaries).',
                      icon: Icons.tune_rounded,
                      accentColor: AppColors.accentIndigo,
                      isSelected: selectedMode == StorageMode.hybrid,
                      onTap: () {
                        ref.read(storageSelectionProvider.notifier).setStorageMode(StorageMode.hybrid);
                      },
                    ),
                  ],
                ),
              ),

              PrimaryButton(
                label: 'Confirm & Setup Permissions',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  context.go('/permissions');
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _StorageOptionCard extends StatelessWidget {
  final StorageMode mode;
  final String tag;
  final String title;
  final String explanation;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _StorageOptionCard({
    required this.mode,
    required this.tag,
    required this.title,
    required this.explanation,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(
          color: isSelected ? accentColor : AppColors.border,
          width: isSelected ? 2.0 : 1.2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : AppDimensions.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? accentColor : AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tag,
                            style: AppTypography.labelSmall.copyWith(
                              color: isSelected ? accentColor : AppColors.textTertiary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            title,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Selection indicator
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? accentColor : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? accentColor : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  explanation,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

