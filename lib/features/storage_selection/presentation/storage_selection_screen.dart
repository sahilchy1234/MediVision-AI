import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
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
        title: Text(
          'Storage Architecture',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
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
              // Clean Step Indicator (Step 2 of 3)
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
                ],
              ),
              const SizedBox(height: 18),

              Text(
                'Data Storage Preference',
                style: AppTypography.displayMedium.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose where your encrypted clinical records and logs are stored.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 18),

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _StorageOptionCard(
                      mode: StorageMode.local,
                      title: 'Local Device Only',
                      explanation:
                          'Your health records stay encrypted exclusively on this device with zero cloud transmissions.',
                      icon: Icons.phonelink_lock_rounded,
                      isSelected: selectedMode == StorageMode.local,
                      onTap: () {
                        ref
                            .read(storageSelectionProvider.notifier)
                            .setStorageMode(StorageMode.local);
                      },
                    ),
                    const SizedBox(height: 10),
                    _StorageOptionCard(
                      mode: StorageMode.cloud,
                      title: 'Zero-Knowledge Cloud Sync',
                      explanation:
                          'End-to-end encrypted backup and sync across all your devices using your private keys.',
                      icon: Icons.cloud_sync_rounded,
                      isSelected: selectedMode == StorageMode.cloud,
                      onTap: () {
                        ref
                            .read(storageSelectionProvider.notifier)
                            .setStorageMode(StorageMode.cloud);
                      },
                    ),
                    const SizedBox(height: 10),
                    _StorageOptionCard(
                      mode: StorageMode.hybrid,
                      title: 'Hybrid Storage',
                      explanation:
                          'Raw imaging and documents stay local; vital metrics and appointment reminders sync securely.',
                      icon: Icons.tune_rounded,
                      isSelected: selectedMode == StorageMode.hybrid,
                      onTap: () {
                        ref
                            .read(storageSelectionProvider.notifier)
                            .setStorageMode(StorageMode.hybrid);
                      },
                    ),
                  ],
                ),
              ),

              PrimaryButton(
                label: 'Continue to Permissions',
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
  final String title;
  final String explanation;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _StorageOptionCard({
    required this.mode,
    required this.title,
    required this.explanation,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      borderColor: isSelected ? AppColors.secondary : AppColors.border,
      backgroundColor: isSelected ? AppColors.secondaryContainer : Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.secondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.secondaryDark : AppColors.textPrimary,
                      ),
                    ),
                    Radio<bool>(
                      value: true,
                      groupValue: isSelected,
                      activeColor: AppColors.secondary,
                      onChanged: (_) => onTap(),
                    ),
                  ],
                ),
                Text(
                  explanation,
                  style: AppTypography.bodySmall.copyWith(
                    color: isSelected ? AppColors.secondaryDark : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
