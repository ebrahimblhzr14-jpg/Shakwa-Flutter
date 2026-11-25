import '../../domain/entities/complaint_comment.dart';

/// Data model representing Comment DTO from ASP.NET Core API.
class ComplaintCommentModel {
  final int id;
  final int complaintId;
  final int userId;
  final String? userName;
  final String? userImageUrl;
  final String comment;
  final DateTime createdAt;

  const ComplaintCommentModel({
    required this.id,
    required this.complaintId,
    required this.userId,
    this.userName,
    this.userImageUrl,
    required this.comment,
    required this.createdAt,
  });

  factory ComplaintCommentModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt'] ?? json['CreatedAt'];
    final parsedDate = rawDate != null
        ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now()
        : DateTime.now();

    return ComplaintCommentModel(
      id: json['id'] ?? json['Id'] ?? 0,
      complaintId: json['complaintId'] ?? json['ComplaintId'] ?? 0,
      userId: json['userId'] ?? json['UserId'] ?? 0,
      userName: (json['userName'] ?? json['UserName'])?.toString(),
      userImageUrl: (json['userImageUrl'] ?? json['UserImageUrl'])?.toString(),
      comment: (json['comment'] ?? json['Comment'] ?? '').toString(),
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaintId': complaintId,
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ComplaintComment toEntity() {
    return ComplaintComment(
      id: id,
      complaintId: complaintId,
      userId: userId,
      userName: userName?.isNotEmpty == true ? userName! : 'مستخدم',
      userImageUrl: userImageUrl,
      comment: comment,
      createdAt: createdAt,
      userRoleText: userId > 0 ? 'فريق العمل' : 'مواطن',
    );
  }
}
