import 'dart:async';
import 'package:dio/dio.dart';
import '../../constants/api_endpoints.dart';
import '../../errors/exceptions.dart';
import '../../security/token_manager.dart';

/// Queued authentication interceptor managing Bearer token injection,
/// single-flight mutex token refresh, stale-token detection, and single-retry loop prevention.
class AuthInterceptor extends QueuedInterceptor {
  final TokenManager _tokenManager;
  final Dio _refreshDio;

  // Single-flight refresh mutex
  Completer<bool>? _refreshCompleter;

  AuthInterceptor({required TokenManager tokenManager, required Dio refreshDio})
    : _tokenManager = tokenManager,
      _refreshDio = refreshDio;

  bool _isExemptEndpoint(String path) {
    final lower = path.toLowerCase();
    return lower.contains(ApiEndpoints.login.toLowerCase()) ||
        lower.contains(ApiEndpoints.register.toLowerCase()) ||
        lower.contains(ApiEndpoints.refreshToken.toLowerCase()) ||
        lower.contains(ApiEndpoints.logout.toLowerCase());
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Exempt authentication endpoints from Bearer injection
    if (_isExemptEndpoint(options.path)) {
      return handler.next(options);
    }

    final token = _tokenManager.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final statusCode = response?.statusCode;
    final options = err.requestOptions;

    // Only intercept HTTP 401 on non-exempt business endpoints
    if (statusCode != 401 || _isExemptEndpoint(options.path)) {
      return handler.next(err);
    }

    // Guard 1: Loop Prevention — Retried request failed again with 401
    final isRetry = options.extra['is_retry'] == true;
    if (isRetry) {
      await _tokenManager.invalidateSession();
      return handler.reject(
        DioException(
          requestOptions: options,
          response: response,
          type: DioExceptionType.badResponse,
          error: const SessionExpiredException(
            'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مجدداً.',
          ),
        ),
      );
    }

    // Guard 2: Stale-Token Check (Critical Concurrency Guard)
    // If another concurrent request has ALREADY refreshed the access token in memory,
    // replay this request immediately with the newest token without triggering another refresh call!
    final activeToken = _tokenManager.accessToken;
    final tokenUsed = (options.headers['Authorization'] as String?)
        ?.replaceFirst('Bearer ', '')
        .trim();

    if (activeToken != null &&
        activeToken.isNotEmpty &&
        activeToken != tokenUsed) {
      try {
        final replayedResponse = await _replayRequest(options, activeToken);
        return handler.resolve(replayedResponse);
      } on DioException catch (retryErr) {
        return handler.next(retryErr);
      } catch (e) {
        return handler.next(DioException(requestOptions: options, error: e));
      }
    }

    // Guard 3: Single-Flight Mutex Coalescing
    final refreshSuccess = await _executeSingleFlightRefresh();

    if (refreshSuccess) {
      final newToken = _tokenManager.accessToken;
      if (newToken != null && newToken.isNotEmpty) {
        try {
          final replayedResponse = await _replayRequest(options, newToken);
          return handler.resolve(replayedResponse);
        } on DioException catch (retryErr) {
          return handler.next(retryErr);
        }
      }
    }

    // Refresh rejected, revoked, or failed
    await _tokenManager.invalidateSession();
    return handler.reject(
      DioException(
        requestOptions: options,
        response: response,
        type: DioExceptionType.badResponse,
        error: const SessionExpiredException('انتهت صلاحية الجلسة.'),
      ),
    );
  }

  /// Coordinates a single active refresh request while coalescing concurrent requests.
  Future<bool> _executeSingleFlightRefresh() async {
    // If another request is currently refreshing, await its future!
    if (_refreshCompleter != null) {
      try {
        return await _refreshCompleter!.future;
      } catch (_) {
        return false;
      }
    }

    _refreshCompleter = Completer<bool>();

    try {
      final currentRefreshToken = _tokenManager.refreshToken;
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        _refreshCompleter!.complete(false);
        return false;
      }

      // Execute refresh using dedicated, non-intercepted Dio instance
      final response = await _refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': currentRefreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final newAccess = data['accessToken'] as String?;
        final newRefresh = data['refreshToken'] as String?;

        if (newAccess != null && newRefresh != null) {
          await _tokenManager.updateTokens(
            accessToken: newAccess,
            refreshToken: newRefresh,
          );
          _refreshCompleter!.complete(true);
          return true;
        }
      }

      // Backend returned 400 or 401 (token revoked or expired)
      _refreshCompleter!.complete(false);
      return false;
    } on DioException catch (e) {
      // If network is down, do not report successful refresh
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout) {
        _refreshCompleter!.complete(false);
        return false;
      }
      _refreshCompleter!.complete(false);
      return false;
    } catch (_) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Replays the original request exactly once using the dedicated non-intercepted Dio instance with new Bearer token.
  Future<Response> _replayRequest(RequestOptions options, String newToken) {
    final retryOptions = Options(
      method: options.method,
      headers: Map<String, dynamic>.from(options.headers)
        ..['Authorization'] = 'Bearer $newToken',
      responseType: options.responseType,
      contentType: options.contentType,
      validateStatus: options.validateStatus,
      receiveTimeout: options.receiveTimeout,
      sendTimeout: options.sendTimeout,
      extra: Map<String, dynamic>.from(options.extra)..['is_retry'] = true,
    );

    return _refreshDio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: retryOptions,
    );
  }
}
