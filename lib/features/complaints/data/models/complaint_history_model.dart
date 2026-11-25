import '../../domain/entities/complaint_history_item.dart';

/// Data model representing History DTO from ASP.NET Core API.
class ComplaintHistoryModel {
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

  const ComplaintHistoryModel({
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

  factory ComplaintHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt'] ?? json['CreatedAt'];
    final parsedDate = rawDate != null
        ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now()
        : DateTime.now();

    return ComplaintHistoryModel(
      id: json['id'] ?? json['Id'] ?? 0,
      complaintId: json['complaintId'] ?? json['ComplaintId'] ?? 0,
      userId: json['userId'] ?? json['UserId'],
      userName: (json['userName'] ?? json['UserName'])?.toString(),
      userImageUrl: (json['userImageUrl'] ?? json['UserImageUrl'])?.toString(),
      action: (json['action'] ?? json['Action'] ?? '').toString(),
      oldValue: (json['oldValue'] ?? json['OldValue'])?.toString(),
      newValue: (json['newValue'] ?? json['NewValue'])?.toString(),
      description: (json['description'] ?? json['Description'])?.toString(),
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
      'action': action,
      'oldValue': oldValue,
      'newValue': newValue,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ComplaintHistoryItem toEntity() {
    return ComplaintHistoryItem(
      id: id,
      complaintId: complaintId,
      userId: userId,
      userName: userName,
      userImageUrl: userImageUrl,
      action: action,
      oldValue: oldValue,
      newValue: newValue,
      description: description,
      createdAt: createdAt,
    );
  }
}
