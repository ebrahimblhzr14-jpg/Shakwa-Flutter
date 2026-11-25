import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Environment-aware application network configuration.
class AppConfig {
  static const String _defaultPort = '5000';
  static const String _httpsPort = '7043';
  static const String _apiPrefix = 'api';

  /// Compile-time environment flags:
  /// `--dart-define=API_ENV=local_emulator`
  /// `--dart-define=API_ENV=local_desktop`
  /// `--dart-define=API_ENV=physical_dev`
  /// `--dart-define=API_ENV=production`
  /// `--dart-define=API_URL=https://<your-host>/api`
  /// `--dart-define=LAN_IP=192.168.1.15`
  static const String _env = String.fromEnvironment(
    'API_ENV',
    defaultValue: '',
  );
  static const String _customUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: '',
  );
  static const String _lanIp = String.fromEnvironment(
    'LAN_IP',
    defaultValue: '',
  );

  static String get httpsPort => _httpsPort;

  /// Resolves the API base URL based on compile-time environment and platform runtime.
  static String get baseUrl {
    if (_customUrl.isNotEmpty) {
      return _customUrl.endsWith('/')
          ? _customUrl.substring(0, _customUrl.length - 1)
          : _customUrl;
    }

    if (_env == 'production') {
      // Must be provided via API_URL in production builds
      throw StateError(
        'Production API_URL must be specified via --dart-define=API_URL=https://<api-domain>/api',
      );
    }

    if (_env == 'physical_dev' || _lanIp.isNotEmpty) {
      final ip = _lanIp.isNotEmpty ? _lanIp : '192.168.1.100';
      return 'http://$ip:$_defaultPort/$_apiPrefix';
    }

    if (kIsWeb) {
      return 'http://localhost:$_defaultPort/$_apiPrefix';
    }

    if (Platform.isAndroid) {
      // Android emulator maps the host development machine loopback to 10.0.2.2
      return 'http://10.0.2.2:$_defaultPort/$_apiPrefix';
    }

    if (Platform.isWindows || Platform.isIOS || Platform.isMacOS) {
      return 'http://localhost:$_defaultPort/$_apiPrefix';
    }

    return 'http://localhost:$_defaultPort/$_apiPrefix';
  }

  // Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);

  // File Upload Constraints (Verified against ASP.NET AttachmentController.cs)
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const List<String> allowedExtensions = ['.jpg', '.jpeg', '.png'];
  static const List<String> allowedMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/jpg',
  ];
}
