import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_session.dart';

abstract class IAuthRepository {
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthSession>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  Future<Either<Failure, AuthSession>> restoreSession();

  Future<Either<Failure, void>> logout();

  AuthSession? get currentSession;

  Stream<bool> get authStateChanges;
}
