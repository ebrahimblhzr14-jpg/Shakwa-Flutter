import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/core/errors/failures.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_status.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/assigned_complaints_bloc.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/assigned_complaints_event.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/assigned_complaints_state.dart';
import 'fake_complaint_repository.dart';

void main() {
  group('AssignedComplaintsBloc Unit Tests', () {
    late FakeComplaintRepository fakeRepository;
    late AssignedComplaintsBloc bloc;

    final sampleAssignedComplaints = [
      Complaint(
        id: 101,
        userId: 10,
        categoryId: 1,
        categoryName: 'الكهرباء',
        statusId: 1,
        status: ComplaintStatus.pending,
        priorityId: 1,
        priority: ComplaintPriority.low,
        title: 'عطل أعمدة الإنارة',
        description: 'في الشارع الرئيسي',
        createdAt: DateTime(2026, 11, 24),
      ),
      Complaint(
        id: 102,
        userId: 11,
        categoryId: 2,
        categoryName: 'المياه',
        statusId: 3,
        status: ComplaintStatus.inProgress,
        priorityId: 3,
        priority: ComplaintPriority.high,
        title: 'كسر ماسورة مياه',
        description: 'قرب الدوار',
        createdAt: DateTime(2026, 11, 23),
      ),
      Complaint(
        id: 103,
        userId: 12,
        categoryId: 3,
        categoryName: 'النظافة',
        statusId: 4,
        status: ComplaintStatus.resolved,
        priorityId: 2,
        priority: ComplaintPriority.medium,
        title: 'تراكم مخلفات بناء',
        description: 'تم التنظيف',
        createdAt: DateTime(2026, 11, 22),
      ),
    ];

    setUp(() {
      fakeRepository = FakeComplaintRepository();
      bloc = AssignedComplaintsBloc(repository: fakeRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is AssignedComplaintsInitialState', () {
      expect(bloc.state, equals(const AssignedComplaintsInitialState()));
    });

    test(
      'emits [AssignedComplaintsLoadingState, AssignedComplaintsLoadedState] when fetch succeeds',
      () async {
        fakeRepository.assignedComplaintsResult = sampleAssignedComplaints;

        final expected = [
          const AssignedComplaintsLoadingState(),
          AssignedComplaintsLoadedState(
            complaints: sampleAssignedComplaints,
            filteredComplaints: sampleAssignedComplaints,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const LoadAssignedComplaintsEvent());
        await Future.delayed(const Duration(milliseconds: 50));

        final state = bloc.state as AssignedComplaintsLoadedState;
        expect(state.totalAssigned, equals(3));
        expect(state.pendingCount, equals(1));
        expect(state.inProgressCount, equals(1));
        expect(state.resolvedCount, equals(1));
      },
    );

    test(
      'emits [AssignedComplaintsLoadingState, AssignedComplaintsEmptyState] when assigned list is empty',
      () async {
        fakeRepository.assignedComplaintsResult = [];

        final expected = [
          const AssignedComplaintsLoadingState(),
          const AssignedComplaintsEmptyState(),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const LoadAssignedComplaintsEvent());
      },
    );

    test(
      'emits [AssignedComplaintsLoadingState, AssignedComplaintsErrorState] on NetworkFailure',
      () async {
        fakeRepository.assignedComplaintsFailure = const NetworkFailure(
          'تعذر الاتصال بالخادم.',
        );

        final expected = [
          const AssignedComplaintsLoadingState(),
          const AssignedComplaintsErrorState(
            'تعذر الاتصال بالخادم.',
            isNetworkError: true,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const LoadAssignedComplaintsEvent());
      },
    );

    test('filters assigned complaints by status correctly', () async {
      fakeRepository.assignedComplaintsResult = sampleAssignedComplaints;
      bloc.add(const LoadAssignedComplaintsEvent());
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(
        const FilterAssignedComplaintsByStatusEvent(ComplaintStatus.inProgress),
      );
      await Future.delayed(const Duration(milliseconds: 20));

      final state = bloc.state as AssignedComplaintsLoadedState;
      expect(state.filteredComplaints.length, equals(1));
      expect(state.filteredComplaints.first.id, equals(102));
      expect(state.selectedStatus, equals(ComplaintStatus.inProgress));

      // Reset filter
      bloc.add(const FilterAssignedComplaintsByStatusEvent(null));
      await Future.delayed(const Duration(milliseconds: 20));

      final resetState = bloc.state as AssignedComplaintsLoadedState;
      expect(resetState.filteredComplaints.length, equals(3));
      expect(resetState.selectedStatus, isNull);
    });

    test('filters assigned complaints by text search query', () async {
      fakeRepository.assignedComplaintsResult = sampleAssignedComplaints;
      bloc.add(const LoadAssignedComplaintsEvent());
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const SearchAssignedComplaintsEvent('ماسورة'));
      await Future.delayed(const Duration(milliseconds: 20));

      final state = bloc.state as AssignedComplaintsLoadedState;
      expect(state.filteredComplaints.length, equals(1));
      expect(state.filteredComplaints.first.title, contains('ماسورة'));
    });

    test('updates complaint status successfully and refreshes list', () async {
      fakeRepository.assignedComplaintsResult = sampleAssignedComplaints;
      bloc.add(const LoadAssignedComplaintsEvent());
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(
        const ChangeAssignedComplaintStatusEvent(
          complaintId: 101,
          status: ComplaintStatus.inProgress,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 80));

      expect(fakeRepository.updateStatusCallCount, equals(1));
      expect(fakeRepository.lastUpdatedStatusId, equals(3));
    });

    test(
      'handles 403 Forbidden with exact Arabic message when status update unauthorized',
      () async {
        fakeRepository.assignedComplaintsResult = sampleAssignedComplaints;
        bloc.add(const LoadAssignedComplaintsEvent());
        await Future.delayed(const Duration(milliseconds: 50));

        fakeRepository.updateStatusFailure = const ForbiddenFailure(
          'أنت لست مسنداً لهذه الشكوى حالياً أو تم نقلها.',
        );

        bloc.add(
          const ChangeAssignedComplaintStatusEvent(
            complaintId: 101,
            status: ComplaintStatus.resolved,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        expect(bloc.state, isA<AssignedComplaintsErrorState>());
        final state = bloc.state as AssignedComplaintsErrorState;
        expect(state.isForbidden, isTrue);
        expect(
          state.message,
          equals('أنت لست مسنداً لهذه الشكوى حالياً أو تم نقلها.'),
        );
      },
    );
  });
}
