import 'package:equatable/equatable.dart';
import 'complaint.dart';
import 'complaint_attachment.dart';
import 'complaint_history_item.dart';

/// Aggregated domain model representing detailed view of a complaint.
class ComplaintDetails extends Equatable {
  final Complaint complaint;
  final List<ComplaintHistoryItem> history;
  final List<ComplaintAttachment> attachments;
  final String? primaryAttachmentUrl;

  const ComplaintDetails({
    required this.complaint,
    this.history = const [],
    this.attachments = const [],
    this.primaryAttachmentUrl,
  });

  @override
  List<Object?> get props => [
    complaint,
    history,
    attachments,
    primaryAttachmentUrl,
  ];
}
