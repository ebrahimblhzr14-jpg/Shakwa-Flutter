import '../../../../core/network/auth_api_service.dart';

abstract class IAuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  Future<Map<String, dynamic>> refreshToken({required String refreshToken});

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  final AuthApiService _apiService;

  AuthRemoteDataSourceImpl(this._apiService);

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) => _apiService.login(email: email, password: password);

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) => _apiService.register(
    name: name,
    email: email,
    password: password,
    phone: phone,
  );

  @override
  Future<Map<String, dynamic>> refreshToken({required String refreshToken}) =>
      _apiService.refreshToken(refreshToken: refreshToken);

  @override
  Future<void> logout() => _apiService.logout();
}
