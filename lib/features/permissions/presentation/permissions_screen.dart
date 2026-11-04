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
        title: const Text('Permissions & Data Sources'),
        actions: [
          TextButton(
            onPressed: () {
              if (grantedCount == permissions.length) {
                ref.read(permissionsProvider.notifier).revokeAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All health data sources disconnected.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ref.read(permissionsProvider.notifier).grantAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All health data sources successfully connected!'),
                    backgroundColor: AppColors.secondary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              grantedCount == permissions.length ? 'Disconnect All' : 'Connect All',
              style: const TextStyle(fontWeight: FontWeight.w700),
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
              // Progress Bar (Step 3 of 3)
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
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Permissions Centre',
                          style: AppTypography.displaySmall.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Explicit authorization is required before reading any health metrics.',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: grantedCount > 0 ? AppColors.secondaryContainer : AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      '$grantedCount of ${permissions.length} Connected',
                      style: AppTypography.labelSmall.copyWith(
                        color: grantedCount > 0 ? AppColors.secondaryDark : AppColors.textTertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: permissions.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = permissions[index];
                    final isGranted = item.status == PermissionStatus.granted;

                    return GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isGranted
                                      ? AppColors.secondaryContainer
                                      : AppColors.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                ),
                                child: Icon(
                                  item.icon,
                                  color: isGranted ? AppColors.secondaryDark : AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: AppTypography.titleMedium.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        StatusBadge(
                                          label: isGranted ? 'Connected' : 'Not Connected',
                                          type: isGranted ? BadgeType.success : BadgeType.neutral,
                                          icon: isGranted ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.description,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 14,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Why needed: ${item.rationale}',
                                    style: AppTypography.bodySmall.copyWith(
                                      fontSize: 11,
                                      color: AppColors.textTertiary,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                side: BorderSide(
                                  color: isGranted ? AppColors.border : AppColors.secondary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                ),
                              ),
                              onPressed: () {
                                ref
                                    .read(permissionsProvider.notifier)
                                    .togglePermission(item.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isGranted
                                          ? 'Disconnected ${item.title}'
                                          : 'Connected ${item.title} data source',
                                    ),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: isGranted
                                        ? AppColors.primary
                                        : AppColors.secondary,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isGranted ? Icons.check : Icons.add_link_rounded,
                                    size: 16,
                                    color: isGranted ? AppColors.textSecondary : AppColors.secondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isGranted ? 'Disconnect' : 'Connect / Enable',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: isGranted ? AppColors.textSecondary : AppColors.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              PrimaryButton(
                label: 'Enter MediVision Dashboard',
                icon: Icons.dashboard_rounded,
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
