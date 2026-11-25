import 'package:equatable/equatable.dart';
import '../../../../core/network/attachment_upload_service.dart';

abstract class ComplaintSubmissionEvent extends Equatable {
  const ComplaintSubmissionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubmissionCategoriesEvent extends ComplaintSubmissionEvent {
  const LoadSubmissionCategoriesEvent();
}

class SubmitComplaintEvent extends ComplaintSubmissionEvent {
  final String title;
  final String description;
  final int categoryId;
  final int priorityId;
  final int? departmentId;
  final List<AttachmentUploadItem>? attachments;

  const SubmitComplaintEvent({
    required this.title,
    required this.description,
    required this.categoryId,
    required this.priorityId,
    this.departmentId,
    this.attachments,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    categoryId,
    priorityId,
    departmentId,
    attachments,
  ];
}

class RetryFailedAttachmentsEvent extends ComplaintSubmissionEvent {
  final int complaintId;
  final List<AttachmentUploadItem> failedAttachments;

  const RetryFailedAttachmentsEvent({
    required this.complaintId,
    required this.failedAttachments,
  });

  @override
  List<Object?> get props => [complaintId, failedAttachments];
}

class UpdateComplaintEvent extends ComplaintSubmissionEvent {
  final int id;
  final String title;
  final String description;
  final int categoryId;
  final int priorityId;
  final int? departmentId;

  const UpdateComplaintEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.priorityId,
    this.departmentId,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    categoryId,
    priorityId,
    departmentId,
  ];
}

class ResetSubmissionStateEvent extends ComplaintSubmissionEvent {
  const ResetSubmissionStateEvent();
}
