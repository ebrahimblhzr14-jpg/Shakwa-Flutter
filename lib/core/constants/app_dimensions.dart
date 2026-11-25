import 'package:flutter/material.dart';

/// Centralized UI Spacing and Dimension constants
class AppDimensions {
  AppDimensions._();

  // Spacing & Padding
  static const double p4 = 4.0;
  static const double p6 = 6.0;
  static const double p8 = 8.0;
  static const double p10 = 10.0;
  static const double p12 = 12.0;
  static const double p14 = 14.0;
  static const double p16 = 16.0;
  static const double p18 = 18.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;

  // Border Radii
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 999.0;

  static const BorderRadius borderRadiusSM = BorderRadius.all(
    Radius.circular(radiusSM),
  );
  static const BorderRadius borderRadiusMD = BorderRadius.all(
    Radius.circular(radiusMD),
  );
  static const BorderRadius borderRadiusLG = BorderRadius.all(
    Radius.circular(radiusLG),
  );
  static const BorderRadius borderRadiusXL = BorderRadius.all(
    Radius.circular(radiusXL),
  );
  static const BorderRadius borderRadiusFull = BorderRadius.all(
    Radius.circular(radiusFull),
  );

  // Component Heights
  static const double buttonHeight = 52.0;
  static const double inputHeight = 52.0;
  static const double buttonHeightSmall = 38.0;

  // Elevation & Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get dialogShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.15),
      offset: const Offset(0, 10),
      blurRadius: 28,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: const Color(0xFF162B4A).withValues(alpha: 0.25),
      offset: const Offset(0, 4),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];
}
