import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/core/errors/exceptions.dart';
import 'package:shakwa_app/core/errors/failures.dart';
import 'package:shakwa_app/core/security/secure_token_storage.dart';
import 'package:shakwa_app/core/security/token_manager.dart';
import 'package:shakwa_app/core/security/token_record.dart';
import 'package:shakwa_app/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:shakwa_app/features/authentication/data/repositories/auth_repository_impl.dart';

class MockRemoteDataSource implements IAuthRemoteDataSource {
  Map<String, dynamic>? loginResult;
  Exception? loginException;

  Map<String, dynamic>? registerResult;
  Exception? registerException;

  Map<String, dynamic>? refreshResult;
  Exception? refreshException;

  bool logoutCalled = false;
  Exception? logoutException;

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (loginException != null) throw loginException!;
    return loginResult ?? {};
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    if (registerException != null) throw registerException!;
    return registerResult ?? {};
  }

  @override
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    if (refreshException != null) throw refreshException!;
    return refreshResult ?? {};
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    if (logoutException != null) throw logoutException!;
  }
}

class FakeSecureStorage implements ISecureTokenStorage {
  TokenRecord? record;
  bool throwCorrupted = false;

  @override
  bool get isVolatileSession => false;

  @override
  Future<void> saveTokenRecord(TokenRecord r) async => record = r;

  @override
  Future<TokenRecord?> getTokenRecord() async {
    if (throwCorrupted)
      throw const CorruptedTokenRecordException('Corrupted record');
    return record;
  }

  @override
  Future<void> clearTokenRecord() async => record = null;
}

String createTestJwt({
  int userId = 10,
  String name = 'أحمد محمد',
  String email = 'user@shakwa.sa',
  String role = 'Citizen',
  int expSecondsFromNow = 900,
}) {
  final header = base64Url.encode(
    utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})),
  );
  final exp =
      DateTime.now()
          .add(Duration(seconds: expSecondsFromNow))
          .millisecondsSinceEpoch ~/
      1000;
  final payload = base64Url.encode(
    utf8.encode(
      jsonEncode({
        'nameid': userId.toString(),
        'unique_name': name,
        'email': email,
        'role': role,
        'exp': exp,
      }),
    ),
  );
  return '$header.$payload.fakeSignature';
}

void main() {
  group('AuthRepositoryImpl', () {
    late MockRemoteDataSource mockRemote;
    late FakeSecureStorage fakeStorage;
    late TokenManager tokenManager;
    late AuthRepositoryImpl repository;

    setUp(() {
      mockRemote = MockRemoteDataSource();
      fakeStorage = FakeSecureStorage();
      tokenManager = TokenManager(fakeStorage);
      repository = AuthRepositoryImpl(
        remoteDataSource: mockRemote,
        tokenManager: tokenManager,
      );
    });

    test(
      '1. Successful login parses tokens, claims, and returns AuthSession',
      () async {
        final validJwt = createTestJwt(
          userId: 42,
          name: 'سارة خالد',
          email: 'sara@shakwa.sa',
          role: 'Citizen',
        );
        mockRemote.loginResult = {
          'accessToken': validJwt,
          'refreshToken': 'valid_refresh_token_123',
        };

        final result = await repository.login(
          email: 'sara@shakwa.sa',
          password: 'Password123!',
        );

        expect(result.isRight(), isTrue);
        result.fold((f) => fail('Expected Right'), (session) {
          expect(session.userId, equals(42));
          expect(session.fullName, equals('سارة خالد'));
          expect(session.email, equals('sara@shakwa.sa'));
          expect(session.accessToken, equals(validJwt));
          expect(session.refreshToken, equals('valid_refresh_token_123'));
        });
      },
    );

    test('2. Invalid credentials returns Left(UnauthorizedFailure)', () async {
      mockRemote.loginException = const UnauthorizedException(
        'اسم المستخدم أو كلمة المرور غير صحيحة.',
      );

      final result = await repository.login(
        email: 'user@shakwa.sa',
        password: 'wrongPassword',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test(
      '3. Backend validation errors returns Left(ValidationFailure) with field details',
      () async {
        mockRemote.loginException = const ValidationException(
          message: 'بيانات غير صالحة',
          fieldErrors: {
            'Email': ['صيغة البريد الإلكتروني غير صالحة.'],
          },
        );

        final result = await repository.login(
          email: 'bad-email',
          password: '123',
        );

        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          final vf = failure as ValidationFailure;
          expect(vf.fieldErrors['Email']?.first, contains('غير صالحة'));
        }, (_) => fail('Expected Left'));
      },
    );

    test('4. Server failure returns Left(ServerFailure)', () async {
      mockRemote.loginException = const ServerException(
        'خطأ في الخادم الداخلي.',
      );

      final result = await repository.login(
        email: 'user@shakwa.sa',
        password: 'pwd',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test(
      '5. Malformed response with missing tokens returns Left(ServerFailure)',
      () async {
        mockRemote.loginResult = {'message': 'Success but no tokens'};

        final result = await repository.login(
          email: 'user@shakwa.sa',
          password: 'pwd',
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      },
    );

    test('6. Successful registration returns Right(AuthSession)', () async {
      final validJwt = createTestJwt(
        userId: 88,
        name: 'فهد الأحمد',
        email: 'fahad@shakwa.sa',
        role: 'Citizen',
      );
      mockRemote.registerResult = {
        'accessToken': validJwt,
        'refreshToken': 'reg_refresh_token_999',
      };

      final result = await repository.register(
        name: 'فهد الأحمد',
        email: 'fahad@shakwa.sa',
        password: 'StrongPassword123!',
        phone: '0501234567',
      );

      expect(result.isRight(), isTrue);
      result.fold((f) => fail('Expected Right'), (session) {
        expect(session.userId, equals(88));
        expect(session.fullName, equals('فهد الأحمد'));
        expect(session.email, equals('fahad@shakwa.sa'));
      });
    });

    test(
      '7. Registration conflict (email taken) returns Left(ConflictFailure)',
      () async {
        mockRemote.registerException = const ConflictException(
          'البريد الإلكتروني مسجل مسبقاً.',
        );

        final result = await repository.register(
          name: 'مواطن',
          email: 'existing@shakwa.sa',
          password: 'Password123!',
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ConflictFailure>()),
          (_) => fail('Expected Left'),
        );
      },
    );

    test(
      '8. Registration does not falsely authenticate when tokens are absent',
      () async {
        mockRemote.registerResult = {
          'userId': 99,
          'message': 'User registered but tokens omitted',
        };

        final result = await repository.register(
          name: 'مواطن جديد',
          email: 'new@shakwa.sa',
          password: 'Password123!',
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left because tokens are absent'),
        );
      },
    );

    test(
      '9. Session restoration with valid non-expired token returns Right(AuthSession)',
      () async {
        final validJwt = createTestJwt(
          userId: 15,
          name: 'عبدالله',
          email: 'abd@shakwa.sa',
          expSecondsFromNow: 800,
        );
        fakeStorage.record = TokenRecord.create(
          accessToken: validJwt,
          refreshToken: 'refresh_active',
          accessLifetime: const Duration(minutes: 15),
        );

        final result = await repository.restoreSession();

        expect(result.isRight(), isTrue);
        result.fold((f) => fail('Expected Right'), (session) {
          expect(session.userId, equals(15));
          expect(session.fullName, equals('عبدالله'));
        });
      },
    );

    test(
      '10. Session restoration with expired token attempts refresh and restores session',
      () async {
        final expiredJwt = createTestJwt(userId: 15, expSecondsFromNow: -100);
        fakeStorage.record = TokenRecord(
          accessToken: expiredJwt,
          refreshToken: 'refresh_to_rotate',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          expiresAt: DateTime.now().subtract(const Duration(minutes: 10)),
        );

        final newJwt = createTestJwt(
          userId: 15,
          name: 'عبدالله',
          expSecondsFromNow: 900,
        );
        mockRemote.refreshResult = {
          'accessToken': newJwt,
          'refreshToken': 'new_rotated_refresh',
        };

        final result = await repository.restoreSession();

        expect(result.isRight(), isTrue);
        result.fold((f) => fail('Expected Right'), (session) {
          expect(session.accessToken, equals(newJwt));
          expect(session.refreshToken, equals('new_rotated_refresh'));
        });
      },
    );

    test(
      '11. Session restoration with revoked refresh token purges session and returns Left(SessionExpiredFailure)',
      () async {
        final expiredJwt = createTestJwt(expSecondsFromNow: -100);
        fakeStorage.record = TokenRecord(
          accessToken: expiredJwt,
          refreshToken: 'revoked_refresh',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        mockRemote.refreshException = const UnauthorizedException(
          'Refresh token revoked',
        );

        final result = await repository.restoreSession();

        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure, isA<SessionExpiredFailure>());
          expect(tokenManager.isAuthenticated, isFalse);
          expect(fakeStorage.record, isNull);
        }, (_) => fail('Expected Left'));
      },
    );

    test(
      '12. Session restoration with network failure retains credentials and returns Left(NetworkFailure)',
      () async {
        final expiredJwt = createTestJwt(expSecondsFromNow: -100);
        final originalRecord = TokenRecord(
          accessToken: expiredJwt,
          refreshToken: 'offline_refresh',
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
          expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
        );
        fakeStorage.record = originalRecord;

        mockRemote.refreshException = const NetworkException(
          'تعذر الاتصال بالخادم.',
        );

        final result = await repository.restoreSession();

        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure, isA<NetworkFailure>());
          // Must NOT wipe session on temporary network outage
          expect(fakeStorage.record, isNotNull);
        }, (_) => fail('Expected Left'));
      },
    );

    test(
      '13. Corrupted secure storage record purges storage and returns Left(SessionExpiredFailure)',
      () async {
        fakeStorage.throwCorrupted = true;

        final result = await repository.restoreSession();

        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure, isA<SessionExpiredFailure>());
          expect(tokenManager.isAuthenticated, isFalse);
        }, (_) => fail('Expected Left'));
      },
    );

    test(
      '14. Logout revokes token on server and invalidates local cache',
      () async {
        final jwt = createTestJwt();
        fakeStorage.record = TokenRecord.create(
          accessToken: jwt,
          refreshToken: 'logout_refresh',
        );
        await tokenManager.initialize();

        final result = await repository.logout();

        expect(result.isRight(), isTrue);
        expect(mockRemote.logoutCalled, isTrue);
        expect(tokenManager.isAuthenticated, isFalse);
      },
    );
  });
}
