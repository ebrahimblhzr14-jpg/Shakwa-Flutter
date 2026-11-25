import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_category.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_details.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_history_item.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_status.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/complaint_comments_bloc.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/complaint_details_bloc.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/complaint_submission_bloc.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/complaints_bloc.dart';
import 'package:shakwa_app/features/user/complaints/complaint_details_screen.dart';
import 'package:shakwa_app/features/user/complaints/create_complaint_screen.dart';
import 'package:shakwa_app/features/user/complaints/edit_complaint_screen.dart';
import 'package:shakwa_app/features/user/complaints/my_complaints_screen.dart';
import 'package:shakwa_app/features/user/dashboard/user_dashboard_screen.dart';
import '../bloc/fake_complaint_repository.dart';

Widget _buildTestApp(Widget child) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => child),
      GoRoute(
        path: '/my-complaints',
        builder: (_, __) => const Scaffold(body: Text('My Complaints Route')),
      ),
      GoRoute(
        path: '/create-complaint',
        builder: (_, __) =>
            const Scaffold(body: Text('Create Complaint Route')),
      ),
      GoRoute(
        path: '/complaint/:id',
        builder: (_, state) => Text('Complaint ${state.pathParameters['id']}'),
      ),
      GoRoute(
        path: '/complaint/:id/edit',
        builder: (_, state) => Text('Edit ${state.pathParameters['id']}'),
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
      locale: const Locale('ar'),
      builder: (context, widget) {
        return Directionality(textDirection: TextDirection.rtl, child: widget!);
      },
    ),
  );
}

void main() {
  late FakeComplaintRepository fakeRepository;

  final sampleComplaints = [
    Complaint(
      id: 101,
      userId: 10,
      categoryId: 1,
      categoryName: 'الكهرباء',
      statusId: 1,
      status: ComplaintStatus.pending,
      priorityId: 2,
      priority: ComplaintPriority.medium,
      title: 'عطل إنارة الشارع',
      description: 'العمود لا يعمل',
      createdAt: DateTime(2026, 11, 24),
    ),
    Complaint(
      id: 102,
      userId: 10,
      categoryId: 2,
      categoryName: 'المياه',
      statusId: 3,
      status: ComplaintStatus.inProgress,
      priorityId: 3,
      priority: ComplaintPriority.high,
      title: 'تسرب مياه رئيسي',
      description: 'في الحي السكني',
      createdAt: DateTime(2026, 11, 23),
    ),
    Complaint(
      id: 103,
      userId: 10,
      categoryId: 1,
      categoryName: 'الكهرباء',
      statusId: 4,
      status: ComplaintStatus.resolved,
      priorityId: 1,
      priority: ComplaintPriority.low,
      title: 'صيانة محول',
      description: 'تم الانتهاء',
      createdAt: DateTime(2026, 11, 20),
    ),
  ];

  setUp(() {
    fakeRepository = FakeComplaintRepository();
  });

  group('UserDashboardScreen Widget Tests', () {
    testWidgets('displays repository-backed statistics and recent complaints', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      fakeRepository.myComplaintsResult = sampleComplaints;
      final bloc = ComplaintsBloc(repository: fakeRepository);

      await tester.pumpWidget(
        _buildTestApp(UserDashboardScreen(complaintsBloc: bloc)),
      );
      await tester.pumpAndSettle();

      // Check Header
      expect(find.text('الرئيسية'), findsOneWidget);

      // Check Derived Counts: Total = 3, Pending = 1, InProgress = 1, Resolved = 1
      expect(find.text('3'), findsOneWidget); // Total
      expect(
        find.text('1'),
        findsNWidgets(3),
      ); // 1 for pending, 1 for inProgress, 1 for resolved

      // Check Recent Complaints displayed
      expect(find.text('عطل إنارة الشارع'), findsOneWidget);
      expect(find.text('تسرب مياه رئيسي'), findsOneWidget);
    });

    testWidgets('displays empty state when citizen has no complaints', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      fakeRepository.myComplaintsResult = [];
      final bloc = ComplaintsBloc(repository: fakeRepository);

      await tester.pumpWidget(
        _buildTestApp(UserDashboardScreen(complaintsBloc: bloc)),
      );
      await tester.pumpAndSettle();

      expect(find.text('لا توجد شكاوى مسجلة حتى الآن'), findsOneWidget);
      expect(find.text('تقديم أول شكوى'), findsOneWidget);
    });
  });

  group('MyComplaintsScreen Widget Tests', () {
    testWidgets('renders complaints list and filter chips', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      fakeRepository.myComplaintsResult = sampleComplaints;
      final bloc = ComplaintsBloc(repository: fakeRepository);

      await tester.pumpWidget(
        _buildTestApp(MyComplaintsScreen(complaintsBloc: bloc)),
      );
      await tester.pumpAndSettle();

      expect(find.text('شكاواي'), findsOneWidget);
      expect(find.text('عطل إنارة الشارع'), findsOneWidget);
      expect(find.text('تسرب مياه رئيسي'), findsOneWidget);

      // Filter by In Progress
      await tester.tap(find.text('قيد المعالجة').first);
      await tester.pumpAndSettle();

      expect(find.text('تسرب مياه رئيسي'), findsOneWidget);
      expect(find.text('عطل إنارة الشارع'), findsNothing);
    });
  });

  group('ComplaintDetailsScreen Widget Tests', () {
    testWidgets(
      'displays complaint information, primary image and history timeline',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final detailComplaint = Complaint(
          id: 70,
          userId: 10,
          categoryId: 1,
          categoryName: 'الكهرباء',
          statusId: 1,
          status: ComplaintStatus.pending,
          priorityId: 2,
          priority: ComplaintPriority.medium,
          title: 'عطل تفصيلي',
          description: 'شرح مفصل للمشكلة في الحي',
          createdAt: DateTime(2026, 11, 24),
        );

        fakeRepository.getDetailsResult = ComplaintDetails(
          complaint: detailComplaint,
          history: [
            ComplaintHistoryItem(
              id: 1,
              complaintId: 70,
              action: 'تم استلام البلاغ',
              description: 'تم توجيهه إلى طاقم الصيانة',
              createdAt: DateTime(2026, 11, 24),
            ),
          ],
          primaryAttachmentUrl: 'https://images.example.com/photo.jpg',
        );

        final bloc = ComplaintDetailsBloc(repository: fakeRepository);
        final commentsBloc = ComplaintCommentsBloc(repository: fakeRepository);

        await tester.pumpWidget(
          _buildTestApp(
            ComplaintDetailsScreen(
              complaintId: '70',
              detailsBloc: bloc,
              commentsBloc: commentsBloc,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('#70'), findsNWidgets(2)); // in AppBar and card
        expect(find.text('عطل تفصيلي'), findsOneWidget);
        expect(find.text('شرح مفصل للمشكلة في الحي'), findsOneWidget);
        expect(find.text('تم استلام البلاغ'), findsOneWidget);
        expect(find.text('تم توجيهه إلى طاقم الصيانة'), findsOneWidget);
        expect(
          find.byIcon(Icons.edit_outlined),
          findsOneWidget,
        ); // Editable because pending
      },
    );

    testWidgets('displays closed immutable notice when complaint is closed', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final closedComplaint = Complaint(
        id: 71,
        userId: 10,
        categoryId: 1,
        categoryName: 'الكهرباء',
        statusId: 5,
        status: ComplaintStatus.closed,
        priorityId: 1,
        priority: ComplaintPriority.low,
        title: 'شكوى مغلقة',
        description: 'تم حلها مسبقاً',
        createdAt: DateTime(2026, 11, 20),
        closedAt: DateTime(2026, 11, 22),
      );

      fakeRepository.getDetailsResult = ComplaintDetails(
        complaint: closedComplaint,
        history: const [],
      );

      final bloc = ComplaintDetailsBloc(repository: fakeRepository);
      final commentsBloc = ComplaintCommentsBloc(repository: fakeRepository);

      await tester.pumpWidget(
        _buildTestApp(
          ComplaintDetailsScreen(
            complaintId: '71',
            detailsBloc: bloc,
            commentsBloc: commentsBloc,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsNothing); // Not editable
      expect(find.textContaining('هذه الشكوى مغلقة نهائياً'), findsOneWidget);
    });
  });

  group('CreateComplaintScreen Widget Tests', () {
    testWidgets('validates required fields and loads categories', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      fakeRepository.categoriesResult = [
        const ComplaintCategory(id: 1, name: 'الكهرباء والإنارة'),
        const ComplaintCategory(id: 2, name: 'المياه والصرف الصحي'),
      ];

      final bloc = ComplaintSubmissionBloc(repository: fakeRepository);

      await tester.pumpWidget(
        _buildTestApp(CreateComplaintScreen(submissionBloc: bloc)),
      );
      await tester.pumpAndSettle();

      expect(find.text('تسجيل بلاغ جديد ومتابعته'), findsOneWidget);

      // Attempt to submit without inputs
      await tester.tap(find.text('إرسال'));
      await tester.pumpAndSettle();

      // Expect validation error
      expect(find.text('هذا الحقل مطلوب'), findsWidgets);
    });
  });

  group('EditComplaintScreen Widget Tests', () {
    testWidgets('shows immutable banner when complaint is closed', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final closedComplaint = Complaint(
        id: 88,
        userId: 10,
        categoryId: 1,
        categoryName: 'الكهرباء',
        statusId: 5,
        status: ComplaintStatus.closed,
        priorityId: 1,
        priority: ComplaintPriority.low,
        title: 'شكوى مغلقة',
        description: 'تفاصيل',
        createdAt: DateTime(2026, 11, 20),
        closedAt: DateTime(2026, 11, 22),
      );

      fakeRepository.getDetailsResult = ComplaintDetails(
        complaint: closedComplaint,
      );
      final detailsBloc = ComplaintDetailsBloc(repository: fakeRepository);
      final subBloc = ComplaintSubmissionBloc(repository: fakeRepository);

      await tester.pumpWidget(
        _buildTestApp(
          EditComplaintScreen(
            complaintId: '88',
            detailsBloc: detailsBloc,
            submissionBloc: subBloc,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('لا يمكن تعديل هذه الشكوى'), findsOneWidget);
      expect(
        find.textContaining('هذه الشكوى في حالة مغلقة نهائياً'),
        findsOneWidget,
      );
    });
  });
}
