import 'package:equatable/equatable.dart';
import '../../domain/entities/complaint_status.dart';

abstract class AssignedComplaintsEvent extends Equatable {
  const AssignedComplaintsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAssignedComplaintsEvent extends AssignedComplaintsEvent {
  final bool isRefresh;

  const LoadAssignedComplaintsEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class FilterAssignedComplaintsByStatusEvent extends AssignedComplaintsEvent {
  final ComplaintStatus? status;

  const FilterAssignedComplaintsByStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class SearchAssignedComplaintsEvent extends AssignedComplaintsEvent {
  final String query;

  const SearchAssignedComplaintsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ChangeAssignedComplaintStatusEvent extends AssignedComplaintsEvent {
  final int complaintId;
  final ComplaintStatus status;

  const ChangeAssignedComplaintStatusEvent({
    required this.complaintId,
    required this.status,
  });

  @override
  List<Object?> get props => [complaintId, status];
}
