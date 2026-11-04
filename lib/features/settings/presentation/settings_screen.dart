import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../shared/models/storage_mode.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../permissions/data/permission_item.dart';
import '../../permissions/providers/permissions_provider.dart';
import '../../profile/data/models/user_profile_model.dart';
import '../../profile/providers/profile_provider.dart';
import '../../storage_selection/providers/storage_provider.dart';
import '../../authentication/data/auth_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _biometricsEnabled = true;

  void _showChangeStorageDialog() {
    final current = ref.read(storageSelectionProvider);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          title: const Text('Storage Mode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: StorageMode.values.map((mode) {
              return RadioListTile<StorageMode>(
                value: mode,
                groupValue: current,
                title: Text(
                  mode.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
                subtitle: Text(
                  mode.description,
                  style: const TextStyle(fontSize: 12),
                ),
                onChanged: (newMode) {
                  if (newMode != null) {
                    ref.read(storageSelectionProvider.notifier).setStorageMode(newMode);
                    Navigator.pop(context);
                    setState(() {});
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('About MediVision'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0 (Production)',
              style: AppTypography.labelMedium.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: 10),
            Text(
              'MediVision organizes personal health metrics, medical records, and clinical timelines with client-side zero-knowledge encryption.\n\n'
              'Notice: MediVision is an information management and consultation aid and does not substitute for emergency medical care or direct clinical diagnosis.',
              style: AppTypography.bodySmall.copyWith(height: 1.45),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final storageMode = ref.watch(storageSelectionProvider);
    final permissions = ref.watch(permissionsProvider);
    final connectedCount = permissions.where((p) => p.status == PermissionStatus.granted).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          children: [
            // User Profile Header Card
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${profile.gender ?? "Patient"} • ${profile.heightCm?.toStringAsFixed(0) ?? 175} cm • ${profile.weightKg?.toStringAsFixed(1) ?? 68.5} kg',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
                    onPressed: () => context.push('/profile-setup'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Storage Architecture Section
            const SectionHeader(title: 'Data & Storage'),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.cloud_queue_rounded, color: AppColors.secondary, size: 18),
                ),
                title: Text(
                  storageMode.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
                subtitle: Text(
                  storageMode.description,
                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: TextButton(
                  onPressed: _showChangeStorageDialog,
                  child: const Text('Change'),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Integrations & Permissions
            const SectionHeader(title: 'Connected Health Sources'),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 18),
                    ),
                    title: const Text(
                      'Data Permissions',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    subtitle: Text(
                      '$connectedCount of ${permissions.length} active',
                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
                    onTap: () => context.push('/permissions'),
                  ),
                  if (profile.isFemale) ...[
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.accentRose.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.water_drop_outlined, color: AppColors.accentRose, size: 18),
                      ),
                      title: const Text(
                        "Women's Health Settings",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                      ),
                      subtitle: Text(
                        'Cycle tracking & private vault',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
                      onTap: () => context.push('/womens-health'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Privacy & Security
            const SectionHeader(title: 'Security'),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _biometricsEnabled,
                    activeColor: AppColors.secondary,
                    secondary: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 18),
                    ),
                    title: const Text(
                      'Biometric Lock',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    subtitle: Text(
                      'Require authentication on open',
                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                    ),
                    onChanged: (val) => setState(() => _biometricsEnabled = val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.download_outlined, color: AppColors.secondary, size: 18),
                    ),
                    title: const Text(
                      'Export Health Archive',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    subtitle: Text(
                      'Download records in JSON / PDF format',
                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Exporting patient health archive...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Information & Sign Out
            const SectionHeader(title: 'Account'),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 18),
                    ),
                    title: const Text(
                      'About MediVision',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
                    onTap: _showAboutDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.errorBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                    ),
                    title: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: AppColors.error,
                      ),
                    ),
                    onTap: () async {
                      await AuthService.logout();
                      ref.read(profileProvider.notifier).updateProfile(UserProfileModel.defaultMock);
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
