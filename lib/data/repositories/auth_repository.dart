import '../models/user_model.dart';
import '../mock_data/mock_database.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> login({
    required String emailOrUsername,
    required String password,
  });
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  });
  Future<void> logout();
  Future<UserModel> switchMockRole(UserRole role);
  Future<UserModel> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    String? department,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class MockAuthRepository implements AuthRepository {
  final MockDatabase _db = MockDatabase.instance;

  @override
  Future<UserModel?> getCurrentUser() async {
    return _db.currentUser;
  }

  @override
  Future<UserModel> login({
    required String emailOrUsername,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Try finding by email
    final user = _db.users.firstWhere(
      (u) => u.email.toLowerCase() == emailOrUsername.trim().toLowerCase(),
      orElse: () {
        // Fallback or demo user login
        return _db.users.first;
      },
    );

    _db.currentUser = user;
    return user;
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final newUser = UserModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: email.trim(),
      phone: phone?.trim() ?? '0500000000',
      role: UserRole.user,
      department: 'مستفيد جديد',
      isActive: true,
      createdAt: DateTime.now(),
    );

    _db.users.add(newUser);
    _db.currentUser = newUser;
    return newUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _db.currentUser = null;
  }

  @override
  Future<UserModel> switchMockRole(UserRole role) async {
    final user = _db.users.firstWhere(
      (u) => u.role == role,
      orElse: () => _db.users.first,
    );
    _db.currentUser = user;
    return user;
  }

  @override
  Future<UserModel> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    String? department,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final current = _db.currentUser;
    if (current == null) throw Exception('No user logged in');

    final updated = current.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
      department: department ?? current.department,
    );

    final idx = _db.users.indexWhere((u) => u.id == current.id);
    if (idx != -1) {
      _db.users[idx] = updated;
    }
    _db.currentUser = updated;
    return updated;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulated successful password change
  }
}
