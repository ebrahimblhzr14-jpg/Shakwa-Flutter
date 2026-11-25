import 'package:equatable/equatable.dart';

abstract class AssignComplaintEvent extends Equatable {
  const AssignComplaintEvent();

  @override
  List<Object?> get props => [];
}

class LoadAssignmentDataEvent extends AssignComplaintEvent {
  final int complaintId;
  const LoadAssignmentDataEvent(this.complaintId);

  @override
  List<Object?> get props => [complaintId];
}

class SubmitAssignmentEvent extends AssignComplaintEvent {
  final int complaintId;
  final int assignedToUserId;
  final String? notes;

  const SubmitAssignmentEvent({
    required this.complaintId,
    required this.assignedToUserId,
    this.notes,
  });

  @override
  List<Object?> get props => [complaintId, assignedToUserId, notes];
}
