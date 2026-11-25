import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shakwa_app/core/constants/app_strings.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_history_item.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_status.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/all_complaints_bloc.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/assign_complaint_bloc.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/super_admin_dashboard_bloc.dart';
import 'package:shakwa_app/features/super_admin/all_complaints/all_complaints_screen.dart';
import 'package:shakwa_app/features/super_admin/assignment/assign_complaint_screen.dart';
import 'package:shakwa_app/features/super_admin/complaint_history/complaint_history_screen.dart';
import 'package:shakwa_app/features/super_admin/dashboard/super_admin_dashboard_screen.dart';
import 'package:shakwa_app/features/super_admin/domain/entities/user_entity.dart';
import 'package:shakwa_app/features/super_admin/presentation/bloc/users_bloc.dart';
import 'package:shakwa_app/features/super_admin/users/user_details_screen.dart';
import 'package:shakwa_app/features/super_admin/users/users_list_screen.dart';
import '../../../complaints/presentation/bloc/fake_complaint_repository.dart';
import '../../fake_super_admin_user_repository.dart';

Widget _buildTestApp(Widget child) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => child),
      GoRoute(
        path: '/all-complaints',
        builder: (_, __) => const Scaffold(body: Text('All Complaints Page')),
      ),
      GoRoute(
        path: '/users',
        builder: (_, __) => const Scaffold(body: Text('Users Page')),
      ),
      GoRoute(
        path: '/history',
        builder: (_, __) => const Scaffold(body: Text('History Page')),
      ),
      GoRoute(
        path: '/complaint/:id',
        builder: (_, state) =>
            Scaffold(body: Text('Complaint ${state.pathParameters["id"]}')),
      ),
      GoRoute(
        path: '/complaint/:id/assign',
        builder: (_, state) =>
            Scaffold(body: Text('Assign ${state.pathParameters["id"]}')),
      ),
      GoRoute(
        path: '/users/:id',
        builder: (_, state) =>
            Scaffold(body: Text('User ${state.pathParameters["id"]}')),
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(fontFamily: 'Cairo'),
    ),
  );
}

void main() {
  late FakeComplaintRepository fakeComplaintRepo;
  late FakeSuperAdminUserRepository fakeUserRepo;

  final sampleComplaintPending = Complaint(
    id: 101,
    userId: 1,
    categoryId: 2,
    categoryName: 'نظافة عامة',
    statusId: 1,
    status: ComplaintStatus.pending,
    priorityId: 2,
    priority: ComplaintPriority.medium,
    title: 'تراكم نفايات في الحي',
    description: 'يوجد تراكم في شارع الملك فهد',
    createdAt: DateTime(2025, 2, 1),
  );

  final sampleComplaintInProgress = Complaint(
    id: 102,
    userId: 1,
    categoryId: 1,
    categoryName: 'إنارة الطرق',
    statusId: 3,
    status: ComplaintStatus.inProgress,
    priorityId: 3,
    priority: ComplaintPriority.high,
    title: 'عمود إنارة مكسور',
    description: 'عمود مائل',
    createdAt: DateTime(2025, 2, 2),
  );

  final sampleUser = UserEntity(
    id: 1,
    name: 'سالم القحطاني',
    email: 'salem@shakwa.sa',
    phone: '0551234567',
    roleId: 1,
    roleName: 'مواطن',
    isActive: true,
    createdAt: DateTime(2025, 1, 1),
  );

  final sampleEmployee = UserEntity(
    id: 2,
    name: 'م. عبدالله الصالح',
    email: 'abdullah@shakwa.sa',
    roleId: 2,
    roleName: 'مشرف صيانة',
    isActive: true,
    createdAt: DateTime(2025, 1, 2),
  );

  final sampleHistoryItem = ComplaintHistoryItem(
    id: 1,
    complaintId: 101,
    action: 'تم إسناد البلاغ',
    description: 'تم توجيه البلاغ إلى فريق الصيانة الميدانية',
    userName: 'المسؤول العام',
    createdAt: DateTime(2025, 2, 1, 14, 30),
  );

  setUp(() {
    fakeComplaintRepo = FakeComplaintRepository();
    fakeUserRepo = FakeSuperAdminUserRepository();
  });

  group('SuperAdminDashboardScreen Widget Tests', () {
    testWidgets('renders executive banner, KPIs, and needs attention section', (
      tester,
    ) async {
      fakeComplaintRepo.dashboardSummaryResult = {
        'totalComplaints': 25,
        'pendingComplaints': 5,
        'inProgressComplaints': 12,
        'resolvedComplaints': 8,
        'closedComplaints': 0,
      };
      fakeComplaintRepo.allComplaintsResult = [sampleComplaintPending];

      final bloc = SuperAdminDashboardBloc(repository: fakeComplaintRepo);

      await tester.pumpWidget(
        _buildTestApp(SuperAdminDashboardScreen(bloc: bloc)),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.superAdminDashboard), findsOneWidget);
      expect(find.text('الإدارة العامة للبلاغات'), findsOneWidget);
      expect(find.text('إجمالي البلاغات'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('تتطلب إسناد فوري'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('قيد المعالجة الميدانية'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('تم إنجازها بنجاح'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('بلاغات بحاجة إلى إسناد عاجل'), findsOneWidget);
      expect(find.text('تراكم نفايات في الحي'), findsOneWidget);
    });
  });

  group('AllComplaintsScreen Widget Tests', () {
    testWidgets(
      'renders complaints list, search field, filter chips, and assign button',
      (tester) async {
        fakeComplaintRepo.allComplaintsResult = [
          sampleComplaintPending,
          sampleComplaintInProgress,
        ];

        final bloc = AllComplaintsBloc(repository: fakeComplaintRepo);

        await tester.pumpWidget(_buildTestApp(AllComplaintsScreen(bloc: bloc)));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.navSuperAllComplaints), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('غير المسندة فقط'), findsOneWidget);
        expect(find.text('الكل'), findsOneWidget);
        expect(find.text('تراكم نفايات في الحي'), findsOneWidget);
        expect(find.text('عمود إنارة مكسور'), findsOneWidget);
        // "إسناد" action button should be rendered for the pending complaint
        expect(find.text('إسناد'), findsOneWidget);
      },
    );
  });

  group('AssignComplaintScreen Widget Tests', () {
    testWidgets(
      'renders complaint info, eligible employees dropdown, notes field, and submit button',
      (tester) async {
        fakeComplaintRepo.getByIdResult = sampleComplaintPending;
        fakeUserRepo.eligibleEmployeesResult = [sampleEmployee];

        final bloc = AssignComplaintBloc(
          complaintRepository: fakeComplaintRepo,
          userRepository: fakeUserRepo,
        );

        await tester.pumpWidget(
          _buildTestApp(AssignComplaintScreen(complaintId: '101', bloc: bloc)),
        );
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.assignToEmployee), findsOneWidget);
        expect(find.text('#101'), findsOneWidget);
        expect(find.text('تراكم نفايات في الحي'), findsOneWidget);
        expect(find.text(AppStrings.selectEmployee), findsOneWidget);
        expect(find.text('اعتماد إسناد الشكوى'), findsOneWidget);
      },
    );
  });

  group('UsersListScreen Widget Tests', () {
    testWidgets('renders user cards, role filter chips, and search input', (
      tester,
    ) async {
      fakeUserRepo.allUsersResult = [sampleUser, sampleEmployee];

      final bloc = UsersBloc(userRepository: fakeUserRepo);

      await tester.pumpWidget(_buildTestApp(UsersListScreen(bloc: bloc)));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.usersList), findsOneWidget);
      expect(find.text('سالم القحطاني'), findsOneWidget);
      expect(find.text('م. عبدالله الصالح'), findsOneWidget);
      expect(find.text('المواطنين'), findsOneWidget);
      expect(find.text('المشرفين'), findsOneWidget);
      expect(find.text('المسؤولين'), findsOneWidget);
    });
  });

  group('UserDetailsScreen Widget Tests', () {
    testWidgets(
      'renders user profile details, status badge, toggle button, and user complaints',
      (tester) async {
        fakeUserRepo.userByIdResult = sampleUser;
        fakeComplaintRepo.allComplaintsResult = [sampleComplaintPending];

        await tester.pumpWidget(
          _buildTestApp(
            UserDetailsScreen(
              userId: '1',
              userRepository: fakeUserRepo,
              complaintRepository: fakeComplaintRepo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.userDetails), findsOneWidget);
        expect(find.text('سالم القحطاني'), findsOneWidget);
        expect(find.text('salem@shakwa.sa'), findsOneWidget);
        expect(find.text('0551234567'), findsOneWidget);
        expect(find.text('تعطيل الحساب'), findsOneWidget);
        expect(find.text('تراكم نفايات في الحي'), findsOneWidget);
      },
    );
  });

  group('ComplaintHistoryScreen Widget Tests', () {
    testWidgets(
      'renders global history items, search input, and action details',
      (tester) async {
        fakeComplaintRepo.globalHistoryResult = [sampleHistoryItem];

        await tester.pumpWidget(
          _buildTestApp(
            ComplaintHistoryScreen(complaintRepository: fakeComplaintRepo),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.complaintHistory), findsOneWidget);
        expect(find.text('#101'), findsOneWidget);
        expect(find.text('تم إسناد البلاغ'), findsOneWidget);
        expect(
          find.text('تم توجيه البلاغ إلى فريق الصيانة الميدانية'),
          findsOneWidget,
        );
        expect(find.text('بواسطة: المسؤول العام'), findsOneWidget);
      },
    );
  });
}
