import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class ISuperAdminUserRepository {
  Future<Either<Failure, List<UserEntity>>> getAllUsers();
  Future<Either<Failure, List<UserEntity>>> getEligibleEmployees();
  Future<Either<Failure, UserEntity>> getUserById(int id);
  Future<Either<Failure, void>> activateUser(int id);
  Future<Either<Failure, void>> deactivateUser(int id);
}
