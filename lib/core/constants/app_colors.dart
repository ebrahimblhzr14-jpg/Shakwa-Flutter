import 'package:flutter/material.dart';

/// Centralized Design System Colors for Shakwa (شكوى)
/// Extracted from approved brand visual identity and Figma specifications
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF162B4A); // Deep Navy Blue
  static const Color primaryDark = Color(0xFF0F1E33);
  static const Color primaryLight = Color(0xFF24426E);
  static const Color primarySurface = Color(0xFFEDF2F7);

  // Secondary / Accent Colors
  static const Color secondary = Color(0xFFF2912B); // Vibrant Amber / Orange
  static const Color secondaryDark = Color(0xFFD9771A);
  static const Color secondaryLight = Color(0xFFFDBA74);
  static const Color secondarySurface = Color(0xFFFFF7ED);

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocused = Color(0xFF162B4A);
  static const Color divider = Color(0xFFEEF2F6);

  // Status Colors (Complaints & Notifications)
  static const Color statusPending = Color(0xFFF59E0B); // Amber / جديد
  static const Color statusPendingBg = Color(0xFFFEF3C7);

  static const Color statusInProgress = Color(
    0xFF2563EB,
  ); // Blue / قيد المعالجة
  static const Color statusInProgressBg = Color(0xFFDBEAFE);

  static const Color statusResolved = Color(0xFF10B981); // Emerald / تم الحل
  static const Color statusResolvedBg = Color(0xFFD1FAE5);

  static const Color statusClosed = Color(0xFF64748B); // Slate / مغلقة
  static const Color statusClosedBg = Color(0xFFE2E8F0);

  static const Color statusRejected = Color(0xFFEF4444); // Red / مرفوضة
  static const Color statusRejectedBg = Color(0xFFFEE2E2);

  // Priority Colors
  static const Color priorityLow = Color(0xFF10B981);
  static const Color priorityLowBg = Color(0xFFECFDF5);

  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityMediumBg = Color(0xFFFFFBEB);

  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityHighBg = Color(0xFFFEF2F2);

  static const Color priorityUrgent = Color(0xFF7C3AED);
  static const Color priorityUrgentBg = Color(0xFFF5F3FF);

  // Feedback & Feedback States
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFD1FAE5);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFFFEE2E2);

  static const Color info = Color(0xFF0284C7);
  static const Color infoBg = Color(0xFFE0F2FE);

  // Rating Star Color
  static const Color ratingStar = Color(0xFFFBBF24);
}
