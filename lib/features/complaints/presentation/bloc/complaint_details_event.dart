import 'package:equatable/equatable.dart';

abstract class ComplaintDetailsEvent extends Equatable {
  const ComplaintDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadComplaintDetailsEvent extends ComplaintDetailsEvent {
  final int complaintId;
  const LoadComplaintDetailsEvent(this.complaintId);

  @override
  List<Object?> get props => [complaintId];
}

class RefreshComplaintDetailsEvent extends ComplaintDetailsEvent {
  final int complaintId;
  const RefreshComplaintDetailsEvent(this.complaintId);

  @override
  List<Object?> get props => [complaintId];
}
