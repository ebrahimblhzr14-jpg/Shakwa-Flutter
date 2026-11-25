import 'package:equatable/equatable.dart';

abstract class SuperAdminDashboardEvent extends Equatable {
  const SuperAdminDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadSuperAdminDashboardEvent extends SuperAdminDashboardEvent {
  final bool isRefresh;
  const LoadSuperAdminDashboardEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}
