import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../core/security/jwt_claims_parser.dart';
import '../core/security/token_manager.dart';
import '../features/authentication/screens/login_screen.dart';
import '../features/authentication/screens/registration_screen.dart';
import '../features/navigation/main_shell_screen.dart';
import '../features/user/dashboard/user_dashboard_screen.dart';
import '../features/user/complaints/my_complaints_screen.dart';
import '../features/user/complaints/create_complaint_screen.dart';
import '../features/user/complaints/complaint_details_screen.dart';
import '../features/user/complaints/edit_complaint_screen.dart';
import '../features/user/profile/user_profile_screen.dart';
import '../features/admin/dashboard/admin_dashboard_screen.dart';
import '../features/admin/assigned_complaints/assigned_complaints_screen.dart';
import '../features/admin/management/management_screen.dart';
import '../features/super_admin/dashboard/super_admin_dashboard_screen.dart';
import '../features/super_admin/all_complaints/all_complaints_screen.dart';
import '../features/super_admin/assignment/assign_complaint_screen.dart';
import '../features/super_admin/users/users_list_screen.dart';
import '../features/super_admin/users/user_details_screen.dart';
import '../features/super_admin/complaint_history/complaint_history_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      if (!GetIt.I.isRegistered<TokenManager>()) {
        return null;
      }

      final tokenManager = GetIt.I<TokenManager>();
      final isAuth = tokenManager.isAuthenticated;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Unauthenticated user trying to access protected screen
      if (!isAuth && !isAuthRoute) {
        return '/login';
      }

      // Authenticated user on login/register screen
      if (isAuth && isAuthRoute) {
        final role = tokenManager.claims?.role;
        switch (role) {
          case UserRole.user:
            return '/user-dashboard';
          case UserRole.admin:
            return '/admin-dashboard';
          case UserRole.superAdmin:
            return '/super-dashboard';
          default:
            return '/user-dashboard';
        }
      }

      return null;
    },
    routes: [
      // Authentication
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),

      // App Shell with Role-based Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainShellScreen(child: child);
        },
        routes: [
          // User Routes
          GoRoute(
            path: '/user-dashboard',
            builder: (context, state) => const UserDashboardScreen(),
          ),
          GoRoute(
            path: '/my-complaints',
            builder: (context, state) => const MyComplaintsScreen(),
          ),
          GoRoute(
            path: '/create-complaint',
            builder: (context, state) => const CreateComplaintScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const UserProfileScreen(),
          ),

          // Admin Routes
          GoRoute(
            path: '/admin-dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/assigned-complaints',
            builder: (context, state) => const AssignedComplaintsScreen(),
          ),
          GoRoute(
            path: '/management',
            builder: (context, state) => const ManagementScreen(),
          ),

          // SuperAdmin Routes
          GoRoute(
            path: '/super-dashboard',
            builder: (context, state) => const SuperAdminDashboardScreen(),
          ),
          GoRoute(
            path: '/all-complaints',
            builder: (context, state) => const AllComplaintsScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersListScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const ComplaintHistoryScreen(),
          ),
        ],
      ),

      // Standalone Detail and Edit Routes
      GoRoute(
        path: '/complaint/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ComplaintDetailsScreen(complaintId: id);
        },
      ),
      GoRoute(
        path: '/complaint/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditComplaintScreen(complaintId: id);
        },
      ),
      GoRoute(
        path: '/complaint/:id/assign',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AssignComplaintScreen(complaintId: id);
        },
      ),
      GoRoute(
        path: '/users/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return UserDetailsScreen(userId: id);
        },
      ),
    ],
  );
});
