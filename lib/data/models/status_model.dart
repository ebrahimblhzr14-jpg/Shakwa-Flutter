import 'package:flutter/material.dart';

enum ComplaintStatus {
  pending,
  underReview,
  inProgress,
  resolved,
  closed,
  rejected;

  String get displayNameArabic {
    switch (this) {
      case ComplaintStatus.pending:
        return 'جديدة';
      case ComplaintStatus.underReview:
        return 'قيد المراجعة';
      case ComplaintStatus.inProgress:
        return 'قيد المعالجة';
      case ComplaintStatus.resolved:
        return 'تم الحل';
      case ComplaintStatus.closed:
        return 'مغلقة';
      case ComplaintStatus.rejected:
        return 'مرفوضة';
    }
  }

  Color get color {
    switch (this) {
      case ComplaintStatus.pending:
        return const Color(0xFFF59E0B);
      case ComplaintStatus.underReview:
        return const Color(0xFF0284C7);
      case ComplaintStatus.inProgress:
        return const Color(0xFF2563EB);
      case ComplaintStatus.resolved:
        return const Color(0xFF10B981);
      case ComplaintStatus.closed:
        return const Color(0xFF64748B);
      case ComplaintStatus.rejected:
        return const Color(0xFFEF4444);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ComplaintStatus.pending:
        return const Color(0xFFFEF3C7);
      case ComplaintStatus.underReview:
        return const Color(0xFFE0F2FE);
      case ComplaintStatus.inProgress:
        return const Color(0xFFDBEAFE);
      case ComplaintStatus.resolved:
        return const Color(0xFFD1FAE5);
      case ComplaintStatus.closed:
        return const Color(0xFFE2E8F0);
      case ComplaintStatus.rejected:
        return const Color(0xFFFEE2E2);
    }
  }

  IconData get icon {
    switch (this) {
      case ComplaintStatus.pending:
        return Icons.hourglass_top_rounded;
      case ComplaintStatus.underReview:
        return Icons.remove_red_eye_rounded;
      case ComplaintStatus.inProgress:
        return Icons.build_circle_rounded;
      case ComplaintStatus.resolved:
        return Icons.check_circle_rounded;
      case ComplaintStatus.closed:
        return Icons.lock_clock_rounded;
      case ComplaintStatus.rejected:
        return Icons.cancel_rounded;
    }
  }
}

class StatusModel {
  final String id;
  final String name;
  final ComplaintStatus status;
  final String description;
  final bool isDefault;
  final int order;

  const StatusModel({
    required this.id,
    required this.name,
    required this.status,
    required this.description,
    this.isDefault = false,
    this.order = 1,
  });

  StatusModel copyWith({
    String? id,
    String? name,
    ComplaintStatus? status,
    String? description,
    bool? isDefault,
    int? order,
  }) {
    return StatusModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      description: description ?? this.description,
      isDefault: isDefault ?? this.isDefault,
      order: order ?? this.order,
    );
  }
}
