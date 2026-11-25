import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_super_admin_user_repository.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final ISuperAdminUserRepository _userRepository;

  UsersBloc({required ISuperAdminUserRepository userRepository})
    : _userRepository = userRepository,
      super(const UsersInitialState()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<SearchUsersEvent>(_onSearchUsers);
    on<FilterUsersByRoleEvent>(_onFilterByRole);
    on<ToggleUserStatusEvent>(_onToggleUserStatus);
  }

  Future<void> _onLoadUsers(
    LoadUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const UsersLoadingState());
    }

    final result = await _userRepository.getAllUsers();

    result.fold((failure) => emit(UsersErrorState(failure.message)), (users) {
      emit(UsersLoadedState(allUsers: users, filteredUsers: users));
    });
  }

  void _onSearchUsers(SearchUsersEvent event, Emitter<UsersState> emit) {
    final currentState = state;
    if (currentState is UsersLoadedState) {
      final filtered = _applyFilter(
        currentState.allUsers,
        event.query,
        currentState.selectedRoleId,
      );
      emit(
        currentState.copyWith(
          searchQuery: event.query,
          filteredUsers: filtered,
        ),
      );
    }
  }

  void _onFilterByRole(FilterUsersByRoleEvent event, Emitter<UsersState> emit) {
    final currentState = state;
    if (currentState is UsersLoadedState) {
      final filtered = _applyFilter(
        currentState.allUsers,
        currentState.searchQuery,
        event.roleId,
      );
      emit(
        currentState.copyWith(
          selectedRoleId: event.roleId,
          clearRole: event.roleId == null,
          filteredUsers: filtered,
        ),
      );
    }
  }

  Future<void> _onToggleUserStatus(
    ToggleUserStatusEvent event,
    Emitter<UsersState> emit,
  ) async {
    final currentState = state;
    final result = event.activate
        ? await _userRepository.activateUser(event.userId)
        : await _userRepository.deactivateUser(event.userId);

    result.fold(
      (failure) {
        if (currentState is UsersLoadedState) {
          emit(currentState.copyWith(actionFeedbackMessage: failure.message));
        } else {
          emit(UsersErrorState(failure.message));
        }
      },
      (_) {
        final actionMsg = event.activate
            ? 'تم تفعيل حساب المستخدم بنجاح.'
            : 'تم تعطيل حساب المستخدم بنجاح.';
        if (currentState is UsersLoadedState) {
          final updatedAll = currentState.allUsers.map((u) {
            if (u.id == event.userId) {
              return UserEntity(
                id: u.id,
                name: u.name,
                email: u.email,
                phone: u.phone,
                imageUrl: u.imageUrl,
                roleId: u.roleId,
                roleName: u.roleName,
                isActive: event.activate,
                createdAt: u.createdAt,
              );
            }
            return u;
          }).toList();

          final updatedFiltered = _applyFilter(
            updatedAll,
            currentState.searchQuery,
            currentState.selectedRoleId,
          );

          emit(
            currentState.copyWith(
              allUsers: updatedAll,
              filteredUsers: updatedFiltered,
              actionFeedbackMessage: actionMsg,
            ),
          );
        }
      },
    );
  }

  List<UserEntity> _applyFilter(
    List<UserEntity> users,
    String query,
    int? roleId,
  ) {
    var result = users;

    if (roleId != null) {
      result = result.where((u) => u.roleId == roleId).toList();
    }

    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((u) {
        return u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            (u.phone != null && u.phone!.contains(q));
      }).toList();
    }

    return result;
  }
}
