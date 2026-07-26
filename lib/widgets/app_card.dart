import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;
  final Color? glowColor;
  final Color? leftAccentColor;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.padding = const EdgeInsets.all(12),
    this.color,
    this.radius = AppRadius.md,
    this.glowColor,
    this.leftAccentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          ...AppShadows.card,
          if (glowColor != null)
            BoxShadow(color: glowColor!.withValues(alpha: 0.4), blurRadius: 16, spreadRadius: 0.5),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Material(
          color: color ?? AppColors.surface,
          shape: glowColor != null
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                  side: BorderSide(color: glowColor!, width: 1.4),
                )
              : null,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (leftAccentColor != null) Container(width: 4, color: leftAccentColor),
                Expanded(
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(padding: padding, child: child),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
