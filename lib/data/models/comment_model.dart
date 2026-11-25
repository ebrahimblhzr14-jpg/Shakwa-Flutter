class CommentModel {
  final String id;
  final String complaintId;
  final String userId;
  final String userName;
  final String userRoleText;
  final String message;
  final DateTime createdAt;
  final bool isInternal;

  const CommentModel({
    required this.id,
    required this.complaintId,
    required this.userId,
    required this.userName,
    required this.userRoleText,
    required this.message,
    required this.createdAt,
    this.isInternal = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaintId': complaintId,
      'userId': userId,
      'userName': userName,
      'userRoleText': userRoleText,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isInternal': isInternal,
    };
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      complaintId: json['complaintId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userRoleText: json['userRoleText'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isInternal: json['isInternal'] as bool? ?? false,
    );
  }
}
