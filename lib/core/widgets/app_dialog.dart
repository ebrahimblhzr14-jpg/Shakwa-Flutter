import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'app_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final bool isDestructive;

  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.cancelText,
    required this.onConfirm,
    this.onCancel,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.isDestructive = false,
  });

  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    bool isDestructive = false,
    IconData icon = Icons.help_outline_rounded,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AppDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          icon: icon,
          iconColor: isDestructive ? AppColors.error : AppColors.primary,
          iconBgColor: isDestructive
              ? AppColors.errorBg
              : AppColors.primarySurface,
          isDestructive: isDestructive,
          onConfirm: () => Navigator.of(ctx).pop(true),
          onCancel: () => Navigator.of(ctx).pop(false),
        ),
      ),
    );
  }

  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'حسناً',
    VoidCallback? onDismiss,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AppDialog(
          title: title,
          message: message,
          confirmText: buttonText,
          icon: Icons.check_circle_outline_rounded,
          iconColor: AppColors.success,
          iconBgColor: AppColors.successBg,
          onConfirm: () {
            Navigator.of(ctx).pop();
            onDismiss?.call();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLG),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.p24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimensions.borderRadiusLG,
          boxShadow: AppDimensions.dialogShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(height: AppDimensions.p16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: AppDimensions.p8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: AppDimensions.p24),
            Row(
              children: [
                if (cancelText != null) ...[
                  Expanded(
                    child: AppButton(
                      text: cancelText!,
                      variant: AppButtonVariant.outline,
                      height: 44,
                      onPressed: onCancel ?? () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.p12),
                ],
                Expanded(
                  child: AppButton(
                    text: confirmText,
                    variant: isDestructive
                        ? AppButtonVariant.danger
                        : AppButtonVariant.primary,
                    height: 44,
                    onPressed: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
