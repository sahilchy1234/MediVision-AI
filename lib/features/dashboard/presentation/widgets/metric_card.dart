import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final String? unit;
  final String? comparison;
  final IconData icon;
  final Color iconColor;
  final double? progress; // 0.0 to 1.0
  final Color? progressColor;
  final String? badgeText;
  final Color? badgeColor;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.unit,
    this.comparison,
    required this.icon,
    this.iconColor = AppColors.secondaryText,
    this.progress,
    this.progressColor,
    this.badgeText,
    this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSubtitle = comparison ?? subtitle;
    final effectiveProgressColor = progressColor ?? iconColor;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? iconColor).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    badgeText!,
                    style: AppTypography.labelSmall.copyWith(
                      color: badgeColor ?? iconColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.metricLarge,
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.surfaceSubtle,
                valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
              ),
            ),
          ],
          if (effectiveSubtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              effectiveSubtitle,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
