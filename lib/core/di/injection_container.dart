import 'package:get_it/get_it.dart';
import '../../features/authentication/data/datasources/auth_remote_data_source.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/i_auth_repository.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/complaints/data/datasources/complaint_remote_data_source.dart';
import '../../features/complaints/data/repositories/complaint_repository_impl.dart';
import '../../features/complaints/domain/repositories/i_complaint_repository.dart';
import '../../features/complaints/presentation/bloc/all_complaints_bloc.dart';
import '../../features/complaints/presentation/bloc/assign_complaint_bloc.dart';
import '../../features/complaints/presentation/bloc/assigned_complaints_bloc.dart';
import '../../features/complaints/presentation/bloc/complaint_comments_bloc.dart';
import '../../features/complaints/presentation/bloc/complaint_details_bloc.dart';
import '../../features/complaints/presentation/bloc/complaint_submission_bloc.dart';
import '../../features/complaints/presentation/bloc/complaints_bloc.dart';
import '../../features/complaints/presentation/bloc/super_admin_dashboard_bloc.dart';
import '../../features/super_admin/data/datasources/user_remote_data_source.dart';
import '../../features/super_admin/data/repositories/super_admin_user_repository_impl.dart';
import '../../features/super_admin/domain/repositories/i_super_admin_user_repository.dart';
import '../../features/super_admin/presentation/bloc/users_bloc.dart';
import '../network/api_client.dart';
import '../network/attachment_upload_service.dart';
import '../network/auth_api_service.dart';
import '../security/secure_token_storage.dart';
import '../security/token_manager.dart';

final sl = GetIt.instance;

/// Initializes Core Network, Security, Authentication, and Complaints dependencies.
Future<void> initCoreDependencies() async {
  // Security & Storage
  if (!sl.isRegistered<ISecureTokenStorage>()) {
    sl.registerLazySingleton<ISecureTokenStorage>(
      () => SecureTokenStorageImpl(),
    );
  }

  if (!sl.isRegistered<TokenManager>()) {
    sl.registerLazySingleton<TokenManager>(
      () => TokenManager(sl<ISecureTokenStorage>()),
    );
  }

  // Network Client
  if (!sl.isRegistered<ApiClient>()) {
    sl.registerLazySingleton<ApiClient>(
      () => ApiClient(tokenManager: sl<TokenManager>()),
    );
  }

  // API Services
  if (!sl.isRegistered<AuthApiService>()) {
    sl.registerLazySingleton<AuthApiService>(
      () => AuthApiService(
        apiClient: sl<ApiClient>(),
        tokenManager: sl<TokenManager>(),
      ),
    );
  }

  if (!sl.isRegistered<AttachmentUploadService>()) {
    sl.registerLazySingleton<AttachmentUploadService>(
      () => AttachmentUploadService(apiClient: sl<ApiClient>()),
    );
  }

  // Authentication Data Sources & Repositories
  if (!sl.isRegistered<IAuthRemoteDataSource>()) {
    sl.registerLazySingleton<IAuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl<AuthApiService>()),
    );
  }

  if (!sl.isRegistered<IAuthRepository>()) {
    sl.registerLazySingleton<IAuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl<IAuthRemoteDataSource>(),
        tokenManager: sl<TokenManager>(),
      ),
    );
  }

  // Authentication BLoC
  if (!sl.isRegistered<AuthBloc>()) {
    sl.registerFactory<AuthBloc>(
      () => AuthBloc(authRepository: sl<IAuthRepository>()),
    );
  }

  // Citizen & Complaints Data Sources & Repositories
  if (!sl.isRegistered<IComplaintRemoteDataSource>()) {
    sl.registerLazySingleton<IComplaintRemoteDataSource>(
      () => ComplaintRemoteDataSourceImpl(
        apiClient: sl<ApiClient>(),
        attachmentUploadService: sl<AttachmentUploadService>(),
      ),
    );
  }

  if (!sl.isRegistered<IComplaintRepository>()) {
    sl.registerLazySingleton<IComplaintRepository>(
      () => ComplaintRepositoryImpl(
        remoteDataSource: sl<IComplaintRemoteDataSource>(),
        tokenManager: sl<TokenManager>(),
      ),
    );
  }

  // Citizen & Complaints BLoCs
  if (!sl.isRegistered<ComplaintsBloc>()) {
    sl.registerFactory<ComplaintsBloc>(
      () => ComplaintsBloc(repository: sl<IComplaintRepository>()),
    );
  }

  if (!sl.isRegistered<ComplaintDetailsBloc>()) {
    sl.registerFactory<ComplaintDetailsBloc>(
      () => ComplaintDetailsBloc(repository: sl<IComplaintRepository>()),
    );
  }

  if (!sl.isRegistered<ComplaintSubmissionBloc>()) {
    sl.registerFactory<ComplaintSubmissionBloc>(
      () => ComplaintSubmissionBloc(repository: sl<IComplaintRepository>()),
    );
  }

  // Employee & Assigned Complaints BLoCs
  if (!sl.isRegistered<AssignedComplaintsBloc>()) {
    sl.registerFactory<AssignedComplaintsBloc>(
      () => AssignedComplaintsBloc(repository: sl<IComplaintRepository>()),
    );
  }

  if (!sl.isRegistered<ComplaintCommentsBloc>()) {
    sl.registerFactory<ComplaintCommentsBloc>(
      () => ComplaintCommentsBloc(repository: sl<IComplaintRepository>()),
    );
  }

  // SuperAdmin Data Sources & Repositories
  if (!sl.isRegistered<IUserRemoteDataSource>()) {
    sl.registerLazySingleton<IUserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
    );
  }

  if (!sl.isRegistered<ISuperAdminUserRepository>()) {
    sl.registerLazySingleton<ISuperAdminUserRepository>(
      () => SuperAdminUserRepositoryImpl(
        remoteDataSource: sl<IUserRemoteDataSource>(),
      ),
    );
  }

  // SuperAdmin BLoCs
  if (!sl.isRegistered<SuperAdminDashboardBloc>()) {
    sl.registerFactory<SuperAdminDashboardBloc>(
      () => SuperAdminDashboardBloc(repository: sl<IComplaintRepository>()),
    );
  }

  if (!sl.isRegistered<AssignComplaintBloc>()) {
    sl.registerFactory<AssignComplaintBloc>(
      () => AssignComplaintBloc(
        complaintRepository: sl<IComplaintRepository>(),
        userRepository: sl<ISuperAdminUserRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<AllComplaintsBloc>()) {
    sl.registerFactory<AllComplaintsBloc>(
      () => AllComplaintsBloc(repository: sl<IComplaintRepository>()),
    );
  }

  if (!sl.isRegistered<UsersBloc>()) {
    sl.registerFactory<UsersBloc>(
      () => UsersBloc(userRepository: sl<ISuperAdminUserRepository>()),
    );
  }
}
