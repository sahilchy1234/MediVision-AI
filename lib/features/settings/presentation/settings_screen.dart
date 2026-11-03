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
import '../../profile/providers/profile_provider.dart';
import '../../storage_selection/providers/storage_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _biometricsEnabled = true;
  bool _anonymousInsights = true;

  void _showChangeStorageDialog() {
    final current = ref.read(storageSelectionProvider);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusL)),
          title: const Text('Change Storage Mode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: StorageMode.values.map((mode) {
              return RadioListTile<StorageMode>(
                value: mode,
                groupValue: current,
                title: Text(mode.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(mode.description, style: const TextStyle(fontSize: 12)),
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
              child: const Text('Close'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusL)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.remove_red_eye_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('MediVision AI'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0-foundation',
              style: AppTypography.labelMedium.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: 12),
            Text(
              'Your Personal AI Health Companion & Intelligent Medical History Platform.\n\n'
              'Built with state-of-the-art Flutter architecture, strict Material 3 design systems, and zero-knowledge privacy standards.\n\n'
              'Disclaimer: MediVision AI is designed for personal health memory and clinical organization. It does not replace certified physician diagnosis.',
              style: AppTypography.bodySmall.copyWith(height: 1.45),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final storageMode = ref.watch(storageSelectionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          children: [
            // User Profile Header Card
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName,
                          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${profile.gender ?? "Individual"} • ${profile.heightCm?.toStringAsFixed(0) ?? 175} cm • ${profile.weightKg?.toStringAsFixed(1) ?? 68.5} kg',
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        const StatusBadge(
                          label: 'Clinical Profile Verified',
                          type: BadgeType.success,
                          icon: Icons.verified_user_rounded,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.secondary),
                    onPressed: () => context.push('/profile-setup'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Storage Section
            const SectionHeader(title: 'Storage & Data Architecture'),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: const Icon(Icons.cloud_sync_rounded, color: AppColors.secondaryDark),
                    ),
                    title: Text(storageMode.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      storageMode.description,
                      style: AppTypography.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: const Size(0, 32),
                      ),
                      onPressed: _showChangeStorageDialog,
                      child: const Text('Change'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Integration & Permissions
            const SectionHeader(title: 'Integrations & Access'),
            GlassCard(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.security_rounded, color: AppColors.primary),
                    title: const Text('Permissions Centre', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Manage sensor, sleep, and record authorization'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/permissions'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.watch_rounded, color: AppColors.secondary),
                    title: const Text('Connected Health Monitors', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Apple Watch Series 9, Oura Ring Gen 3 (Paired)'),
                    trailing: const StatusBadge(label: '2 Active', type: BadgeType.info),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Connected Devices: Apple Watch & Oura Ring active.')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Privacy & Security
            const SectionHeader(title: 'Privacy & Security'),
            GlassCard(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _biometricsEnabled,
                    activeColor: AppColors.secondary,
                    secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.primary),
                    title: const Text('Biometric Authentication', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Require FaceID / Fingerprint on launch'),
                    onChanged: (val) => setState(() => _biometricsEnabled = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: _anonymousInsights,
                    activeColor: AppColors.secondary,
                    secondary: const Icon(Icons.psychology_alt_rounded, color: AppColors.accentIndigo),
                    title: const Text('Differential Privacy Analysis', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Enable on-device model learning without raw data export'),
                    onChanged: (val) => setState(() => _anonymousInsights = val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.file_download_outlined, color: AppColors.accentEmerald),
                    title: const Text('Data Export & FHIR Transfer', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Export all personal health data in encrypted JSON/PDF'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Preparing secure FHIR data archive...')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // About & System
            const SectionHeader(title: 'Information & Support'),
            GlassCard(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                    title: const Text('About MediVision AI', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Platform architecture & medical notices'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _showAboutDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                    title: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                    onTap: () {
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
