import 'package:equatable/equatable.dart';
import '../../domain/entities/complaint_status.dart';

abstract class ComplaintsEvent extends Equatable {
  const ComplaintsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyComplaintsEvent extends ComplaintsEvent {
  final bool isRefresh;
  const LoadMyComplaintsEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class FilterComplaintsByStatusEvent extends ComplaintsEvent {
  final ComplaintStatus? status;
  const FilterComplaintsByStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class SearchComplaintsEvent extends ComplaintsEvent {
  final String query;
  const SearchComplaintsEvent(this.query);

  @override
  List<Object?> get props => [query];
}
