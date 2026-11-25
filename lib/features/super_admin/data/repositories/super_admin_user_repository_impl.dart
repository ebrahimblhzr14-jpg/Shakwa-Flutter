import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_super_admin_user_repository.dart';
import '../datasources/user_remote_data_source.dart';

class SuperAdminUserRepositoryImpl implements ISuperAdminUserRepository {
  final IUserRemoteDataSource _remoteDataSource;

  SuperAdminUserRepositoryImpl({
    required IUserRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers() async {
    try {
      final dtos = await _remoteDataSource.getAllUsers();
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getEligibleEmployees() async {
    try {
      final dtos = await _remoteDataSource.getAllUsers();
      final employees = dtos
          .where((u) => u.roleId == 2 || (u.roleName?.toLowerCase() == 'admin'))
          .map((dto) => dto.toEntity())
          .toList();
      return Right(employees);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(int id) async {
    try {
      if (id <= 0) {
        return const Left(ValidationFailure('معرف المستخدم غير صالح.'));
      }
      final dto = await _remoteDataSource.getUserById(id);
      return Right(dto.toEntity());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> activateUser(int id) async {
    try {
      if (id <= 0) {
        return const Left(ValidationFailure('معرف المستخدم غير صالح.'));
      }
      await _remoteDataSource.activateUser(id);
      return const Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateUser(int id) async {
    try {
      if (id <= 0) {
        return const Left(ValidationFailure('معرف المستخدم غير صالح.'));
      }
      await _remoteDataSource.deactivateUser(id);
      return const Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(Object exception) {
    if (exception is UnauthorizedException) {
      return const UnauthorizedFailure(
        'انتهت صلاحية الجلسة، يرجى إعادة تسجيل الدخول.',
      );
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message);
    } else if (exception is ForbiddenException) {
      return const ForbiddenFailure(
        'غير مصرح لك بتنفيذ هذه العملية كمسؤول عام.',
      );
    } else if (exception is NotFoundException) {
      return const NotFoundFailure('المستخدم غير موجود.');
    } else if (exception is ConflictException) {
      return ConflictFailure(exception.message);
    } else if (exception is NetworkException) {
      return const NetworkFailure(
        'فشل الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت.',
      );
    } else if (exception is ServerException) {
      return ServerFailure(exception.message);
    }
    return ServerFailure(exception.toString());
  }
}
