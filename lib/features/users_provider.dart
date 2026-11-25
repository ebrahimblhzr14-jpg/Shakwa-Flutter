import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return MockUserRepository();
});

class UsersFilterState {
  final UserRole? roleFilter;
  final String searchQuery;

  const UsersFilterState({this.roleFilter, this.searchQuery = ''});

  UsersFilterState copyWith({
    UserRole? roleFilter,
    bool clearRole = false,
    String? searchQuery,
  }) {
    return UsersFilterState(
      roleFilter: clearRole ? null : (roleFilter ?? this.roleFilter),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class UsersFilterNotifier extends StateNotifier<UsersFilterState> {
  UsersFilterNotifier() : super(const UsersFilterState());

  void setRoleFilter(UserRole? role) {
    if (role == null) {
      state = state.copyWith(clearRole: true);
    } else {
      state = state.copyWith(roleFilter: role);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final usersFilterProvider =
    StateNotifierProvider<UsersFilterNotifier, UsersFilterState>((ref) {
      return UsersFilterNotifier();
    });

final usersListProvider = FutureProvider<List<UserModel>>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  final filter = ref.watch(usersFilterProvider);
  return repo.getUsers(
    roleFilter: filter.roleFilter,
    search: filter.searchQuery,
  );
});

final employeesListProvider = FutureProvider<List<UserModel>>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getEmployeesAndAdmins();
});
