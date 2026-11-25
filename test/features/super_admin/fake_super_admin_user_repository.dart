import 'package:dartz/dartz.dart';
import 'package:shakwa_app/core/errors/failures.dart';
import 'package:shakwa_app/features/super_admin/domain/entities/user_entity.dart';
import 'package:shakwa_app/features/super_admin/domain/repositories/i_super_admin_user_repository.dart';

class FakeSuperAdminUserRepository implements ISuperAdminUserRepository {
  List<UserEntity>? allUsersResult;
  Failure? allUsersFailure;

  List<UserEntity>? eligibleEmployeesResult;
  Failure? eligibleEmployeesFailure;

  UserEntity? userByIdResult;
  Failure? userByIdFailure;

  Failure? activateUserFailure;
  int activateUserCallCount = 0;
  int? lastActivatedUserId;

  Failure? deactivateUserFailure;
  int deactivateUserCallCount = 0;
  int? lastDeactivatedUserId;

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers() async {
    if (allUsersFailure != null) return Left(allUsersFailure!);
    return Right(allUsersResult ?? []);
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getEligibleEmployees() async {
    if (eligibleEmployeesFailure != null) {
      return Left(eligibleEmployeesFailure!);
    }
    return Right(eligibleEmployeesResult ?? []);
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(int id) async {
    if (userByIdFailure != null) return Left(userByIdFailure!);
    return Right(
      userByIdResult ??
          UserEntity(
            id: id,
            name: 'مستخدم تجريبي',
            email: 'user@shakwa.sa',
            roleId: 1,
            roleName: 'مواطن',
            isActive: true,
            createdAt: DateTime(2025, 1, 1),
          ),
    );
  }

  @override
  Future<Either<Failure, void>> activateUser(int id) async {
    activateUserCallCount++;
    lastActivatedUserId = id;
    if (activateUserFailure != null) return Left(activateUserFailure!);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deactivateUser(int id) async {
    deactivateUserCallCount++;
    lastDeactivatedUserId = id;
    if (deactivateUserFailure != null) return Left(deactivateUserFailure!);
    return const Right(null);
  }
}
