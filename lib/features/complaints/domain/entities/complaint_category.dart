import 'package:equatable/equatable.dart';

/// Domain entity representing a complaint category.
class ComplaintCategory extends Equatable {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  const ComplaintCategory({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, description, isActive];
}
