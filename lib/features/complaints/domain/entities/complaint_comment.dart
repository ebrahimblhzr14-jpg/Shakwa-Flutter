import 'package:equatable/equatable.dart';

/// Domain entity representing a complaint comment.
class ComplaintComment extends Equatable {
  final int id;
  final int complaintId;
  final int userId;
  final String userName;
  final String? userImageUrl;
  final String comment;
  final DateTime createdAt;
  final String userRoleText;

  const ComplaintComment({
    required this.id,
    required this.complaintId,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.comment,
    required this.createdAt,
    this.userRoleText = 'موظف مختص',
  });

  @override
  List<Object?> get props => [
    id,
    complaintId,
    userId,
    userName,
    userImageUrl,
    comment,
    createdAt,
    userRoleText,
  ];
}
