import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? AppDimensions.borderRadiusMD;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: effectiveBorderRadius,
        border: border ?? Border.all(color: AppColors.border, width: 1.0),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: effectiveBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppDimensions.p16),
            child: child,
          ),
        ),
      ),
    );
  }
}
