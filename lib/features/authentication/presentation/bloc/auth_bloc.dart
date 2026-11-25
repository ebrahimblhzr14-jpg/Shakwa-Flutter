import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _authRepository;

  AuthBloc({required IAuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    on<AuthCheckSessionRequested>(_onCheckSessionRequested);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckSessionRequested(
    AuthCheckSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(operation: AuthOperation.sessionCheck));

    final result = await _authRepository.restoreSession();

    result.fold(
      (failure) => emit(AuthUnauthenticated(message: failure.message)),
      (session) => emit(AuthAuthenticated(session)),
    );
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    // Duplicate submission protection: if already loading, ignore
    if (state is AuthLoading) return;

    emit(const AuthLoading(operation: AuthOperation.login));

    final result = await _authRepository.login(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(
        AuthError(message: failure.message, operation: AuthOperation.login),
      ),
      (session) => emit(AuthAuthenticated(session)),
    );
  }

  Future<void> _onRegisterSubmitted(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    // Duplicate submission protection: if already loading, ignore
    if (state is AuthLoading) return;

    emit(const AuthLoading(operation: AuthOperation.registration));

    final result = await _authRepository.register(
      name: event.name,
      email: event.email,
      password: event.password,
      phone: event.phone,
    );

    result.fold(
      (failure) => emit(
        AuthError(
          message: failure.message,
          operation: AuthOperation.registration,
        ),
      ),
      (session) => emit(AuthAuthenticated(session)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(operation: AuthOperation.logout));

    await _authRepository.logout();

    emit(const AuthUnauthenticated());
  }
}
