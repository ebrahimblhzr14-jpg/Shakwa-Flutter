import '../../domain/entities/complaint_details.dart';
import 'complaint_attachment_model.dart';
import 'complaint_dto.dart';
import 'complaint_history_model.dart';

/// Aggregated data model for complaint details.
class ComplaintDetailsModel {
  final ComplaintDto complaint;
  final List<ComplaintHistoryModel> history;
  final List<ComplaintAttachmentModel> attachments;
  final String? primaryAttachmentUrl;

  const ComplaintDetailsModel({
    required this.complaint,
    this.history = const [],
    this.attachments = const [],
    this.primaryAttachmentUrl,
  });

  ComplaintDetails toEntity() {
    return ComplaintDetails(
      complaint: complaint.toEntity(),
      history: history.map((h) => h.toEntity()).toList(),
      attachments: attachments.map((a) => a.toEntity()).toList(),
      primaryAttachmentUrl: primaryAttachmentUrl,
    );
  }
}
