import 'package:flutter/material.dart';
import '../../data/models/status_model.dart';
import '../constants/app_dimensions.dart';

class AppStatusBadge extends StatelessWidget {
  final ComplaintStatus status;
  final bool showIcon;
  final double fontSize;

  const AppStatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: AppDimensions.borderRadiusFull,
        border: Border.all(
          color: status.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(status.icon, size: fontSize + 2, color: status.color),
            const SizedBox(width: AppDimensions.p4),
          ],
          Text(
            status.displayNameArabic,
            style: TextStyle(
              color: status.color,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
