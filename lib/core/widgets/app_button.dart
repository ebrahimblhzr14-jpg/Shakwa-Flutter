import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    BorderSide? borderSide;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = AppColors.primary;
        fgColor = Colors.white;
        borderSide = BorderSide.none;
        break;
      case AppButtonVariant.secondary:
        bgColor = AppColors.secondary;
        fgColor = Colors.white;
        borderSide = BorderSide.none;
        break;
      case AppButtonVariant.outline:
        bgColor = Colors.transparent;
        fgColor = AppColors.primary;
        borderSide = const BorderSide(color: AppColors.border, width: 1.5);
        break;
      case AppButtonVariant.danger:
        bgColor = AppColors.error;
        fgColor = Colors.white;
        borderSide = BorderSide.none;
        break;
    }

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 20, color: fgColor),
            const SizedBox(width: AppDimensions.p8),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: fgColor,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height ?? AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.6),
          elevation: variant == AppButtonVariant.primary ? 2 : 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusMD,
            side: borderSide,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        child: content,
      ),
    );
  }
}
