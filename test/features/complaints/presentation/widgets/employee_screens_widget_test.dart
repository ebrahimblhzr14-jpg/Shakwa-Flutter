import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shakwa_app/core/security/jwt_claims_parser.dart';
import 'package:shakwa_app/core/security/secure_token_storage.dart';
import 'package:shakwa_app/core/security/token_manager.dart';
import 'package:shakwa_app/core/security/token_record.dart';
import 'package:shakwa_app/features/admin/assigned_complaints/assigned_complaints_screen.dart';
import 'package:shakwa_app/features/admin/dashboard/admin_dashboard_screen.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_comment.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_details.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_history_item.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_status.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/assigned_complaints_bloc.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/complaint_comments_bloc.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/complaint_details_bloc.dart';
import 'package:shakwa_app/features/user/complaints/complaint_details_screen.dart';
import '../bloc/fake_complaint_repository.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// A minimal ISecureTokenStorage that holds nothing (tokens start absent).
class _NullTokenStorage implements ISecureTokenStorage {
  @override
  bool get isVolatileSession => false;
  @override
  Future<void> saveTokenRecord(TokenRecord r) async {}
  @override
  Future<TokenRecord?> getTokenRecord() async => null;
  @override
  Future<void> clearTokenRecord() async {}
}

/// A TokenManager whose claims are injected directly for test purposes,
/// bypassing JWT parsing (which requires a real encoded token).
class _FakeAdminTokenManager extends TokenManager {
  final JwtClaims _fakeClaims;

  _FakeAdminTokenManager(this._fakeClaims) : super(_NullTokenStorage());

  @override
  JwtClaims? get claims => _fakeClaims;
}

Widget _buildTestApp(Widget child, {List<GoRoute> extraRoutes = const []}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => child),
      GoRoute(
        path: '/assigned-complaints',
        builder: (_, __) => const Scaffold(body: Text('Assigned Complaints')),
      ),
      GoRoute(
        path: '/management',
        builder: (_, __) => const Scaffold(body: Text('Management')),
      ),
      GoRoute(
        path: '/complaint/:id',
        builder: (_, state) => Text('Complaint ${state.pathParameters['id']}'),
      ),
      GoRoute(
        path: '/complaint/:id/edit',
        builder: (_, state) => Text('Edit ${state.pathParameters['id']}'),
      ),
      ...extraRoutes,
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
      locale: const Locale('ar'),
      builder: (context, widget) =>
          Directionality(textDirection: TextDirection.rtl, child: widget!),
    ),
  );
}

void main() {
  late FakeComplaintRepository fakeRepository;

  final sampleAssignedComplaints = [
    Complaint(
      id: 201,
      userId: 10,
      categoryId: 1,
      categoryName: 'الكهرباء',
      statusId: 1,
      status: ComplaintStatus.pending,
      priorityId: 2,
      priority: ComplaintPriority.medium,
      title: 'عطل محول كهرباء',
      description: 'انقطاع التيار في المربع السكني',
      createdAt: DateTime(2026, 11, 24),
    ),
    Complaint(
      id: 202,
      userId: 11,
      categoryId: 2,
      categoryName: 'المياه',
      statusId: 3,
      status: ComplaintStatus.inProgress,
      priorityId: 3,
      priority: ComplaintPriority.high,
      title: 'انكسار خط مياه رئيسي',
      description: 'تدفق المياه في الشارع العام',
      createdAt: DateTime(2026, 11, 23),
    ),
    Complaint(
      id: 203,
      userId: 12,
      categoryId: 3,
      categoryName: 'النظافة',
      statusId: 4,
      status: ComplaintStatus.resolved,
      priorityId: 1,
      priority: ComplaintPriority.low,
      title: 'إزالة نفايات صلبة',
      description: 'تم إنجاز العمل بالكامل',
      createdAt: DateTime(2026, 11, 22),
    ),
  ];

  final adminClaims = JwtClaims(
    userId: 5,
    fullName: 'المشرف الميداني',
    email: 'admin@test.com',
    role: UserRole.admin,
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );

  setUp(() {
    fakeRepository = FakeComplaintRepository();
    // Reset GetIt so we can register test fakes
    if (GetIt.I.isRegistered<TokenManager>()) {
      GetIt.I.unregister<TokenManager>();
    }
  });

  tearDown(() {
    if (GetIt.I.isRegistered<TokenManager>()) {
      GetIt.I.unregister<TokenManager>();
    }
  });

  // =========================================================================
  // AdminDashboardScreen
  // =========================================================================
  group('AdminDashboardScreen Widget Tests', () {
    testWidgets('displays workload metrics and recent assigned complaints', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      fakeRepository.assignedComplaintsResult = sampleAssignedComplaints;
      final assignedBloc = AssignedComplaintsBloc(repository: fakeRepository);

      await tester.pumpWidget(
        _buildTestApp(
          AdminDashboardScreen(assignedComplaintsBloc: assignedBloc),
        ),
      );
      await tester.pumpAndSettle();

      // Header & Banner
      expect(find.text('لوحة تحكم المشرف'), findsOneWidget);
      expect(find.text('مركز معالجة البلاغات الميدانية'), findsOneWidget);

      // Workload metrics — 3 total, one each of pending/inProgress/resolved
      expect(find.text('3'), findsOneWidget);
      expect(find.text('1'), findsNWidgets(3));

      // Recent complaints section header
      expect(find.text('أحدث الشكاوى المسندة'), findsOneWidget);

      // At least one complaint card title
      expect(find.text('عطل محول كهرباء'), findsOneWidget);
    });

    testWidgets(
      'displays empty state when employee has no assigned complaints',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        fakeRepository.assignedComplaintsResult = [];
        final assignedBloc = AssignedComplaintsBloc(repository: fakeRepository);

        await tester.pumpWidget(
          _buildTestApp(
            AdminDashboardScreen(assignedComplaintsBloc: assignedBloc),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('لا توجد شكاوى مسندة لك حالياً'), findsOneWidget);
      },
    );
  });

  // =========================================================================
  // AssignedComplaintsScreen
  // =========================================================================
  group('AssignedComplaintsScreen Widget Tests', () {
    testWidgets('renders assigned complaints list with status filter chips', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      fakeRepository.assignedComplaintsResult = sampleAssignedComplaints;
      final assignedBloc = AssignedComplaintsBloc(repository: fakeRepository);

      await tester.pumpWidget(
        _buildTestApp(
          AssignedComplaintsScreen(assignedComplaintsBloc: assignedBloc),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الشكاوى المسندة'), findsOneWidget);
      expect(find.text('عطل محول كهرباء'), findsOneWidget);
      expect(find.text('انكسار خط مياه رئيسي'), findsOneWidget);
      expect(find.text('إزالة نفايات صلبة'), findsOneWidget);

      // Filter chips exist
      expect(find.widgetWithText(ChoiceChip, 'الكل'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'قيد المعالجة'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'تم الحل'), findsOneWidget);
    });

    testWidgets('filters assigned complaints by status chip tap', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      fakeRepository.assignedComplaintsResult = sampleAssignedComplaints;
      final assignedBloc = AssignedComplaintsBloc(repository: fakeRepository);

      await tester.pumpWidget(
        _buildTestApp(
          AssignedComplaintsScreen(assignedComplaintsBloc: assignedBloc),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'قيد المعالجة' filter chip
      await tester.tap(find.text('قيد المعالجة').first);
      await tester.pumpAndSettle();

      // Only the inProgress complaint should be visible
      expect(find.text('انكسار خط مياه رئيسي'), findsOneWidget);
      expect(find.text('عطل محول كهرباء'), findsNothing);
      expect(find.text('إزالة نفايات صلبة'), findsNothing);
    });

    testWidgets('searches complaints by keyword', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      fakeRepository.assignedComplaintsResult = sampleAssignedComplaints;
      final assignedBloc = AssignedComplaintsBloc(repository: fakeRepository);

      await tester.pumpWidget(
        _buildTestApp(
          AssignedComplaintsScreen(assignedComplaintsBloc: assignedBloc),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'محول');
      await tester.pumpAndSettle();

      expect(find.text('عطل محول كهرباء'), findsOneWidget);
      expect(find.text('انكسار خط مياه رئيسي'), findsNothing);
    });

    testWidgets(
      'quick status IconButton appears and tapping opens bottom sheet',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        fakeRepository.assignedComplaintsResult = sampleAssignedComplaints;
        final assignedBloc = AssignedComplaintsBloc(repository: fakeRepository);

        await tester.pumpWidget(
          _buildTestApp(
            AssignedComplaintsScreen(assignedComplaintsBloc: assignedBloc),
          ),
        );
        await tester.pumpAndSettle();

        // The quick-status IconButton uses Icons.sync_rounded
        final syncButtons = find.byIcon(Icons.sync_rounded);
        expect(syncButtons, findsWidgets);

        await tester.tap(syncButtons.first);
        await tester.pumpAndSettle();

        // Modal bottom sheet should contain 'تحديث حالة الشكوى'
        expect(find.text('تحديث حالة الشكوى'), findsOneWidget);
      },
    );
  });

  // =========================================================================
  // ComplaintDetailsScreen — Employee role (with fake TokenManager registered)
  // =========================================================================
  group('ComplaintDetailsScreen Employee Integration Widget Tests', () {
    testWidgets(
      'renders comments section and employee status update button when user is admin',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        // Register admin TokenManager so _isEmployee returns true
        GetIt.I.registerSingleton<TokenManager>(
          _FakeAdminTokenManager(adminClaims),
        );

        final openComplaint = Complaint(
          id: 301,
          userId: 10,
          categoryId: 1,
          categoryName: 'الكهرباء',
          statusId: 3,
          status: ComplaintStatus.inProgress,
          priorityId: 2,
          priority: ComplaintPriority.medium,
          title: 'بلاغ قيد المعالجة الميدانية',
          description: 'جاري فحص وتأهيل الشبكة',
          createdAt: DateTime(2026, 11, 24),
        );

        fakeRepository.getDetailsResult = ComplaintDetails(
          complaint: openComplaint,
          history: [
            ComplaintHistoryItem(
              id: 1,
              complaintId: 301,
              action: 'تم التعيين للمشرف',
              createdAt: DateTime(2026, 11, 24),
            ),
          ],
        );

        fakeRepository.commentsResult = [
          ComplaintComment(
            id: 1,
            complaintId: 301,
            userId: 5,
            userName: 'م. أحمد المشرف',
            comment: 'تم الانتقال لموقع البلاغ والمعاينة',
            createdAt: DateTime(2026, 11, 24, 10, 0),
          ),
        ];

        final detailsBloc = ComplaintDetailsBloc(repository: fakeRepository);
        final commentsBloc = ComplaintCommentsBloc(repository: fakeRepository);
        final assignedBloc = AssignedComplaintsBloc(repository: fakeRepository);

        await tester.pumpWidget(
          _buildTestApp(
            ComplaintDetailsScreen(
              complaintId: '301',
              detailsBloc: detailsBloc,
              commentsBloc: commentsBloc,
              assignedComplaintsBloc: assignedBloc,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Comments section heading
        expect(find.text('الملاحظات والتعليقات الفنية'), findsOneWidget);

        // Existing comment in the list
        expect(find.text('م. أحمد المشرف'), findsOneWidget);
        expect(find.text('تم الانتقال لموقع البلاغ والمعاينة'), findsOneWidget);

        // Employee status update button (open complaint + isEmployee)
        expect(find.text('تغيير حالة البلاغ الميداني'), findsOneWidget);

        // Comment text field (not closed)
        expect(
          find.widgetWithText(
            TextField,
            'إضافة ملاحظة فنية أو توجيه ميداني...',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('comment submit increments repository add count', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      GetIt.I.registerSingleton<TokenManager>(
        _FakeAdminTokenManager(adminClaims),
      );

      final openComplaint = Complaint(
        id: 302,
        userId: 10,
        categoryId: 1,
        statusId: 3,
        status: ComplaintStatus.inProgress,
        priorityId: 1,
        priority: ComplaintPriority.low,
        title: 'بلاغ تعليق',
        description: 'وصف',
        createdAt: DateTime(2026, 11, 24),
      );

      fakeRepository.getDetailsResult = ComplaintDetails(
        complaint: openComplaint,
        history: const [],
      );
      fakeRepository.commentsResult = [];

      final detailsBloc = ComplaintDetailsBloc(repository: fakeRepository);
      final commentsBloc = ComplaintCommentsBloc(repository: fakeRepository);
      final assignedBloc = AssignedComplaintsBloc(repository: fakeRepository);

      await tester.pumpWidget(
        _buildTestApp(
          ComplaintDetailsScreen(
            complaintId: '302',
            detailsBloc: detailsBloc,
            commentsBloc: commentsBloc,
            assignedComplaintsBloc: assignedBloc,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter a comment
      await tester.enterText(
        find.widgetWithText(TextField, 'إضافة ملاحظة فنية أو توجيه ميداني...'),
        'تم إنجاز الصيانة بنجاح',
      );
      await tester.pumpAndSettle();

      // Tap send button
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      expect(fakeRepository.addCommentCallCount, equals(1));
    });

    testWidgets(
      'hides status update button and comment input when complaint is closed',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        GetIt.I.registerSingleton<TokenManager>(
          _FakeAdminTokenManager(adminClaims),
        );

        final closedComplaint = Complaint(
          id: 303,
          userId: 10,
          categoryId: 1,
          statusId: 5,
          status: ComplaintStatus.closed,
          priorityId: 1,
          priority: ComplaintPriority.low,
          title: 'بلاغ مغلق نهائياً',
          description: 'تم الانتهاء والإغلاق',
          createdAt: DateTime(2026, 11, 20),
          closedAt: DateTime(2026, 11, 22),
        );

        fakeRepository.getDetailsResult = ComplaintDetails(
          complaint: closedComplaint,
          history: const [],
        );
        fakeRepository.commentsResult = [];

        final detailsBloc = ComplaintDetailsBloc(repository: fakeRepository);
        final commentsBloc = ComplaintCommentsBloc(repository: fakeRepository);
        final assignedBloc = AssignedComplaintsBloc(repository: fakeRepository);

        await tester.pumpWidget(
          _buildTestApp(
            ComplaintDetailsScreen(
              complaintId: '303',
              detailsBloc: detailsBloc,
              commentsBloc: commentsBloc,
              assignedComplaintsBloc: assignedBloc,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Closed banner must appear
        expect(find.textContaining('هذه الشكوى مغلقة نهائياً'), findsOneWidget);

        // Status update button must NOT appear for a closed complaint
        expect(find.text('تغيير حالة البلاغ الميداني'), findsNothing);

        // Comment input field must NOT appear for a closed complaint
        expect(
          find.widgetWithText(
            TextField,
            'إضافة ملاحظة فنية أو توجيه ميداني...',
          ),
          findsNothing,
        );
      },
    );
  });
}
