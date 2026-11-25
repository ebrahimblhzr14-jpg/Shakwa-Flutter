import 'package:equatable/equatable.dart';

abstract class ComplaintCommentsEvent extends Equatable {
  const ComplaintCommentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadComplaintCommentsEvent extends ComplaintCommentsEvent {
  final int complaintId;

  const LoadComplaintCommentsEvent(this.complaintId);

  @override
  List<Object?> get props => [complaintId];
}

class AddComplaintCommentEvent extends ComplaintCommentsEvent {
  final int complaintId;
  final String comment;

  const AddComplaintCommentEvent({
    required this.complaintId,
    required this.comment,
  });

  @override
  List<Object?> get props => [complaintId, comment];
}
