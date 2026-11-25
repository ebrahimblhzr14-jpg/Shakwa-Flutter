import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object?> get props => [];
}

class UsersInitialState extends UsersState {
  const UsersInitialState();
}

class UsersLoadingState extends UsersState {
  const UsersLoadingState();
}

class UsersLoadedState extends UsersState {
  final List<UserEntity> allUsers;
  final List<UserEntity> filteredUsers;
  final String searchQuery;
  final int? selectedRoleId;
  final String? actionFeedbackMessage;

  const UsersLoadedState({
    required this.allUsers,
    required this.filteredUsers,
    this.searchQuery = '',
    this.selectedRoleId,
    this.actionFeedbackMessage,
  });

  UsersLoadedState copyWith({
    List<UserEntity>? allUsers,
    List<UserEntity>? filteredUsers,
    String? searchQuery,
    int? selectedRoleId,
    bool clearRole = false,
    String? actionFeedbackMessage,
  }) {
    return UsersLoadedState(
      allUsers: allUsers ?? this.allUsers,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRoleId: clearRole
          ? null
          : (selectedRoleId ?? this.selectedRoleId),
      actionFeedbackMessage: actionFeedbackMessage,
    );
  }

  @override
  List<Object?> get props => [
    allUsers,
    filteredUsers,
    searchQuery,
    selectedRoleId,
    actionFeedbackMessage,
  ];
}

class UsersErrorState extends UsersState {
  final String message;
  const UsersErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
