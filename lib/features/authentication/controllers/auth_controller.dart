import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({this.user, this.isLoading = false, this.errorMessage});

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _loadInitialUser();
  }

  Future<void> _loadInitialUser() async {
    final user = await _repository.getCurrentUser();
    state = state.copyWith(user: user);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.login(
        emailOrUsername: email,
        password: password,
      );
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تسجيل الدخول. تحقق من البيانات.',
      );
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
      );
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'تعذر إنشاء الحساب. حاول مجدداً.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }

  Future<void> switchRole(UserRole role) async {
    state = state.copyWith(isLoading: true);
    final user = await _repository.switchMockRole(role);
    state = state.copyWith(user: user, isLoading: false);
  }

  Future<bool> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    String? department,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated = await _repository.updateProfile(
        fullName: fullName,
        email: email,
        phone: phone,
        department: department,
      );
      state = state.copyWith(user: updated, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحديث الملف الشخصي.',
      );
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
