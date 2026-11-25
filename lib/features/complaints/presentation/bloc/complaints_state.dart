import 'package:equatable/equatable.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/entities/complaint_status.dart';

abstract class ComplaintsState extends Equatable {
  const ComplaintsState();

  @override
  List<Object?> get props => [];
}

class ComplaintsInitialState extends ComplaintsState {
  const ComplaintsInitialState();
}

class ComplaintsLoadingState extends ComplaintsState {
  const ComplaintsLoadingState();
}

class ComplaintsLoadedState extends ComplaintsState {
  final List<Complaint> complaints;
  final List<Complaint> filteredComplaints;
  final ComplaintStatus? selectedStatus;
  final String searchQuery;

  const ComplaintsLoadedState({
    required this.complaints,
    required this.filteredComplaints,
    this.selectedStatus,
    this.searchQuery = '',
  });

  // Accurately derived metrics for Citizen Dashboard
  int get totalCount => complaints.length;
  int get pendingCount => complaints
      .where(
        (c) =>
            c.status == ComplaintStatus.pending ||
            c.status == ComplaintStatus.underReview,
      )
      .length;
  int get inProgressCount =>
      complaints.where((c) => c.status == ComplaintStatus.inProgress).length;
  int get resolvedCount =>
      complaints.where((c) => c.status == ComplaintStatus.resolved).length;
  int get closedCount =>
      complaints.where((c) => c.status == ComplaintStatus.closed).length;

  ComplaintsLoadedState copyWith({
    List<Complaint>? complaints,
    List<Complaint>? filteredComplaints,
    ComplaintStatus? selectedStatus,
    bool clearStatus = false,
    String? searchQuery,
  }) {
    return ComplaintsLoadedState(
      complaints: complaints ?? this.complaints,
      filteredComplaints: filteredComplaints ?? this.filteredComplaints,
      selectedStatus: clearStatus
          ? null
          : (selectedStatus ?? this.selectedStatus),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    complaints,
    filteredComplaints,
    selectedStatus,
    searchQuery,
  ];
}

class ComplaintsEmptyState extends ComplaintsState {
  final String message;
  const ComplaintsEmptyState({this.message = 'لا توجد شكاوى مسجلة حالياً.'});

  @override
  List<Object?> get props => [message];
}

class ComplaintsErrorState extends ComplaintsState {
  final String message;
  final bool isNetworkError;

  const ComplaintsErrorState(this.message, {this.isNetworkError = false});

  @override
  List<Object?> get props => [message, isNetworkError];
}
