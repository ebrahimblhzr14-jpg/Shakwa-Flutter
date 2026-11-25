import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/core/errors/failures.dart';
import 'package:shakwa_app/core/security/jwt_claims_parser.dart';
import 'package:shakwa_app/features/authentication/domain/entities/auth_session.dart';
import 'package:shakwa_app/features/authentication/domain/repositories/i_auth_repository.dart';
import 'package:shakwa_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:shakwa_app/features/authentication/presentation/bloc/auth_event.dart';
import 'package:shakwa_app/features/authentication/presentation/bloc/auth_state.dart';

class MockAuthRepository implements IAuthRepository {
  Either<Failure, AuthSession>? loginResult;
  Duration? loginDelay;
  Completer<Either<Failure, AuthSession>>? loginCompleter;
  int loginCallCount = 0;

  Either<Failure, AuthSession>? registerResult;
  Duration? registerDelay;
  int registerCallCount = 0;

  Either<Failure, AuthSession>? restoreResult;
  Either<Failure, void>? logoutResult;

  final StreamController<bool> _authController =
      StreamController<bool>.broadcast();

  @override
  AuthSession? currentSession;

  @override
  Stream<bool> get authStateChanges => _authController.stream;

  @override
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    loginCallCount++;
    if (loginCompleter != null) return loginCompleter!.future;
    if (loginDelay != null) await Future.delayed(loginDelay!);
    return loginResult ?? Left(const ServerFailure('No login mock configured'));
  }

  @override
  Future<Either<Failure, AuthSession>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    registerCallCount++;
    if (registerDelay != null) await Future.delayed(registerDelay!);
    return registerResult ??
        Left(const ServerFailure('No register mock configured'));
  }

  @override
  Future<Either<Failure, AuthSession>> restoreSession() async {
    return restoreResult ?? Left(const SessionExpiredFailure('No session'));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return logoutResult ?? const Right(null);
  }
}

AuthSession createMockSession({
  int userId = 1,
  String name = 'محمد علي',
  String email = 'user@shakwa.sa',
  UserRole role = UserRole.user,
  bool isVolatile = false,
}) {
  return AuthSession(
    userId: userId,
    fullName: name,
    email: email,
    role: role,
    accessToken: 'mock_access_token',
    refreshToken: 'mock_refresh_token',
    expiresAt: DateTime.now().add(const Duration(minutes: 15)),
    isVolatileSession: isVolatile,
  );
}

void main() {
  group('AuthBloc', () {
    late MockAuthRepository mockRepo;
    late AuthBloc authBloc;

    setUp(() {
      mockRepo = MockAuthRepository();
      authBloc = AuthBloc(authRepository: mockRepo);
    });

    tearDown(() {
      authBloc.close();
    });

    test('1. Initial state is AuthInitial', () {
      expect(authBloc.state, equals(const AuthInitial()));
    });

    test(
      '2. Login loading -> success emits AuthLoading and AuthAuthenticated',
      () async {
        final session = createMockSession();
        mockRepo.loginResult = Right(session);

        final expectedStates = [
          const AuthLoading(operation: AuthOperation.login),
          AuthAuthenticated(session),
        ];

        expectLater(authBloc.stream, emitsInOrder(expectedStates));

        authBloc.add(
          const AuthLoginSubmitted(
            email: 'user@shakwa.sa',
            password: 'password123',
          ),
        );
      },
    );

    test(
      '3. Login loading -> failure emits AuthLoading and AuthFailure',
      () async {
        mockRepo.loginResult = const Left(
          UnauthorizedFailure('اسم المستخدم أو كلمة المرور غير صحيحة.'),
        );

        final expectedStates = [
          const AuthLoading(operation: AuthOperation.login),
          const AuthError(
            message: 'اسم المستخدم أو كلمة المرور غير صحيحة.',
            operation: AuthOperation.login,
          ),
        ];

        expectLater(authBloc.stream, emitsInOrder(expectedStates));

        authBloc.add(
          const AuthLoginSubmitted(email: 'user@shakwa.sa', password: 'wrong'),
        );
      },
    );

    test(
      '4. Duplicate submission protection: ignores second submit while first is loading',
      () async {
        final session = createMockSession();
        mockRepo.loginResult = Right(session);
        mockRepo.loginDelay = const Duration(milliseconds: 50);

        authBloc.add(
          const AuthLoginSubmitted(
            email: 'user@shakwa.sa',
            password: 'password123',
          ),
        );
        // Immediate duplicate submission while loading
        authBloc.add(
          const AuthLoginSubmitted(
            email: 'user@shakwa.sa',
            password: 'password123',
          ),
        );

        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          mockRepo.loginCallCount,
          equals(1),
          reason: 'Must ignore duplicate event while loading',
        );
      },
    );

    test('5. Logout emits AuthLoading and AuthUnauthenticated', () async {
      mockRepo.logoutResult = const Right(null);

      final expectedStates = [
        const AuthLoading(operation: AuthOperation.logout),
        const AuthUnauthenticated(),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(const AuthLogoutRequested());
    });

    test(
      '6. Session restoration with valid session emits AuthLoading and AuthAuthenticated',
      () async {
        final session = createMockSession(userId: 55, name: 'سارة');
        mockRepo.restoreResult = Right(session);

        final expectedStates = [
          const AuthLoading(operation: AuthOperation.sessionCheck),
          AuthAuthenticated(session),
        ];

        expectLater(authBloc.stream, emitsInOrder(expectedStates));

        authBloc.add(const AuthCheckSessionRequested());
      },
    );

    test(
      '7. Session restoration with expired/missing session emits AuthUnauthenticated',
      () async {
        mockRepo.restoreResult = const Left(
          SessionExpiredFailure('لا توجد جلسة نشطة.'),
        );

        final expectedStates = [
          const AuthLoading(operation: AuthOperation.sessionCheck),
          const AuthUnauthenticated(message: 'لا توجد جلسة نشطة.'),
        ];

        expectLater(authBloc.stream, emitsInOrder(expectedStates));

        authBloc.add(const AuthCheckSessionRequested());
      },
    );

    test(
      '8. Session restoration with corrupt storage emits AuthUnauthenticated',
      () async {
        mockRepo.restoreResult = const Left(
          SessionExpiredFailure(
            'بيانات الجلسة المخزنة تالفة وتمت إعادة ضبطها.',
          ),
        );

        final expectedStates = [
          const AuthLoading(operation: AuthOperation.sessionCheck),
          const AuthUnauthenticated(
            message: 'بيانات الجلسة المخزنة تالفة وتمت إعادة ضبطها.',
          ),
        ];

        expectLater(authBloc.stream, emitsInOrder(expectedStates));

        authBloc.add(const AuthCheckSessionRequested());
      },
    );

    test(
      '9. Refresh failure during session restoration emits AuthUnauthenticated',
      () async {
        mockRepo.restoreResult = const Left(
          SessionExpiredFailure(
            'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مجدداً.',
          ),
        );

        final expectedStates = [
          const AuthLoading(operation: AuthOperation.sessionCheck),
          const AuthUnauthenticated(
            message: 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مجدداً.',
          ),
        ];

        expectLater(authBloc.stream, emitsInOrder(expectedStates));

        authBloc.add(const AuthCheckSessionRequested());
      },
    );

    test(
      '10. Session storage write failure (volatile session) maintains authenticated state',
      () async {
        final volatileSession = createMockSession(isVolatile: true);
        mockRepo.loginResult = Right(volatileSession);

        final expectedStates = [
          const AuthLoading(operation: AuthOperation.login),
          AuthAuthenticated(volatileSession),
        ];

        expectLater(authBloc.stream, emitsInOrder(expectedStates));

        authBloc.add(
          const AuthLoginSubmitted(
            email: 'user@shakwa.sa',
            password: 'password123',
          ),
        );
      },
    );
  });
}
