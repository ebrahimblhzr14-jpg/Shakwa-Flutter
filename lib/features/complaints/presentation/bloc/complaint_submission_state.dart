import 'package:equatable/equatable.dart';
import '../../../../core/network/attachment_upload_service.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/entities/complaint_category.dart';

abstract class ComplaintSubmissionState extends Equatable {
  const ComplaintSubmissionState();

  @override
  List<Object?> get props => [];
}

class ComplaintSubmissionInitialState extends ComplaintSubmissionState {
  final List<ComplaintCategory> categories;
  final bool isLoadingCategories;
  final String? categoriesError;

  const ComplaintSubmissionInitialState({
    this.categories = const [],
    this.isLoadingCategories = false,
    this.categoriesError,
  });

  ComplaintSubmissionInitialState copyWith({
    List<ComplaintCategory>? categories,
    bool? isLoadingCategories,
    String? categoriesError,
  }) {
    return ComplaintSubmissionInitialState(
      categories: categories ?? this.categories,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      categoriesError: categoriesError,
    );
  }

  @override
  List<Object?> get props => [categories, isLoadingCategories, categoriesError];
}

class ComplaintSubmittingState extends ComplaintSubmissionState {
  final String progressMessage;
  const ComplaintSubmittingState({
    this.progressMessage = 'جاري إرسال البلاغ...',
  });

  @override
  List<Object?> get props => [progressMessage];
}

class ComplaintSubmissionSuccessState extends ComplaintSubmissionState {
  final Complaint complaint;
  final List<AttachmentUploadItem> attachments;
  final bool hasPartialAttachmentFailures;
  final String message;

  const ComplaintSubmissionSuccessState({
    required this.complaint,
    this.attachments = const [],
    this.hasPartialAttachmentFailures = false,
    this.message = 'تم تقديم البلاغ بنجاح',
  });

  @override
  List<Object?> get props => [
    complaint,
    attachments,
    hasPartialAttachmentFailures,
    message,
  ];
}

class ComplaintSubmissionFailureState extends ComplaintSubmissionState {
  final String message;
  final int? createdComplaintId;
  final List<AttachmentUploadItem>? failedAttachments;
  final Map<String, List<String>> fieldErrors;

  const ComplaintSubmissionFailureState(
    this.message, {
    this.createdComplaintId,
    this.failedAttachments,
    this.fieldErrors = const {},
  });

  @override
  List<Object?> get props => [
    message,
    createdComplaintId,
    failedAttachments,
    fieldErrors,
  ];
}
