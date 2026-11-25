import 'package:equatable/equatable.dart';
import '../../domain/entities/complaint.dart';

abstract class AllComplaintsState extends Equatable {
  const AllComplaintsState();

  @override
  List<Object?> get props => [];
}

class AllComplaintsInitialState extends AllComplaintsState {
  const AllComplaintsInitialState();
}

class AllComplaintsLoadingState extends AllComplaintsState {
  const AllComplaintsLoadingState();
}

class AllComplaintsLoadedState extends AllComplaintsState {
  final List<Complaint> allComplaints;
  final List<Complaint> filteredComplaints;
  final String searchQuery;
  final bool onlyUnassigned;
  final int? selectedStatusId;

  const AllComplaintsLoadedState({
    required this.allComplaints,
    required this.filteredComplaints,
    this.searchQuery = '',
    this.onlyUnassigned = false,
    this.selectedStatusId,
  });

  AllComplaintsLoadedState copyWith({
    List<Complaint>? allComplaints,
    List<Complaint>? filteredComplaints,
    String? searchQuery,
    bool? onlyUnassigned,
    int? selectedStatusId,
    bool clearStatus = false,
  }) {
    return AllComplaintsLoadedState(
      allComplaints: allComplaints ?? this.allComplaints,
      filteredComplaints: filteredComplaints ?? this.filteredComplaints,
      searchQuery: searchQuery ?? this.searchQuery,
      onlyUnassigned: onlyUnassigned ?? this.onlyUnassigned,
      selectedStatusId: clearStatus
          ? null
          : (selectedStatusId ?? this.selectedStatusId),
    );
  }

  @override
  List<Object?> get props => [
    allComplaints,
    filteredComplaints,
    searchQuery,
    onlyUnassigned,
    selectedStatusId,
  ];
}

class AllComplaintsErrorState extends AllComplaintsState {
  final String message;
  const AllComplaintsErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
