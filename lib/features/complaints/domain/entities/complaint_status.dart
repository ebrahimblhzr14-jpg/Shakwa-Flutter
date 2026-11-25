import 'package:flutter/material.dart';
import '../../../../data/models/priority_model.dart' as legacy_priority;
import '../../../../data/models/status_model.dart' as legacy_status;

/// Domain representation of Complaint Status and Priority with backend ID mapping.
enum ComplaintStatus {
  pending(1, 'جديدة', 'Pending'),
  underReview(2, 'قيد المراجعة', 'Under Review'),
  inProgress(3, 'قيد المعالجة', 'In Progress'),
  resolved(4, 'تم الحل', 'Resolved'),
  closed(5, 'مغلقة', 'Closed'),
  unknown(0, 'غير معروف', 'Unknown');

  final int id;
  final String labelArabic;
  final String labelEnglish;

  const ComplaintStatus(this.id, this.labelArabic, this.labelEnglish);

  static ComplaintStatus fromId(int? id) {
    if (id == null) return ComplaintStatus.unknown;
    return ComplaintStatus.values.firstWhere(
      (e) => e.id == id,
      orElse: () => ComplaintStatus.unknown,
    );
  }

  static ComplaintStatus fromString(String? name) {
    if (name == null || name.trim().isEmpty) return ComplaintStatus.unknown;
    final normalized = name.trim().toLowerCase();
    if (normalized.contains('pend') || normalized.contains('جديد')) {
      return ComplaintStatus.pending;
    }
    if (normalized.contains('review') || normalized.contains('مراجع')) {
      return ComplaintStatus.underReview;
    }
    if (normalized.contains('progress') || normalized.contains('معالج')) {
      return ComplaintStatus.inProgress;
    }
    if (normalized.contains('resolv') || normalized.contains('حل')) {
      return ComplaintStatus.resolved;
    }
    if (normalized.contains('close') || normalized.contains('مغلق')) {
      return ComplaintStatus.closed;
    }
    return ComplaintStatus.unknown;
  }

  bool get isClosed => this == ComplaintStatus.closed;
  bool get isPending => this == ComplaintStatus.pending;
  bool get isInProgress => this == ComplaintStatus.inProgress;
  bool get isResolved => this == ComplaintStatus.resolved;
  bool get isUnderReview => this == ComplaintStatus.underReview;

  String get displayNameArabic => labelArabic;

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
      case ComplaintStatus.unknown:
        return const Color(0xFF94A3B8);
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
      case ComplaintStatus.unknown:
        return const Color(0xFFF1F5F9);
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
      case ComplaintStatus.unknown:
        return Icons.help_outline_rounded;
    }
  }

  legacy_status.ComplaintStatus toLegacyStatus() {
    switch (this) {
      case ComplaintStatus.pending:
        return legacy_status.ComplaintStatus.pending;
      case ComplaintStatus.underReview:
        return legacy_status.ComplaintStatus.underReview;
      case ComplaintStatus.inProgress:
        return legacy_status.ComplaintStatus.inProgress;
      case ComplaintStatus.resolved:
        return legacy_status.ComplaintStatus.resolved;
      case ComplaintStatus.closed:
        return legacy_status.ComplaintStatus.closed;
      case ComplaintStatus.unknown:
        return legacy_status.ComplaintStatus.pending;
    }
  }
}

enum ComplaintPriority {
  low(1, 'منخفضة', 'Low'),
  medium(2, 'متوسطة', 'Medium'),
  high(3, 'عالية', 'High'),
  urgent(4, 'حرجة / طارئة', 'Urgent'),
  unknown(0, 'غير محدد', 'Unknown');

  final int id;
  final String labelArabic;
  final String labelEnglish;

  const ComplaintPriority(this.id, this.labelArabic, this.labelEnglish);

  static ComplaintPriority fromId(int? id) {
    if (id == null) return ComplaintPriority.unknown;
    return ComplaintPriority.values.firstWhere(
      (e) => e.id == id,
      orElse: () => ComplaintPriority.unknown,
    );
  }

  static ComplaintPriority fromString(String? name) {
    if (name == null || name.trim().isEmpty) return ComplaintPriority.unknown;
    final normalized = name.trim().toLowerCase();
    if (normalized.contains('low') || normalized.contains('منخفض')) {
      return ComplaintPriority.low;
    }
    if (normalized.contains('med') || normalized.contains('توسط')) {
      return ComplaintPriority.medium;
    }
    if (normalized.contains('high') || normalized.contains('عال')) {
      return ComplaintPriority.high;
    }
    if (normalized.contains('urg') ||
        normalized.contains('حرج') ||
        normalized.contains('طارئ')) {
      return ComplaintPriority.urgent;
    }
    return ComplaintPriority.unknown;
  }

  String get displayNameArabic => labelArabic;

  Color get color {
    switch (this) {
      case ComplaintPriority.low:
        return const Color(0xFF10B981);
      case ComplaintPriority.medium:
        return const Color(0xFFF59E0B);
      case ComplaintPriority.high:
        return const Color(0xFFEF4444);
      case ComplaintPriority.urgent:
      case ComplaintPriority.unknown:
        return const Color(0xFF7C3AED);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ComplaintPriority.low:
        return const Color(0xFFECFDF5);
      case ComplaintPriority.medium:
        return const Color(0xFFFFFBEB);
      case ComplaintPriority.high:
        return const Color(0xFFFEF2F2);
      case ComplaintPriority.urgent:
      case ComplaintPriority.unknown:
        return const Color(0xFFF5F3FF);
    }
  }

  legacy_priority.PriorityLevel toLegacyPriority() {
    switch (this) {
      case ComplaintPriority.low:
        return legacy_priority.PriorityLevel.low;
      case ComplaintPriority.medium:
        return legacy_priority.PriorityLevel.medium;
      case ComplaintPriority.high:
        return legacy_priority.PriorityLevel.high;
      case ComplaintPriority.urgent:
      case ComplaintPriority.unknown:
        return legacy_priority.PriorityLevel.urgent;
    }
  }
}
