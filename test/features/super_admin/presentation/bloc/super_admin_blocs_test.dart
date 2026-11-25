import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/core/errors/failures.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_status.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/all_complaints_bloc.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/all_complaints_event.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/all_complaints_state.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/assign_complaint_bloc.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/assign_complaint_event.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/assign_complaint_state.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/super_admin_dashboard_bloc.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/super_admin_dashboard_event.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/super_admin_dashboard_state.dart';
import 'package:shakwa_app/features/super_admin/domain/entities/user_entity.dart';
import 'package:shakwa_app/features/super_admin/presentation/bloc/users_bloc.dart';
import 'package:shakwa_app/features/super_admin/presentation/bloc/users_event.dart';
import 'package:shakwa_app/features/super_admin/presentation/bloc/users_state.dart';
import '../../../complaints/presentation/bloc/fake_complaint_repository.dart';
import '../../fake_super_admin_user_repository.dart';

void main() {
  late FakeComplaintRepository fakeComplaintRepo;
  late FakeSuperAdminUserRepository fakeUserRepo;

  final sampleComplaint1 = Complaint(
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

  final sampleComplaint2 = Complaint(
    id: 102,
    userId: 2,
    categoryId: 1,
    categoryName: 'إنارة الطرق',
    statusId: 3,
    status: ComplaintStatus.inProgress,
    priorityId: 3,
    priority: ComplaintPriority.high,
    title: 'عمود إنارة مكسور',
    description: 'عمود إنارة مائل يشكل خطراً',
    createdAt: DateTime(2025, 2, 2),
  );

  final sampleUser1 = UserEntity(
    id: 1,
    name: 'أحمد المواطن',
    email: 'ahmed@shakwa.sa',
    roleId: 1,
    roleName: 'User',
    isActive: true,
    createdAt: DateTime(2025, 1, 1),
  );

  final sampleEmployee = UserEntity(
    id: 2,
    name: 'م. خالد المشرف',
    email: 'khaled@shakwa.sa',
    roleId: 2,
    roleName: 'Admin',
    isActive: true,
    createdAt: DateTime(2025, 1, 5),
  );

  setUp(() {
    fakeComplaintRepo = FakeComplaintRepository();
    fakeUserRepo = FakeSuperAdminUserRepository();
  });

  group('SuperAdminDashboardBloc', () {
    test(
      'emits LoadedState with summary counts and recent complaints',
      () async {
        fakeComplaintRepo.dashboardSummaryResult = {
          'totalComplaints': 50,
          'pendingComplaints': 15,
          'inProgressComplaints': 20,
          'resolvedComplaints': 10,
          'closedComplaints': 5,
        };
        fakeComplaintRepo.allComplaintsResult = [
          sampleComplaint1,
          sampleComplaint2,
        ];

        final bloc = SuperAdminDashboardBloc(repository: fakeComplaintRepo);

        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<SuperAdminDashboardLoadingState>(),
            predicate<SuperAdminDashboardLoadedState>((state) {
              return state.totalComplaints == 50 &&
                  state.pendingComplaints == 15 &&
                  state.inProgressComplaints == 20 &&
                  state.resolvedComplaints == 10 &&
                  state.recentComplaints.length == 2;
            }),
          ]),
        );

        bloc.add(const LoadSuperAdminDashboardEvent());
      },
    );

    test('emits ErrorState when summary fetch fails', () async {
      fakeComplaintRepo.dashboardSummaryFailure = const ServerFailure(
        'فشل الاتصال بالخادم',
      );

      final bloc = SuperAdminDashboardBloc(repository: fakeComplaintRepo);

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<SuperAdminDashboardLoadingState>(),
          predicate<SuperAdminDashboardErrorState>(
            (s) => s.message.contains('فشل الاتصال بالخادم'),
          ),
        ]),
      );

      bloc.add(const LoadSuperAdminDashboardEvent());
    });
  });

  group('AllComplaintsBloc', () {
    test(
      'loads all complaints and filters by search query and status',
      () async {
        fakeComplaintRepo.allComplaintsResult = [
          sampleComplaint1,
          sampleComplaint2,
        ];

        final bloc = AllComplaintsBloc(repository: fakeComplaintRepo);

        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<AllComplaintsLoadingState>(),
            predicate<AllComplaintsLoadedState>(
              (s) => s.filteredComplaints.length == 2,
            ),
            // After search query 'نفايات'
            predicate<AllComplaintsLoadedState>(
              (s) =>
                  s.filteredComplaints.length == 1 &&
                  s.filteredComplaints.first.id == 101,
            ),
            // After filtering only unassigned (status == 1)
            predicate<AllComplaintsLoadedState>(
              (s) =>
                  s.filteredComplaints.length == 1 &&
                  s.filteredComplaints.first.statusId == 1,
            ),
          ]),
        );

        bloc.add(const LoadAllComplaintsEvent());
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const SearchAllComplaintsEvent('نفايات'));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const FilterAllComplaintsEvent(onlyUnassigned: true));
      },
    );
  });

  group('AssignComplaintBloc', () {
    test(
      'loads complaint details and eligible employees, then submits assignment',
      () async {
        fakeComplaintRepo.getByIdResult = sampleComplaint1;
        fakeUserRepo.eligibleEmployeesResult = [sampleEmployee];

        final bloc = AssignComplaintBloc(
          complaintRepository: fakeComplaintRepo,
          userRepository: fakeUserRepo,
        );

        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<AssignComplaintLoadingState>(),
            predicate<AssignComplaintLoadedState>(
              (s) => s.complaint.id == 101 && s.eligibleEmployees.length == 1,
            ),
            predicate<AssignComplaintLoadedState>(
              (s) => s.isSubmitting == true,
            ),
            isA<AssignComplaintSuccessState>(),
          ]),
        );

        bloc.add(const LoadAssignmentDataEvent(101));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(
          const SubmitAssignmentEvent(
            complaintId: 101,
            assignedToUserId: 2,
            notes: 'ملاحظات هامة',
          ),
        );
      },
    );
  });

  group('UsersBloc', () {
    test(
      'loads users, filters by role and search query, and toggles status',
      () async {
        fakeUserRepo.allUsersResult = [sampleUser1, sampleEmployee];

        final bloc = UsersBloc(userRepository: fakeUserRepo);

        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<UsersLoadingState>(),
            predicate<UsersLoadedState>((s) => s.filteredUsers.length == 2),
            // After filtering roleId 2 (Employee/Admin)
            predicate<UsersLoadedState>(
              (s) =>
                  s.filteredUsers.length == 1 && s.filteredUsers.first.id == 2,
            ),
            // After toggling user status
            predicate<UsersLoadedState>(
              (s) =>
                  s.actionFeedbackMessage != null &&
                  s.actionFeedbackMessage!.contains('بنجاح'),
            ),
          ]),
        );

        bloc.add(const LoadUsersEvent());
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const FilterUsersByRoleEvent(2));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const ToggleUserStatusEvent(userId: 2, activate: false));
      },
    );
  });
}
