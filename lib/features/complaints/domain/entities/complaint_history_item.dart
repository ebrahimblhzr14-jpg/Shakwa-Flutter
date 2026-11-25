import 'package:equatable/equatable.dart';

/// Domain entity representing an entry in the complaint audit/history timeline.
class ComplaintHistoryItem extends Equatable {
  final int id;
  final int complaintId;
  final int? userId;
  final String? userName;
  final String? userImageUrl;
  final String action;
  final String? oldValue;
  final String? newValue;
  final String? description;
  final DateTime createdAt;

  const ComplaintHistoryItem({
    required this.id,
    required this.complaintId,
    this.userId,
    this.userName,
    this.userImageUrl,
    required this.action,
    this.oldValue,
    this.newValue,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    complaintId,
    userId,
    userName,
    userImageUrl,
    action,
    oldValue,
    newValue,
    description,
    createdAt,
  ];
}
