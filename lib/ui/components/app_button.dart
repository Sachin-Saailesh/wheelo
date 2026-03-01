import 'package:flutter/material.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_typography.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.primary
                    ? AppColors.textInverse
                    : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          text,
          style: AppTypography.textTheme.labelLarge?.copyWith(
            color: _getTextColor(),
          ),
        ),
      ],
    );

    final Widget button = _buildButtonVariant(context, buttonChild);

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Color _getTextColor() {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
        return AppColors.textInverse;
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
        return AppColors.primary;
    }
  }

  Widget _buildButtonVariant(BuildContext context, Widget child) {
    final bool isDisabled = onPressed == null || isLoading;
    final Function()? action = isDisabled ? null : onPressed;

    switch (variant) {
      case AppButtonVariant.primary:
        return FilledButton(onPressed: action, child: child);
      case AppButtonVariant.secondary:
        return FilledButton(
          onPressed: action,
          style: FilledButton.styleFrom(backgroundColor: AppColors.secondary),
          child: child,
        );
      case AppButtonVariant.outline:
        return OutlinedButton(onPressed: action, child: child);
      case AppButtonVariant.ghost:
        return TextButton(
          onPressed: action,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          child: child,
        );
    }
  }
}
