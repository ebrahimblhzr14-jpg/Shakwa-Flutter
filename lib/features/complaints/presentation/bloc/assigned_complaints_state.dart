import 'package:equatable/equatable.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/entities/complaint_status.dart';

abstract class AssignedComplaintsState extends Equatable {
  const AssignedComplaintsState();

  @override
  List<Object?> get props => [];
}

class AssignedComplaintsInitialState extends AssignedComplaintsState {
  const AssignedComplaintsInitialState();
}

class AssignedComplaintsLoadingState extends AssignedComplaintsState {
  const AssignedComplaintsLoadingState();
}

class AssignedComplaintsLoadedState extends AssignedComplaintsState {
  final List<Complaint> complaints;
  final List<Complaint> filteredComplaints;
  final ComplaintStatus? selectedStatus;
  final String? searchQuery;
  final String? statusUpdateSuccessMessage;
  final bool isUpdatingStatus;

  const AssignedComplaintsLoadedState({
    required this.complaints,
    required this.filteredComplaints,
    this.selectedStatus,
    this.searchQuery,
    this.statusUpdateSuccessMessage,
    this.isUpdatingStatus = false,
  });

  // Derived workload metrics for Field Supervisor / Processing Employee
  int get totalAssigned => complaints.length;
  int get inProgressCount =>
      complaints.where((c) => c.status == ComplaintStatus.inProgress).length;
  int get pendingCount => complaints
      .where(
        (c) =>
            c.status == ComplaintStatus.pending ||
            c.status == ComplaintStatus.underReview,
      )
      .length;
  int get resolvedCount =>
      complaints.where((c) => c.status == ComplaintStatus.resolved).length;
  int get closedCount =>
      complaints.where((c) => c.status == ComplaintStatus.closed).length;

  AssignedComplaintsLoadedState copyWith({
    List<Complaint>? complaints,
    List<Complaint>? filteredComplaints,
    ComplaintStatus? selectedStatus,
    bool clearStatusFilter = false,
    String? searchQuery,
    String? statusUpdateSuccessMessage,
    bool? isUpdatingStatus,
  }) {
    return AssignedComplaintsLoadedState(
      complaints: complaints ?? this.complaints,
      filteredComplaints: filteredComplaints ?? this.filteredComplaints,
      selectedStatus: clearStatusFilter
          ? null
          : (selectedStatus ?? this.selectedStatus),
      searchQuery: searchQuery ?? this.searchQuery,
      statusUpdateSuccessMessage: statusUpdateSuccessMessage,
      isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
    );
  }

  @override
  List<Object?> get props => [
    complaints,
    filteredComplaints,
    selectedStatus,
    searchQuery,
    statusUpdateSuccessMessage,
    isUpdatingStatus,
  ];
}

class AssignedComplaintsEmptyState extends AssignedComplaintsState {
  const AssignedComplaintsEmptyState();
}

class AssignedComplaintsErrorState extends AssignedComplaintsState {
  final String message;
  final bool isForbidden;
  final bool isNetworkError;

  const AssignedComplaintsErrorState(
    this.message, {
    this.isForbidden = false,
    this.isNetworkError = false,
  });

  @override
  List<Object?> get props => [message, isForbidden, isNetworkError];
}
