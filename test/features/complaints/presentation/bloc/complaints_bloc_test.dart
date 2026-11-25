import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/core/errors/failures.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_status.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/complaints_bloc.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/complaints_event.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/complaints_state.dart';
import 'fake_complaint_repository.dart';

void main() {
  group('ComplaintsBloc Unit Tests', () {
    late FakeComplaintRepository fakeRepository;
    late ComplaintsBloc bloc;

    final sampleComplaints = [
      Complaint(
        id: 1,
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
        id: 2,
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
        id: 3,
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
      bloc = ComplaintsBloc(repository: fakeRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is ComplaintsInitialState', () {
      expect(bloc.state, equals(const ComplaintsInitialState()));
    });

    test(
      'emits [ComplaintsLoadingState, ComplaintsLoadedState] when complaints fetch succeeds',
      () async {
        fakeRepository.myComplaintsResult = sampleComplaints;

        final expected = [
          const ComplaintsLoadingState(),
          ComplaintsLoadedState(
            complaints: sampleComplaints,
            filteredComplaints: sampleComplaints,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const LoadMyComplaintsEvent());
        await Future.delayed(const Duration(milliseconds: 50));

        final state = bloc.state as ComplaintsLoadedState;
        expect(state.totalCount, equals(3));
        expect(state.pendingCount, equals(1));
        expect(state.inProgressCount, equals(1));
        expect(state.resolvedCount, equals(1));
        expect(state.closedCount, equals(0));
      },
    );

    test(
      'emits [ComplaintsLoadingState, ComplaintsEmptyState] when complaint list is empty',
      () async {
        fakeRepository.myComplaintsResult = [];

        final expected = [
          const ComplaintsLoadingState(),
          const ComplaintsEmptyState(),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const LoadMyComplaintsEvent());
      },
    );

    test(
      'emits [ComplaintsLoadingState, ComplaintsErrorState] when repository returns NetworkFailure',
      () async {
        fakeRepository.myComplaintsFailure = const NetworkFailure(
          'تعذر الاتصال بالخادم.',
        );

        final expected = [
          const ComplaintsLoadingState(),
          const ComplaintsErrorState(
            'تعذر الاتصال بالخادم.',
            isNetworkError: true,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const LoadMyComplaintsEvent());
      },
    );

    test(
      'pull-to-refresh does not emit loading state before loaded state',
      () async {
        fakeRepository.myComplaintsResult = sampleComplaints;

        final expected = [
          ComplaintsLoadedState(
            complaints: sampleComplaints,
            filteredComplaints: sampleComplaints,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const LoadMyComplaintsEvent(isRefresh: true));
      },
    );

    test(
      'filters complaints correctly when FilterComplaintsByStatusEvent is dispatched',
      () async {
        fakeRepository.myComplaintsResult = sampleComplaints;

        bloc.add(const LoadMyComplaintsEvent());
        await Future.delayed(const Duration(milliseconds: 50));

        final expected = [
          ComplaintsLoadedState(
            complaints: sampleComplaints,
            filteredComplaints: [sampleComplaints[1]],
            selectedStatus: ComplaintStatus.inProgress,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(
          const FilterComplaintsByStatusEvent(ComplaintStatus.inProgress),
        );
      },
    );

    test('searches complaints correctly across title and category', () async {
      fakeRepository.myComplaintsResult = sampleComplaints;

      bloc.add(const LoadMyComplaintsEvent());
      await Future.delayed(const Duration(milliseconds: 50));

      final expected = [
        ComplaintsLoadedState(
          complaints: sampleComplaints,
          filteredComplaints: [sampleComplaints[1]],
          searchQuery: 'تسرب',
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const SearchComplaintsEvent('تسرب'));
    });
  });
}
