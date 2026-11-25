import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logging interceptor that sanitizes sensitive data (tokens, passwords, keys).
/// Stripped completely in release builds to guarantee zero leakages in production.
class SanitizedLoggingInterceptor extends Interceptor {
  static const Set<String> _sensitiveKeys = {
    'password',
    'currentpassword',
    'newpassword',
    'confirmpassword',
    'refreshtoken',
    'accesstoken',
    'token',
    'authorization',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final sanitizedHeaders = _sanitizeMap(options.headers);
      final sanitizedData = _sanitizeData(options.data);
      debugPrint(
        '┌─── HTTP REQUEST ────────────────────────────────────────────────',
      );
      debugPrint('│ [${options.method}] ${options.uri}');
      debugPrint('│ Headers: $sanitizedHeaders');
      if (sanitizedData != null) {
        debugPrint('│ Body: $sanitizedData');
      }
      debugPrint(
        '└─────────────────────────────────────────────────────────────────',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final sanitizedData = _sanitizeData(response.data);
      debugPrint(
        '┌─── HTTP RESPONSE [${response.statusCode}] ────────────────────────────────────',
      );
      debugPrint('│ URI: ${response.requestOptions.uri}');
      if (sanitizedData != null) {
        debugPrint('│ Data: $sanitizedData');
      }
      debugPrint(
        '└─────────────────────────────────────────────────────────────────',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '┌─── HTTP ERROR [${err.response?.statusCode}] ──────────────────────────────────────',
      );
      debugPrint('│ URI: ${err.requestOptions.uri}');
      debugPrint('│ Message: ${err.message}');
      if (err.response?.data != null) {
        debugPrint('│ Response: ${_sanitizeData(err.response?.data)}');
      }
      debugPrint(
        '└─────────────────────────────────────────────────────────────────',
      );
    }
    handler.next(err);
  }

  static dynamic _sanitizeData(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      return _sanitizeMap(data);
    }
    if (data is List) {
      return data.map((item) => _sanitizeData(item)).toList();
    }
    if (data is FormData) {
      final fields = data.fields.map((f) {
        final keyLower = f.key.toLowerCase();
        final value = _sensitiveKeys.contains(keyLower)
            ? '[REDACTED]'
            : f.value;
        return '${f.key}: $value';
      }).toList();
      final files = data.files
          .map(
            (f) =>
                '${f.key}: <File: ${f.value.filename}, ${f.value.length} bytes>',
          )
          .toList();
      return 'FormData(fields: $fields, files: $files)';
    }
    return data;
  }

  static Map<String, dynamic> _sanitizeMap(Map<dynamic, dynamic> map) {
    final sanitized = <String, dynamic>{};
    for (final entry in map.entries) {
      final keyStr = entry.key.toString();
      final keyLower = keyStr.toLowerCase();
      if (_sensitiveKeys.contains(keyLower)) {
        sanitized[keyStr] = '[REDACTED]';
      } else if (entry.value is Map) {
        sanitized[keyStr] = _sanitizeMap(entry.value as Map);
      } else if (entry.value is List) {
        sanitized[keyStr] = (entry.value as List)
            .map((v) => _sanitizeData(v))
            .toList();
      } else {
        sanitized[keyStr] = entry.value;
      }
    }
    return sanitized;
  }
}
