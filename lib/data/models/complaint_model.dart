import 'priority_model.dart';
import 'status_model.dart';
import 'comment_model.dart';

class ComplaintModel {
  final String id;
  final String complaintNumber;
  final String title;
  final String description;
  final String category;
  final PriorityLevel priority;
  final ComplaintStatus status;
  final String location;
  final List<String> attachments;
  final String submittedByUserId;
  final String submittedByName;
  final String? assignedToUserId;
  final String? assignedToName;
  final String? department;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CommentModel> comments;
  final int? rating;
  final String? feedbackText;

  const ComplaintModel({
    required this.id,
    required this.complaintNumber,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.location,
    this.attachments = const [],
    required this.submittedByUserId,
    required this.submittedByName,
    this.assignedToUserId,
    this.assignedToName,
    this.department,
    required this.createdAt,
    required this.updatedAt,
    this.comments = const [],
    this.rating,
    this.feedbackText,
  });

  ComplaintModel copyWith({
    String? id,
    String? complaintNumber,
    String? title,
    String? description,
    String? category,
    PriorityLevel? priority,
    ComplaintStatus? status,
    String? location,
    List<String>? attachments,
    String? submittedByUserId,
    String? submittedByName,
    String? assignedToUserId,
    String? assignedToName,
    String? department,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CommentModel>? comments,
    int? rating,
    String? feedbackText,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      complaintNumber: complaintNumber ?? this.complaintNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      location: location ?? this.location,
      attachments: attachments ?? this.attachments,
      submittedByUserId: submittedByUserId ?? this.submittedByUserId,
      submittedByName: submittedByName ?? this.submittedByName,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      assignedToName: assignedToName ?? this.assignedToName,
      department: department ?? this.department,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      comments: comments ?? this.comments,
      rating: rating ?? this.rating,
      feedbackText: feedbackText ?? this.feedbackText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaintNumber': complaintNumber,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority.name,
      'status': status.name,
      'location': location,
      'attachments': attachments,
      'submittedByUserId': submittedByUserId,
      'submittedByName': submittedByName,
      'assignedToUserId': assignedToUserId,
      'assignedToName': assignedToName,
      'department': department,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'comments': comments.map((c) => c.toJson()).toList(),
      'rating': rating,
      'feedbackText': feedbackText,
    };
  }

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] as String,
      complaintNumber: json['complaintNumber'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      priority: PriorityLevel.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => PriorityLevel.medium,
      ),
      status: ComplaintStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ComplaintStatus.pending,
      ),
      location: json['location'] as String,
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      submittedByUserId: json['submittedByUserId'] as String,
      submittedByName: json['submittedByName'] as String,
      assignedToUserId: json['assignedToUserId'] as String?,
      assignedToName: json['assignedToName'] as String?,
      department: json['department'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((c) => CommentModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      rating: json['rating'] as int?,
      feedbackText: json['feedbackText'] as String?,
    );
  }
}
