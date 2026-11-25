import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/core/errors/exceptions.dart';
import 'package:shakwa_app/core/network/api_client.dart';
import 'package:shakwa_app/core/security/secure_token_storage.dart';
import 'package:shakwa_app/core/security/token_manager.dart';
import '../security/secure_token_storage_test.dart';

void main() {
  group('ApiClient Error Mapping', () {
    late ApiClient apiClient;

    setUp(() {
      final tokenStorage = SecureTokenStorageImpl(
        storage: MockFlutterSecureStorage(),
      );
      final tokenManager = TokenManager(tokenStorage);
      apiClient = ApiClient(tokenManager: tokenManager);
    });

    test('8. Maps HTTP 400 with field errors to ValidationException', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: {
            'message': 'بيانات غير صحيحة',
            'errors': {
              'Email': ['البريد غير صالح'],
              'Password': ['كلمة المرور قصيرة'],
            },
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = apiClient.mapDioException(dioError);
      expect(exception, isA<ValidationException>());
      final valEx = exception as ValidationException;
      expect(valEx.statusCode, equals(400));
      expect(valEx.message, contains('بيانات غير صحيحة'));
      expect(valEx.fieldErrors['Email'], contains('البريد غير صالح'));
    });

    test('9. Maps HTTP 403 to ForbiddenException', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/admin'),
        response: Response(
          requestOptions: RequestOptions(path: '/admin'),
          statusCode: 403,
          data: {'message': 'ليس لديك صلاحية'},
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = apiClient.mapDioException(dioError);
      expect(exception, isA<ForbiddenException>());
      expect(exception.statusCode, equals(403));
    });

    test('10. Maps HTTP 404 to NotFoundException', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/item/999'),
        response: Response(
          requestOptions: RequestOptions(path: '/item/999'),
          statusCode: 404,
          data: {'message': 'غير موجود'},
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = apiClient.mapDioException(dioError);
      expect(exception, isA<NotFoundException>());
      expect(exception.statusCode, equals(404));
    });

    test('11. Maps HTTP 409 to ConflictException', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/Complaints/1/status'),
        response: Response(
          requestOptions: RequestOptions(path: '/Complaints/1/status'),
          statusCode: 409,
          data: {'message': 'الشكوى مغلقة مسبقاً'},
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = apiClient.mapDioException(dioError);
      expect(exception, isA<ConflictException>());
      expect(exception.statusCode, equals(409));
    });

    test('12. Maps HTTP 500 to ServerException', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/crash'),
        response: Response(
          requestOptions: RequestOptions(path: '/crash'),
          statusCode: 500,
          data: 'Internal error',
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = apiClient.mapDioException(dioError);
      expect(exception, isA<ServerException>());
      expect(exception.statusCode, equals(500));
    });

    test('13. Maps connection and receive timeouts to NetworkException', () {
      final connectTimeout = DioException(
        requestOptions: RequestOptions(path: '/slow'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(
        apiClient.mapDioException(connectTimeout),
        isA<NetworkException>(),
      );

      final receiveTimeout = DioException(
        requestOptions: RequestOptions(path: '/slow'),
        type: DioExceptionType.receiveTimeout,
      );
      expect(
        apiClient.mapDioException(receiveTimeout),
        isA<NetworkException>(),
      );
    });

    test(
      '14. Maps connection error and offline failure to NetworkException',
      () {
        final connError = DioException(
          requestOptions: RequestOptions(path: '/offline'),
          type: DioExceptionType.connectionError,
        );
        expect(apiClient.mapDioException(connError), isA<NetworkException>());
      },
    );
  });
}
