import '../../domain/entities/complaint.dart';
import '../../domain/entities/complaint_status.dart';

/// Data model representing Complaint DTO from ASP.NET Core API.
class ComplaintDto {
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
  final int priorityId;
  final String? priorityName;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;

  const ComplaintDto({
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
    required this.priorityId,
    this.priorityName,
    required this.title,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.closedAt,
  });

  factory ComplaintDto.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value, [DateTime? fallback]) {
      if (value == null) return fallback ?? DateTime.now();
      return DateTime.tryParse(value.toString()) ??
          (fallback ?? DateTime.now());
    }

    DateTime? parseNullableDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return ComplaintDto(
      id: json['id'] ?? json['Id'] ?? 0,
      userId: json['userId'] ?? json['UserId'] ?? 0,
      userName: (json['userName'] ?? json['UserName'])?.toString(),
      userImageUrl: (json['userImageUrl'] ?? json['UserImageUrl'])?.toString(),
      categoryId: json['categoryId'] ?? json['CategoryId'] ?? 0,
      categoryName: (json['categoryName'] ?? json['CategoryName'])?.toString(),
      departmentId: json['departmentId'] ?? json['DepartmentId'],
      departmentName: (json['departmentName'] ?? json['DepartmentName'])
          ?.toString(),
      statusId: json['statusId'] ?? json['StatusId'] ?? 1,
      statusName: (json['statusName'] ?? json['StatusName'])?.toString(),
      priorityId: json['priorityId'] ?? json['PriorityId'] ?? 1,
      priorityName: (json['priorityName'] ?? json['PriorityName'])?.toString(),
      title: (json['title'] ?? json['Title'] ?? '').toString(),
      description: (json['description'] ?? json['Description'] ?? '')
          .toString(),
      createdAt: parseDate(json['createdAt'] ?? json['CreatedAt']),
      updatedAt: parseNullableDate(json['updatedAt'] ?? json['UpdatedAt']),
      resolvedAt: parseNullableDate(json['resolvedAt'] ?? json['ResolvedAt']),
      closedAt: parseNullableDate(json['closedAt'] ?? json['ClosedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'statusId': statusId,
      'statusName': statusName,
      'priorityId': priorityId,
      'priorityName': priorityName,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
    };
  }

  Complaint toEntity() {
    return Complaint(
      id: id,
      userId: userId,
      userName: userName,
      userImageUrl: userImageUrl,
      categoryId: categoryId,
      categoryName: categoryName,
      departmentId: departmentId,
      departmentName: departmentName,
      statusId: statusId,
      statusName: statusName,
      status: ComplaintStatus.fromId(statusId),
      priorityId: priorityId,
      priorityName: priorityName,
      priority: ComplaintPriority.fromId(priorityId),
      title: title,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      resolvedAt: resolvedAt,
      closedAt: closedAt,
    );
  }
}

/// Type alias for backward compatibility / ergonomic naming.
typedef ComplaintModel = ComplaintDto;
