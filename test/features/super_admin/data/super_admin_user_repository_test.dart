import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/core/errors/exceptions.dart';
import 'package:shakwa_app/core/errors/failures.dart';
import 'package:shakwa_app/features/super_admin/data/datasources/user_remote_data_source.dart';
import 'package:shakwa_app/features/super_admin/data/models/user_dto.dart';
import 'package:shakwa_app/features/super_admin/data/repositories/super_admin_user_repository_impl.dart';

class FakeUserRemoteDataSource implements IUserRemoteDataSource {
  List<UserDto>? usersResult;
  UserDto? userByIdResult;
  Exception? exceptionToThrow;

  int activateCallCount = 0;
  int deactivateCallCount = 0;

  @override
  Future<List<UserDto>> getAllUsers() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return usersResult ?? [];
  }

  @override
  Future<UserDto> getUserById(int id) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return userByIdResult ??
        UserDto(
          id: id,
          name: 'المستخدم $id',
          email: 'user$id@shakwa.sa',
          roleId: 1,
          roleName: 'User',
          isActive: true,
          createdAt: DateTime(2025, 1, 1),
        );
  }

  @override
  Future<void> activateUser(int id) async {
    activateCallCount++;
    if (exceptionToThrow != null) throw exceptionToThrow!;
  }

  @override
  Future<void> deactivateUser(int id) async {
    deactivateCallCount++;
    if (exceptionToThrow != null) throw exceptionToThrow!;
  }
}

void main() {
  late FakeUserRemoteDataSource fakeDataSource;
  late SuperAdminUserRepositoryImpl repository;

  final sampleUsers = [
    UserDto(
      id: 1,
      name: 'مواطن تجريبي',
      email: 'citizen@shakwa.sa',
      roleId: 1,
      roleName: 'User',
      isActive: true,
      createdAt: DateTime(2025, 1, 1),
    ),
    UserDto(
      id: 2,
      name: 'مشرف الصيانة',
      email: 'admin@shakwa.sa',
      roleId: 2,
      roleName: 'Admin',
      isActive: true,
      createdAt: DateTime(2025, 1, 1),
    ),
    UserDto(
      id: 3,
      name: 'المسؤول العام',
      email: 'super@shakwa.sa',
      roleId: 3,
      roleName: 'SuperAdmin',
      isActive: true,
      createdAt: DateTime(2025, 1, 1),
    ),
  ];

  setUp(() {
    fakeDataSource = FakeUserRemoteDataSource();
    repository = SuperAdminUserRepositoryImpl(remoteDataSource: fakeDataSource);
  });

  group('SuperAdminUserRepositoryImpl - getAllUsers', () {
    test(
      'returns Right(List<UserEntity>) on successful remote fetch',
      () async {
        fakeDataSource.usersResult = sampleUsers;

        final result = await repository.getAllUsers();

        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected Right but got Left($failure)'),
          (users) {
            expect(users.length, 3);
            expect(users[0].name, 'مواطن تجريبي');
            expect(users[1].name, 'مشرف الصيانة');
          },
        );
      },
    );

    test(
      'returns Left(UnauthorizedFailure) when UnauthorizedException is thrown',
      () async {
        fakeDataSource.exceptionToThrow = const UnauthorizedException(
          'غير مصرح',
        );

        final result = await repository.getAllUsers();

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<UnauthorizedFailure>()),
          (_) => fail('Expected Left'),
        );
      },
    );

    test(
      'returns Left(ForbiddenFailure) when ForbiddenException is thrown',
      () async {
        fakeDataSource.exceptionToThrow = const ForbiddenException('ممنوع');

        final result = await repository.getAllUsers();

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ForbiddenFailure>()),
          (_) => fail('Expected Left'),
        );
      },
    );

    test(
      'returns Left(NetworkFailure) when NetworkException is thrown',
      () async {
        fakeDataSource.exceptionToThrow = const NetworkException(
          'لا يوجد اتصال',
        );

        final result = await repository.getAllUsers();

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected Left'),
        );
      },
    );
  });

  group('SuperAdminUserRepositoryImpl - getEligibleEmployees', () {
    test('filters and returns only users with employee/admin role', () async {
      fakeDataSource.usersResult = sampleUsers;

      final result = await repository.getEligibleEmployees();

      expect(result.isRight(), isTrue);
      result.fold((failure) => fail('Expected Right'), (employees) {
        expect(employees.length, 1);
        expect(employees.first.id, 2);
        expect(employees.first.roleName, 'Admin');
      });
    });
  });

  group('SuperAdminUserRepositoryImpl - getUserById', () {
    test('returns Right(UserEntity) when user is found', () async {
      fakeDataSource.userByIdResult = sampleUsers[1];

      final result = await repository.getUserById(2);

      expect(result.isRight(), isTrue);
      result.fold((failure) => fail('Expected Right'), (user) {
        expect(user.id, 2);
        expect(user.name, 'مشرف الصيانة');
      });
    });

    test('returns Left(NotFoundFailure) when user is not found', () async {
      fakeDataSource.exceptionToThrow = const NotFoundException(
        'المستخدم غير موجود',
      );

      final result = await repository.getUserById(999);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('SuperAdminUserRepositoryImpl - activate & deactivate', () {
    test('activateUser completes successfully', () async {
      final result = await repository.activateUser(2);

      expect(result.isRight(), isTrue);
      expect(fakeDataSource.activateCallCount, 1);
    });

    test('deactivateUser completes successfully', () async {
      final result = await repository.deactivateUser(2);

      expect(result.isRight(), isTrue);
      expect(fakeDataSource.deactivateCallCount, 1);
    });
  });
}
