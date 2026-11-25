import '../models/user_model.dart';
import '../mock_data/mock_database.dart';

abstract class UserRepository {
  Future<List<UserModel>> getUsers({UserRole? roleFilter, String? search});
  Future<List<UserModel>> getEmployeesAndAdmins();
  Future<UserModel?> getUserById(String id);
  Future<UserModel> updateUser(UserModel user);
  Future<UserModel> addUser(UserModel user);
  Future<void> toggleUserStatus(String id);
}

class MockUserRepository implements UserRepository {
  final MockDatabase _db = MockDatabase.instance;

  @override
  Future<List<UserModel>> getUsers({
    UserRole? roleFilter,
    String? search,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    var result = List<UserModel>.from(_db.users);

    if (roleFilter != null) {
      result = result.where((u) => u.role == roleFilter).toList();
    }

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      result = result
          .where(
            (u) =>
                u.fullName.toLowerCase().contains(q) ||
                u.email.toLowerCase().contains(q) ||
                (u.department != null &&
                    u.department!.toLowerCase().contains(q)),
          )
          .toList();
    }

    return result;
  }

  @override
  Future<List<UserModel>> getEmployeesAndAdmins() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _db.users
        .where((u) => u.role == UserRole.admin || u.role == UserRole.superAdmin)
        .toList();
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return _db.users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final index = _db.users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _db.users[index] = user;
      return user;
    }
    throw Exception('User not found');
  }

  @override
  Future<UserModel> addUser(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newUser = user.copyWith(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    _db.users.add(newUser);
    return newUser;
  }

  @override
  Future<void> toggleUserStatus(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _db.users.indexWhere((u) => u.id == id);
    if (index != -1) {
      final current = _db.users[index];
      _db.users[index] = current.copyWith(isActive: !current.isActive);
    }
  }
}
