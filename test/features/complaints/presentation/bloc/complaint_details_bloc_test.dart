import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/core/errors/failures.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_details.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_history_item.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_status.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/complaint_details_bloc.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/complaint_details_event.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/complaint_details_state.dart';
import 'fake_complaint_repository.dart';

void main() {
  group('ComplaintDetailsBloc Unit Tests', () {
    late FakeComplaintRepository fakeRepository;
    late ComplaintDetailsBloc bloc;

    final sampleComplaint = Complaint(
      id: 42,
      userId: 10,
      categoryId: 1,
      categoryName: 'الكهرباء',
      statusId: 1,
      status: ComplaintStatus.pending,
      priorityId: 2,
      priority: ComplaintPriority.medium,
      title: 'انقطاع تيار',
      description: 'المحول الرئيسي مفصول',
      createdAt: DateTime(2026, 11, 24),
    );

    setUp(() {
      fakeRepository = FakeComplaintRepository();
      bloc = ComplaintDetailsBloc(repository: fakeRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is ComplaintDetailsInitialState', () {
      expect(bloc.state, equals(const ComplaintDetailsInitialState()));
    });

    test(
      'emits [ComplaintDetailsLoadingState, ComplaintDetailsLoadedState] on successful details load',
      () async {
        final details = ComplaintDetails(
          complaint: sampleComplaint,
          history: [
            ComplaintHistoryItem(
              id: 1,
              complaintId: 42,
              action: 'Created',
              createdAt: DateTime(2026, 11, 24),
            ),
          ],
          primaryAttachmentUrl: 'https://host/img.jpg',
        );
        fakeRepository.getDetailsResult = details;

        final expected = [
          const ComplaintDetailsLoadingState(),
          ComplaintDetailsLoadedState(details: details),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const LoadComplaintDetailsEvent(42));
      },
    );

    test(
      'gracefully handles details when history and attachment are empty/missing',
      () async {
        final details = ComplaintDetails(
          complaint: sampleComplaint,
          history: const [],
          primaryAttachmentUrl: null,
        );
        fakeRepository.getDetailsResult = details;

        final expected = [
          const ComplaintDetailsLoadingState(),
          ComplaintDetailsLoadedState(details: details),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const LoadComplaintDetailsEvent(42));
        await Future.delayed(const Duration(milliseconds: 50));

        final state = bloc.state as ComplaintDetailsLoadedState;
        expect(state.details.history, isEmpty);
        expect(state.details.primaryAttachmentUrl, isNull);
      },
    );

    test(
      'emits [ComplaintDetailsLoadingState, ComplaintDetailsErrorState] on NotFoundFailure',
      () async {
        fakeRepository.getDetailsFailure = const NotFoundFailure(
          'الشكوى غير موجودة',
        );

        final expected = [
          const ComplaintDetailsLoadingState(),
          const ComplaintDetailsErrorState(
            'الشكوى غير موجودة',
            isNotFound: true,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const LoadComplaintDetailsEvent(999));
      },
    );
  });
}
