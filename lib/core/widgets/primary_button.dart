import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

enum ButtonVariant { primary, secondary, outline, text }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    Color getBackgroundColor() {
      switch (variant) {
        case ButtonVariant.primary:
          return AppColors.primary;
        case ButtonVariant.secondary:
          return AppColors.secondary;
        case ButtonVariant.outline:
        case ButtonVariant.text:
          return Colors.transparent;
      }
    }

    Color getForegroundColor() {
      switch (variant) {
        case ButtonVariant.primary:
        case ButtonVariant.secondary:
          return Colors.white;
        case ButtonVariant.outline:
          return AppColors.primary;
        case ButtonVariant.text:
          return AppColors.secondary;
      }
    }

    BorderSide? getBorder() {
      if (variant == ButtonVariant.outline) {
        return const BorderSide(color: AppColors.border, width: 1.5);
      }
      return null;
    }

    Widget content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(getForegroundColor()),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: getForegroundColor()),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: getForegroundColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: getBackgroundColor(),
      foregroundColor: getForegroundColor(),
      elevation: 0,
      side: getBorder(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
    );

    Widget button = SizedBox(
      height: height,
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: isLoading ? null : onPressed,
        child: content,
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
