import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/permission_item.dart';
import '../providers/permissions_provider.dart';

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsProvider);
    final grantedCount =
        permissions.where((p) => p.status == PermissionStatus.granted).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Data Permissions',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (grantedCount == permissions.length) {
                ref.read(permissionsProvider.notifier).revokeAll();
              } else {
                ref.read(permissionsProvider.notifier).grantAll();
              }
            },
            child: Text(
              grantedCount == permissions.length ? 'Revoke All' : 'Grant All',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clean Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Connected Health Feeds',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  StatusBadge(
                    label: '$grantedCount of ${permissions.length} active',
                    type: grantedCount > 0 ? BadgeType.success : BadgeType.neutral,
                    isPill: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Permissions List
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: permissions.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = permissions[index];
                    final isGranted = item.status == PermissionStatus.granted;

                    return GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isGranted
                                  ? AppColors.secondaryContainer
                                  : AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              item.icon,
                              color: isGranted ? AppColors.secondary : AppColors.textTertiary,
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
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.description,
                                  style: AppTypography.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch.adaptive(
                            value: isGranted,
                            activeColor: AppColors.secondary,
                            onChanged: (_) {
                              ref
                                  .read(permissionsProvider.notifier)
                                  .togglePermission(item.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              PrimaryButton(
                label: 'Save & Return to Dashboard',
                onPressed: () {
                  context.go('/home');
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
