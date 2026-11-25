import 'status_model.dart';

class HistoryModel {
  final String id;
  final String complaintId;
  final String complaintNumber;
  final String actionTitle;
  final String actionDescription;
  final String performedByUserId;
  final String performedByName;
  final String performedByRole;
  final DateTime timestamp;
  final ComplaintStatus? previousStatus;
  final ComplaintStatus? newStatus;

  const HistoryModel({
    required this.id,
    required this.complaintId,
    required this.complaintNumber,
    required this.actionTitle,
    required this.actionDescription,
    required this.performedByUserId,
    required this.performedByName,
    required this.performedByRole,
    required this.timestamp,
    this.previousStatus,
    this.newStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaintId': complaintId,
      'complaintNumber': complaintNumber,
      'actionTitle': actionTitle,
      'actionDescription': actionDescription,
      'performedByUserId': performedByUserId,
      'performedByName': performedByName,
      'performedByRole': performedByRole,
      'timestamp': timestamp.toIso8601String(),
      'previousStatus': previousStatus?.name,
      'newStatus': newStatus?.name,
    };
  }

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'] as String,
      complaintId: json['complaintId'] as String,
      complaintNumber: json['complaintNumber'] as String,
      actionTitle: json['actionTitle'] as String,
      actionDescription: json['actionDescription'] as String,
      performedByUserId: json['performedByUserId'] as String,
      performedByName: json['performedByName'] as String,
      performedByRole: json['performedByRole'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      previousStatus: json['previousStatus'] != null
          ? ComplaintStatus.values.firstWhere(
              (s) => s.name == json['previousStatus'],
            )
          : null,
      newStatus: json['newStatus'] != null
          ? ComplaintStatus.values.firstWhere(
              (s) => s.name == json['newStatus'],
            )
          : null,
    );
  }
}
