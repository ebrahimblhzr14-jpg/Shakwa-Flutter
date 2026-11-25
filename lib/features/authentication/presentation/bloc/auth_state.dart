import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_session.dart';

enum AuthOperation { none, sessionCheck, login, registration, logout }

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  final AuthOperation operation;

  const AuthLoading({this.operation = AuthOperation.none});

  @override
  List<Object?> get props => [operation];
}

class AuthAuthenticated extends AuthState {
  final AuthSession session;

  const AuthAuthenticated(this.session);

  @override
  List<Object?> get props => [session];
}

class AuthUnauthenticated extends AuthState {
  final String? message;

  const AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;
  final Map<String, List<String>>? fieldErrors;
  final AuthOperation operation;

  const AuthError({
    required this.message,
    this.fieldErrors,
    this.operation = AuthOperation.none,
  });

  @override
  List<Object?> get props => [message, fieldErrors, operation];
}
