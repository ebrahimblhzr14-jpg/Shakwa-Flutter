import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/complaint_comment.dart';
import '../../domain/repositories/i_complaint_repository.dart';
import 'complaint_comments_event.dart';
import 'complaint_comments_state.dart';

class ComplaintCommentsBloc
    extends Bloc<ComplaintCommentsEvent, ComplaintCommentsState> {
  final IComplaintRepository _repository;
  bool _isSubmitting = false;

  ComplaintCommentsBloc({required IComplaintRepository repository})
    : _repository = repository,
      super(const ComplaintCommentsInitialState()) {
    on<LoadComplaintCommentsEvent>(_onLoadComments);
    on<AddComplaintCommentEvent>(_onAddComment);
  }

  Future<void> _onLoadComments(
    LoadComplaintCommentsEvent event,
    Emitter<ComplaintCommentsState> emit,
  ) async {
    emit(const ComplaintCommentsLoadingState());

    final result = await _repository.getComplaintComments(event.complaintId);

    result.fold(
      (failure) => emit(ComplaintCommentsErrorState(failure.message)),
      (comments) => emit(ComplaintCommentsLoadedState(comments: comments)),
    );
  }

  Future<void> _onAddComment(
    AddComplaintCommentEvent event,
    Emitter<ComplaintCommentsState> emit,
  ) async {
    if (_isSubmitting) return; // Prevent duplicate submissions

    final trimmed = event.comment.trim();
    if (trimmed.isEmpty) {
      emit(
        const ComplaintCommentsErrorState(
          'نص الملاحظة مطلوب ولا يمكن أن يكون فارغاً.',
          isSubmissionError: true,
        ),
      );
      return;
    }

    _isSubmitting = true;

    final currentComments = state is ComplaintCommentsLoadedState
        ? (state as ComplaintCommentsLoadedState).comments
        : <ComplaintComment>[];

    emit(ComplaintCommentSubmittingState(comments: currentComments));

    final result = await _repository.addComplaintComment(
      complaintId: event.complaintId,
      comment: trimmed,
    );

    _isSubmitting = false;

    result.fold(
      (failure) {
        emit(
          ComplaintCommentsErrorState(
            failure.message,
            isSubmissionError: true,
            currentComments: currentComments,
          ),
        );
      },
      (newComment) {
        final updatedList = List<ComplaintComment>.from(currentComments)
          ..add(newComment);
        emit(
          ComplaintCommentsLoadedState(
            comments: updatedList,
            submissionMessage: 'تم إضافة الملاحظة بنجاح.',
          ),
        );
      },
    );
  }
}
