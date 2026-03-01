import 'package:flutter/material.dart';
import '../../design/app_spacing.dart';
import '../../design/app_elevation.dart';
import '../../design/app_radius.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool usePrimaryShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.color,
    this.usePrimaryShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget card = Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderRadiusXl,
        boxShadow: usePrimaryShadow
            ? AppElevation.shadowPrimary
            : AppElevation.shadowSm,
      ),
      child: Card(
        color: color,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    return card;
  }
}
