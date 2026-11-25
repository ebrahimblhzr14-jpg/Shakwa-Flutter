import 'package:equatable/equatable.dart';
import '../../domain/entities/complaint_comment.dart';

abstract class ComplaintCommentsState extends Equatable {
  const ComplaintCommentsState();

  @override
  List<Object?> get props => [];
}

class ComplaintCommentsInitialState extends ComplaintCommentsState {
  const ComplaintCommentsInitialState();
}

class ComplaintCommentsLoadingState extends ComplaintCommentsState {
  const ComplaintCommentsLoadingState();
}

class ComplaintCommentsLoadedState extends ComplaintCommentsState {
  final List<ComplaintComment> comments;
  final String? submissionMessage;

  const ComplaintCommentsLoadedState({
    required this.comments,
    this.submissionMessage,
  });

  @override
  List<Object?> get props => [comments, submissionMessage];
}

class ComplaintCommentSubmittingState extends ComplaintCommentsState {
  final List<ComplaintComment> comments;

  const ComplaintCommentSubmittingState({required this.comments});

  @override
  List<Object?> get props => [comments];
}

class ComplaintCommentsErrorState extends ComplaintCommentsState {
  final String message;
  final bool isSubmissionError;
  final List<ComplaintComment> currentComments;

  const ComplaintCommentsErrorState(
    this.message, {
    this.isSubmissionError = false,
    this.currentComments = const [],
  });

  @override
  List<Object?> get props => [message, isSubmissionError, currentComments];
}
