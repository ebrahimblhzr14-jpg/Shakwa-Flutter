import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../errors/exceptions.dart';
import '../security/token_manager.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/sanitized_logging_interceptor.dart';

/// Centralized Dio API Client providing base options, error translation,
/// Bearer token injection, single-flight refresh, and sanitized logging.
class ApiClient {
  final Dio _dio;
  final TokenManager _tokenManager;

  ApiClient({Dio? dio, required TokenManager tokenManager})
    : _tokenManager = tokenManager,
      _dio = dio ?? _createDefaultDio(tokenManager);

  Dio get dio => _dio;
  TokenManager get tokenManager => _tokenManager;

  static Dio _createDefaultDio(TokenManager tokenManager) {
    final baseOptions = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.sendTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    final dioInstance = Dio(baseOptions);

    // Dedicated non-intercepted Dio instance for refresh and replay to prevent recursive interception
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
      ),
    );

    _configureSslAdapter(dioInstance);
    _configureSslAdapter(refreshDio);

    dioInstance.interceptors.addAll([
      AuthInterceptor(tokenManager: tokenManager, refreshDio: refreshDio),
      SanitizedLoggingInterceptor(),
    ]);

    return dioInstance;
  }

  static void _configureSslAdapter(Dio dio) {
    if (kIsWeb) return;

    // In release mode, enforce strict system CA certificate validation by default.
    // Self-signed dev certificates are permitted only in debug/profile modes,
    // or when explicitly enabled via compile-time flag: --dart-define=ALLOW_INSECURE_DEV_CERTS=true.
    const allowInsecureDevCerts = bool.fromEnvironment(
      'ALLOW_INSECURE_DEV_CERTS',
      defaultValue: false,
    );
    if (kReleaseMode && !allowInsecureDevCerts) {
      return;
    }

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          return host == 'localhost' ||
              host == '127.0.0.1' ||
              host == '10.0.2.2' ||
              host.startsWith('192.168.');
        };
        return client;
      },
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  /// Maps DioExceptions into strongly-typed domain AppExceptions with Arabic messages.
  AppException mapDioException(DioException error) {
    if (error.error is AppException) {
      return error.error as AppException;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'انتهت مهلة انتظار الخادم. يرجى التحقق من جودة الاتصال.',
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          'تعذر الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت.',
        );

      case DioExceptionType.cancel:
        return const NetworkException('تم إلغاء الطلب.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        String? serverMessage;
        Map<String, List<String>> fieldErrors = {};

        if (responseData is Map) {
          serverMessage = responseData['message']?.toString();
          if (responseData['errors'] is Map) {
            final rawErrors = responseData['errors'] as Map;
            fieldErrors = rawErrors.map((k, v) {
              if (v is List) {
                return MapEntry(
                  k.toString(),
                  v.map((e) => e.toString()).toList(),
                );
              }
              return MapEntry(k.toString(), [v.toString()]);
            });
          }
        } else if (responseData is String && responseData.isNotEmpty) {
          serverMessage = responseData;
        }

        switch (statusCode) {
          case 400:
            return ValidationException(
              message: serverMessage ?? 'البيانات المدخلة غير صحيحة.',
              fieldErrors: fieldErrors,
            );
          case 401:
            return UnauthorizedException(
              serverMessage ??
                  'اسم المستخدم أو كلمة المرور غير صحيحة / انتهت الجلسة.',
            );
          case 403:
            return ForbiddenException(
              serverMessage ??
                  'ليس لديك صلاحية للوصول إلى هذا الإجراء أو المورد.',
            );
          case 404:
            return NotFoundException(
              serverMessage ?? 'المورد المطلوب غير موجود أو تم حذفه.',
            );
          case 409:
            return ConflictException(
              serverMessage ?? 'تعارض في بيانات المورد أو الشكوى مغلقة مسبقاً.',
            );
          case 413:
            return const PayloadTooLargeException();
          case 415:
            return const UnsupportedMediaTypeException();
          case 429:
            return const RateLimitException();
          default:
            return ServerException(
              serverMessage ?? 'حدث خطأ في الخادم (كود $statusCode).',
            );
        }

      case DioExceptionType.badCertificate:
        return const NetworkException(
          'فشل التحقق من شهادة أمان الخادم (TLS Handshake Failed).',
        );

      case DioExceptionType.unknown:
      default:
        return NetworkException(
          'حدث خطأ غير متوقع في الاتصال: ${error.message ?? ""}',
        );
    }
  }
}
