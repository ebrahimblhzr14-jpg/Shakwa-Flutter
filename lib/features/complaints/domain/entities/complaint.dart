import 'package:equatable/equatable.dart';
import '../../../../data/models/complaint_model.dart';
import 'complaint_status.dart';

/// Domain entity representing a complaint in the system.
class Complaint extends Equatable {
  final int id;
  final int userId;
  final String? userName;
  final String? userImageUrl;
  final int categoryId;
  final String? categoryName;
  final int? departmentId;
  final String? departmentName;
  final int statusId;
  final String? statusName;
  final ComplaintStatus status;
  final int priorityId;
  final String? priorityName;
  final ComplaintPriority priority;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;

  const Complaint({
    required this.id,
    required this.userId,
    this.userName,
    this.userImageUrl,
    required this.categoryId,
    this.categoryName,
    this.departmentId,
    this.departmentName,
    required this.statusId,
    this.statusName,
    required this.status,
    required this.priorityId,
    this.priorityName,
    required this.priority,
    required this.title,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.closedAt,
  });

  bool get isClosed => status == ComplaintStatus.closed || closedAt != null;
  bool get isEditable => status == ComplaintStatus.pending && closedAt == null;

  /// Adapts domain entity to legacy model for UI widgets that expect [ComplaintModel].
  ComplaintModel toLegacyModel() {
    return ComplaintModel(
      id: id.toString(),
      complaintNumber: '#$id',
      title: title,
      description: description,
      category: categoryName ?? 'عام',
      priority: priority.toLegacyPriority(),
      status: status.toLegacyStatus(),
      location: departmentName ?? 'عام',
      submittedByUserId: userId.toString(),
      submittedByName: userName ?? '',
      assignedToUserId: status == ComplaintStatus.pending ? null : 'assigned',
      createdAt: createdAt,
      updatedAt: updatedAt ?? createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userImageUrl,
    categoryId,
    categoryName,
    departmentId,
    departmentName,
    statusId,
    statusName,
    status,
    priorityId,
    priorityName,
    priority,
    title,
    description,
    createdAt,
    updatedAt,
    resolvedAt,
    closedAt,
  ];
}
