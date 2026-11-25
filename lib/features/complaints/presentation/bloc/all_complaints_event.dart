import 'package:equatable/equatable.dart';

abstract class AllComplaintsEvent extends Equatable {
  const AllComplaintsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllComplaintsEvent extends AllComplaintsEvent {
  final bool isRefresh;
  const LoadAllComplaintsEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class SearchAllComplaintsEvent extends AllComplaintsEvent {
  final String query;
  const SearchAllComplaintsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterAllComplaintsEvent extends AllComplaintsEvent {
  final bool onlyUnassigned;
  final int? statusId;

  const FilterAllComplaintsEvent({this.onlyUnassigned = false, this.statusId});

  @override
  List<Object?> get props => [onlyUnassigned, statusId];
}
