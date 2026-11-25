import '../constants/api_endpoints.dart';
import '../errors/exceptions.dart';
import '../security/token_manager.dart';
import 'api_client.dart';

/// Authentication API Service implementing verified backend auth contracts.
class AuthApiService {
  final ApiClient _apiClient;
  final TokenManager _tokenManager;

  AuthApiService({
    required ApiClient apiClient,
    required TokenManager tokenManager,
  }) : _apiClient = apiClient,
       _tokenManager = tokenManager;

  TokenManager get tokenManager => _tokenManager;

  /// Logs in using verified route POST api/Auth/login.
  /// Backend returns { accessToken, refreshToken }.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email.trim(), 'password': password},
    );

    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final access = data['accessToken'] as String?;
      final refresh = data['refreshToken'] as String?;

      if (access != null && refresh != null) {
        await _tokenManager.updateTokens(
          accessToken: access,
          refreshToken: refresh,
        );
      }
      return data;
    }
    throw const ServerException('استجابة تسجيل الدخول غير صالحة.');
  }

  /// Registers citizen account using verified route POST api/Auth/SingIn (exact spelling preserved).
  /// Hardcodes RoleId = 1 (Citizen/User) on backend. Returns { accessToken, refreshToken }.
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? imageUrl,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (imageUrl != null && imageUrl.trim().isNotEmpty)
          'imageUrl': imageUrl.trim(),
      },
    );

    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final access = data['accessToken'] as String?;
      final refresh = data['refreshToken'] as String?;

      if (access != null && refresh != null) {
        await _tokenManager.updateTokens(
          accessToken: access,
          refreshToken: refresh,
        );
      }
      return data;
    }
    throw const ServerException('استجابة إنشاء الحساب غير صالحة.');
  }

  /// Refreshes session tokens using verified route POST api/Auth/refresh.
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': refreshToken},
    );

    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final access = data['accessToken'] as String?;
      final refresh = data['refreshToken'] as String?;

      if (access != null && refresh != null) {
        await _tokenManager.updateTokens(
          accessToken: access,
          refreshToken: refresh,
        );
      }
      return data;
    }
    throw const ServerException('فشل تجديد الجلسة.');
  }

  /// Logs out by revoking refresh token on server (POST api/Auth/logout) and clearing local session.
  Future<void> logout() async {
    final currentRefresh = _tokenManager.refreshToken;
    try {
      if (currentRefresh != null && currentRefresh.isNotEmpty) {
        await _apiClient.post(
          ApiEndpoints.logout,
          data: {'refreshToken': currentRefresh},
        );
      }
    } catch (_) {
      // Best effort server revocation; local session must be cleared regardless
    } finally {
      await _tokenManager.invalidateSession();
    }
  }
}
