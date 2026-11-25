import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsersEvent extends UsersEvent {
  final bool isRefresh;
  const LoadUsersEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class SearchUsersEvent extends UsersEvent {
  final String query;
  const SearchUsersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterUsersByRoleEvent extends UsersEvent {
  final int? roleId;
  const FilterUsersByRoleEvent(this.roleId);

  @override
  List<Object?> get props => [roleId];
}

class ToggleUserStatusEvent extends UsersEvent {
  final int userId;
  final bool activate;

  const ToggleUserStatusEvent({required this.userId, required this.activate});

  @override
  List<Object?> get props => [userId, activate];
}
