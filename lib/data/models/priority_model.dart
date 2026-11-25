import 'package:flutter/material.dart';

enum PriorityLevel {
  low,
  medium,
  high,
  urgent;

  String get displayNameArabic {
    switch (this) {
      case PriorityLevel.low:
        return 'منخفضة';
      case PriorityLevel.medium:
        return 'متوسطة';
      case PriorityLevel.high:
        return 'عالية';
      case PriorityLevel.urgent:
        return 'حرجة / طارئة';
    }
  }

  Color get color {
    switch (this) {
      case PriorityLevel.low:
        return const Color(0xFF10B981);
      case PriorityLevel.medium:
        return const Color(0xFFF59E0B);
      case PriorityLevel.high:
        return const Color(0xFFEF4444);
      case PriorityLevel.urgent:
        return const Color(0xFF7C3AED);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case PriorityLevel.low:
        return const Color(0xFFECFDF5);
      case PriorityLevel.medium:
        return const Color(0xFFFFFBEB);
      case PriorityLevel.high:
        return const Color(0xFFFEF2F2);
      case PriorityLevel.urgent:
        return const Color(0xFFF5F3FF);
    }
  }
}

class PriorityModel {
  final String id;
  final String name;
  final PriorityLevel level;
  final String description;
  final int slaHours;

  const PriorityModel({
    required this.id,
    required this.name,
    required this.level,
    required this.description,
    this.slaHours = 48,
  });

  PriorityModel copyWith({
    String? id,
    String? name,
    PriorityLevel? level,
    String? description,
    int? slaHours,
  }) {
    return PriorityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      description: description ?? this.description,
      slaHours: slaHours ?? this.slaHours,
    );
  }
}
