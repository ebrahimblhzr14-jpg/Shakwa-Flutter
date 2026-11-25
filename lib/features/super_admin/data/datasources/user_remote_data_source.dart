import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_dto.dart';

abstract class IUserRemoteDataSource {
  Future<List<UserDto>> getAllUsers();
  Future<UserDto> getUserById(int id);
  Future<void> activateUser(int id);
  Future<void> deactivateUser(int id);
}

class UserRemoteDataSourceImpl implements IUserRemoteDataSource {
  final ApiClient _apiClient;

  UserRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<UserDto>> getAllUsers() async {
    final response = await _apiClient.get(ApiEndpoints.allUsers);
    if (response.data is List) {
      final list = response.data as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => UserDto.fromJson(json))
          .toList();
    }
    return [];
  }

  @override
  Future<UserDto> getUserById(int id) async {
    final response = await _apiClient.get(ApiEndpoints.userById(id));
    return UserDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> activateUser(int id) async {
    await _apiClient.patch(ApiEndpoints.activateUser(id));
  }

  @override
  Future<void> deactivateUser(int id) async {
    await _apiClient.patch(ApiEndpoints.deactivateUser(id));
  }
}
