import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_typography.dart';

enum BadgeType { success, warning, error, info, neutral }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;
  final bool isPill;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = BadgeType.info,
    this.icon,
    this.isPill = false,
  });

  @override
  Widget build(BuildContext context) {
    Color getBackgroundColor() {
      switch (type) {
        case BadgeType.success:
          return AppColors.successBackground;
        case BadgeType.warning:
          return AppColors.warningBackground;
        case BadgeType.error:
          return AppColors.errorBackground;
        case BadgeType.info:
          return AppColors.infoBackground;
        case BadgeType.neutral:
          return AppColors.surfaceSubtle;
      }
    }

    Color getTextColor() {
      switch (type) {
        case BadgeType.success:
          return AppColors.success;
        case BadgeType.warning:
          return AppColors.warning;
        case BadgeType.error:
          return AppColors.error;
        case BadgeType.info:
          return AppColors.info;
        case BadgeType.neutral:
          return AppColors.textSecondary;
      }
    }

    final textColor = getTextColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: getBackgroundColor(),
        borderRadius: BorderRadius.circular(
          isPill ? AppDimensions.radiusFull : AppDimensions.radiusS,
        ),
        border: Border.all(
          color: textColor.withValues(alpha: 0.18),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: textColor),
            const SizedBox(width: 3.5),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
