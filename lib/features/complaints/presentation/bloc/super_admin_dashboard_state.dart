import 'package:equatable/equatable.dart';
import '../../domain/entities/complaint.dart';

abstract class SuperAdminDashboardState extends Equatable {
  const SuperAdminDashboardState();

  @override
  List<Object?> get props => [];
}

class SuperAdminDashboardInitialState extends SuperAdminDashboardState {
  const SuperAdminDashboardInitialState();
}

class SuperAdminDashboardLoadingState extends SuperAdminDashboardState {
  const SuperAdminDashboardLoadingState();
}

class SuperAdminDashboardLoadedState extends SuperAdminDashboardState {
  final int totalComplaints;
  final int pendingComplaints;
  final int inProgressComplaints;
  final int resolvedComplaints;
  final int closedComplaints;
  final List<Complaint> recentComplaints;
  final int totalUsersCount;

  const SuperAdminDashboardLoadedState({
    required this.totalComplaints,
    required this.pendingComplaints,
    required this.inProgressComplaints,
    required this.resolvedComplaints,
    required this.closedComplaints,
    required this.recentComplaints,
    this.totalUsersCount = 0,
  });

  int get unassignedCount => pendingComplaints;

  int get resolutionRate => totalComplaints > 0
      ? ((resolvedComplaints / totalComplaints) * 100).toInt()
      : 0;

  SuperAdminDashboardLoadedState copyWith({
    int? totalComplaints,
    int? pendingComplaints,
    int? inProgressComplaints,
    int? resolvedComplaints,
    int? closedComplaints,
    List<Complaint>? recentComplaints,
    int? totalUsersCount,
  }) {
    return SuperAdminDashboardLoadedState(
      totalComplaints: totalComplaints ?? this.totalComplaints,
      pendingComplaints: pendingComplaints ?? this.pendingComplaints,
      inProgressComplaints: inProgressComplaints ?? this.inProgressComplaints,
      resolvedComplaints: resolvedComplaints ?? this.resolvedComplaints,
      closedComplaints: closedComplaints ?? this.closedComplaints,
      recentComplaints: recentComplaints ?? this.recentComplaints,
      totalUsersCount: totalUsersCount ?? this.totalUsersCount,
    );
  }

  @override
  List<Object?> get props => [
    totalComplaints,
    pendingComplaints,
    inProgressComplaints,
    resolvedComplaints,
    closedComplaints,
    recentComplaints,
    totalUsersCount,
  ];
}

class SuperAdminDashboardErrorState extends SuperAdminDashboardState {
  final String message;
  const SuperAdminDashboardErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
