import 'package:flutter/material.dart';
import '../../data/models/priority_model.dart';
import '../constants/app_dimensions.dart';

class AppPriorityBadge extends StatelessWidget {
  final PriorityLevel priority;
  final double fontSize;

  const AppPriorityBadge({
    super.key,
    required this.priority,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: priority.backgroundColor,
        borderRadius: AppDimensions.borderRadiusSM,
        border: Border.all(
          color: priority.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: priority.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.p4),
          Text(
            priority.displayNameArabic,
            style: TextStyle(
              color: priority.color,
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
