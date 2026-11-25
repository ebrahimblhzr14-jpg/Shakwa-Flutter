import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../data/models/complaint_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'app_card.dart';
import 'app_status_badge.dart';
import 'app_priority_badge.dart';

class ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final VoidCallback onTap;
  final Widget? trailingAction;

  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.onTap,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd');
    final formattedDate = dateFormat.format(complaint.createdAt);
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppDimensions.p12),
      padding: const EdgeInsets.all(AppDimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Number + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: AppDimensions.borderRadiusSM,
                ),
                child: Text(
                  complaint.complaintNumber,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              AppStatusBadge(status: complaint.status),
            ],
          ),
          const SizedBox(height: AppDimensions.p12),
          // Title
          Text(
            complaint.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.4,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: AppDimensions.p8),
          // Location
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppDimensions.p4),
              Expanded(
                child: Text(
                  complaint.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.p12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppDimensions.p10),
          // Footer: Priority + Category + Date
          Row(
            children: [
              AppPriorityBadge(priority: complaint.priority),
              const SizedBox(width: AppDimensions.p8),
              Expanded(
                child: Text(
                  complaint.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              if (trailingAction != null) ...[
                const SizedBox(width: AppDimensions.p8),
                trailingAction!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}
