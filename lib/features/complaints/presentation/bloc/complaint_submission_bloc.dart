import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/attachment_upload_service.dart';
import '../../domain/entities/complaint_category.dart';
import '../../domain/repositories/i_complaint_repository.dart';
import 'complaint_submission_event.dart';
import 'complaint_submission_state.dart';

class ComplaintSubmissionBloc
    extends Bloc<ComplaintSubmissionEvent, ComplaintSubmissionState> {
  final IComplaintRepository _repository;
  List<ComplaintCategory> _cachedCategories = [];

  ComplaintSubmissionBloc({required IComplaintRepository repository})
    : _repository = repository,
      super(const ComplaintSubmissionInitialState()) {
    on<LoadSubmissionCategoriesEvent>(_onLoadCategories);
    on<SubmitComplaintEvent>(_onSubmitComplaint);
    on<RetryFailedAttachmentsEvent>(_onRetryFailedAttachments);
    on<UpdateComplaintEvent>(_onUpdateComplaint);
    on<ResetSubmissionStateEvent>(_onReset);
  }

  Future<void> _onLoadCategories(
    LoadSubmissionCategoriesEvent event,
    Emitter<ComplaintSubmissionState> emit,
  ) async {
    final current = state is ComplaintSubmissionInitialState
        ? state as ComplaintSubmissionInitialState
        : const ComplaintSubmissionInitialState();

    emit(current.copyWith(isLoadingCategories: true, categoriesError: null));

    final result = await _repository.getCategories();

    result.fold(
      (failure) {
        emit(
          current.copyWith(
            isLoadingCategories: false,
            categoriesError: failure.message,
          ),
        );
      },
      (categories) {
        _cachedCategories = categories;
        emit(
          current.copyWith(
            isLoadingCategories: false,
            categories: categories,
            categoriesError: null,
          ),
        );
      },
    );
  }

  Future<void> _onSubmitComplaint(
    SubmitComplaintEvent event,
    Emitter<ComplaintSubmissionState> emit,
  ) async {
    emit(
      const ComplaintSubmittingState(
        progressMessage: 'جاري تسجيل البلاغ في النظام...',
      ),
    );

    final result = await _repository.createComplaint(
      title: event.title,
      description: event.description,
      categoryId: event.categoryId,
      priorityId: event.priorityId,
      departmentId: event.departmentId,
      attachments: event.attachments,
    );

    result.fold(
      (failure) {
        final fieldErrors = failure is ValidationFailure
            ? failure.fieldErrors
            : <String, List<String>>{};
        emit(
          ComplaintSubmissionFailureState(
            failure.message,
            fieldErrors: fieldErrors,
          ),
        );
      },
      (createdComplaint) {
        final attachments = event.attachments ?? [];
        final failedAttachments = attachments.where((a) => a.isFailed).toList();
        final hasFailures = failedAttachments.isNotEmpty;

        emit(
          ComplaintSubmissionSuccessState(
            complaint: createdComplaint,
            attachments: attachments,
            hasPartialAttachmentFailures: hasFailures,
            message: hasFailures
                ? 'تم إنشاء البلاغ بنجاح (#${createdComplaint.id})، ولكن تعذر رفع بعض المرفقات.'
                : 'تم تقديم البلاغ بنجاح برقم (#${createdComplaint.id}).',
          ),
        );
      },
    );
  }

  Future<void> _onRetryFailedAttachments(
    RetryFailedAttachmentsEvent event,
    Emitter<ComplaintSubmissionState> emit,
  ) async {
    emit(
      const ComplaintSubmittingState(
        progressMessage: 'جاري إعادة محاولة رفع المرفقات...',
      ),
    );

    final remainingFailed = <AttachmentUploadItem>[];

    for (final item in event.failedAttachments) {
      final uploadRes = await _repository.uploadAttachment(
        complaintId: event.complaintId,
        item: item,
      );

      uploadRes.fold(
        (failure) {
          remainingFailed.add(item);
        },
        (uploadedItem) {
          // Upload succeeded for this item
        },
      );
    }

    if (remainingFailed.isEmpty) {
      // Re-fetch complaint to yield updated success state
      final getRes = await _repository.getComplaintById(event.complaintId);
      getRes.fold(
        (failure) => emit(ComplaintSubmissionFailureState(failure.message)),
        (complaint) => emit(
          ComplaintSubmissionSuccessState(
            complaint: complaint,
            hasPartialAttachmentFailures: false,
            message: 'تم اكتمال رفع جميع المرفقات بنجاح.',
          ),
        ),
      );
    } else {
      emit(
        ComplaintSubmissionFailureState(
          'تعذر رفع بعض المرفقات. يرجى المحاولة لاحقاً.',
          createdComplaintId: event.complaintId,
          failedAttachments: remainingFailed,
        ),
      );
    }
  }

  Future<void> _onUpdateComplaint(
    UpdateComplaintEvent event,
    Emitter<ComplaintSubmissionState> emit,
  ) async {
    emit(
      const ComplaintSubmittingState(progressMessage: 'جاري حفظ التعديلات...'),
    );

    final result = await _repository.updateComplaint(
      id: event.id,
      title: event.title,
      description: event.description,
      categoryId: event.categoryId,
      priorityId: event.priorityId,
      departmentId: event.departmentId,
    );

    result.fold(
      (failure) {
        emit(ComplaintSubmissionFailureState(failure.message));
      },
      (updatedComplaint) {
        emit(
          ComplaintSubmissionSuccessState(
            complaint: updatedComplaint,
            message: 'تم تحديث بيانات البلاغ بنجاح.',
          ),
        );
      },
    );
  }

  void _onReset(
    ResetSubmissionStateEvent event,
    Emitter<ComplaintSubmissionState> emit,
  ) {
    emit(ComplaintSubmissionInitialState(categories: _cachedCategories));
  }
}
