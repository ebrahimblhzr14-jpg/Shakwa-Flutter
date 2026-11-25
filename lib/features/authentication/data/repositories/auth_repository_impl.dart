import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/security/jwt_claims_parser.dart';
import '../../../../core/security/token_manager.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;
  final TokenManager _tokenManager;

  AuthRepositoryImpl({
    required IAuthRemoteDataSource remoteDataSource,
    required TokenManager tokenManager,
  }) : _remoteDataSource = remoteDataSource,
       _tokenManager = tokenManager;

  @override
  AuthSession? get currentSession => _buildSessionFromCache();

  @override
  Stream<bool> get authStateChanges => _tokenManager.statusStream.map(
    (status) => status == AuthStatus.authenticated,
  );

  AuthSession? _buildSessionFromCache() {
    final record = _tokenManager.tokenRecord;
    if (record == null || record.accessToken.isEmpty) {
      return null;
    }

    final claims =
        _tokenManager.claims ?? JwtClaimsParser.tryParse(record.accessToken);
    return AuthSession(
      userId: claims?.userId ?? 0,
      fullName: claims?.fullName ?? '',
      email: claims?.email ?? '',
      role: claims?.role ?? UserRole.user,
      accessToken: record.accessToken,
      refreshToken: record.refreshToken,
      expiresAt: record.expiresAt,
      isVolatileSession: _tokenManager.isSessionVolatile,
    );
  }

  @override
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      final access = res['accessToken'] as String?;
      final refresh = res['refreshToken'] as String?;

      if (access == null || refresh == null) {
        return const Left(
          ServerFailure('استجابة غير مكتملة من الخادم: الرموز غير متوفرة.'),
        );
      }

      await _tokenManager.updateTokens(
        accessToken: access,
        refreshToken: refresh,
      );

      final session = _buildSessionFromCache();
      if (session != null) {
        return Right(session);
      }

      final claims = JwtClaimsParser.tryParse(access);
      return Right(
        AuthSession(
          userId: claims?.userId ?? 0,
          fullName: claims?.fullName ?? '',
          email: claims?.email ?? email,
          role: claims?.role ?? UserRole.user,
          accessToken: access,
          refreshToken: refresh,
          expiresAt:
              claims?.expiresAt ??
              DateTime.now().add(const Duration(minutes: 15)),
          isVolatileSession: _tokenManager.isSessionVolatile,
        ),
      );
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, fieldErrors: e.fieldErrors));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع أثناء تسجيل الدخول: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthSession>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final res = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      final access = res['accessToken'] as String?;
      final refresh = res['refreshToken'] as String?;

      // Validate tokens were returned by backend SingIn
      if (access == null || refresh == null) {
        return const Left(
          ServerFailure(
            'تم إنشاء الحساب ولكن لم يتم استلام رموز المصادقة. يرجى تسجيل الدخول.',
          ),
        );
      }

      await _tokenManager.updateTokens(
        accessToken: access,
        refreshToken: refresh,
      );

      final session = _buildSessionFromCache();
      if (session != null) {
        return Right(session);
      }

      final claims = JwtClaimsParser.tryParse(access);
      return Right(
        AuthSession(
          userId: claims?.userId ?? 0,
          fullName: claims?.fullName ?? name,
          email: claims?.email ?? email,
          role: claims?.role ?? UserRole.user,
          accessToken: access,
          refreshToken: refresh,
          expiresAt:
              claims?.expiresAt ??
              DateTime.now().add(const Duration(minutes: 15)),
          isVolatileSession: _tokenManager.isSessionVolatile,
        ),
      );
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, fieldErrors: e.fieldErrors));
    } on ConflictException catch (e) {
      return Left(ConflictFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع أثناء إنشاء الحساب: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthSession>> restoreSession() async {
    try {
      await _tokenManager.initialize();
      final record = _tokenManager.tokenRecord;

      if (record == null || record.accessToken.isEmpty) {
        return const Left(SessionExpiredFailure('لا توجد جلسة محفوظة.'));
      }

      // Check token expiration
      if (!record.isExpired) {
        final session = _buildSessionFromCache();
        if (session != null) {
          return Right(session);
        }
      }

      // Access token is expired, attempt refresh using saved refresh token
      try {
        final refreshRes = await _remoteDataSource.refreshToken(
          refreshToken: record.refreshToken,
        );

        final newAccess = refreshRes['accessToken'] as String?;
        final newRefresh = refreshRes['refreshToken'] as String?;

        if (newAccess != null && newRefresh != null) {
          await _tokenManager.updateTokens(
            accessToken: newAccess,
            refreshToken: newRefresh,
          );
          final updatedSession = _buildSessionFromCache();
          if (updatedSession != null) {
            return Right(updatedSession);
          }
        }
        return const Left(SessionExpiredFailure('فشل تجديد الجلسة المنتهية.'));
      } on UnauthorizedException {
        // Confirmed revoked or invalid refresh token on server
        await _tokenManager.invalidateSession();
        return const Left(
          SessionExpiredFailure(
            'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مجدداً.',
          ),
        );
      } on SessionExpiredException {
        await _tokenManager.invalidateSession();
        return const Left(
          SessionExpiredFailure(
            'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مجدداً.',
          ),
        );
      } on NetworkException catch (e) {
        // Temporary connection issue: do NOT invalidate local credentials!
        return Left(NetworkFailure(e.message));
      }
    } on CorruptedTokenRecordException {
      await _tokenManager.invalidateSession();
      return const Left(
        SessionExpiredFailure('بيانات الجلسة المخزنة تالفة وتمت إعادة ضبطها.'),
      );
    } catch (e) {
      return Left(ServerFailure('فشل استعادة الجلسة: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return const Right(null);
    } finally {
      await _tokenManager.invalidateSession();
    }
  }
}
