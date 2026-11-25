import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/core/errors/failures.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_comment.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/complaint_comments_bloc.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/complaint_comments_event.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/complaint_comments_state.dart';
import 'fake_complaint_repository.dart';

void main() {
  group('ComplaintCommentsBloc Unit Tests', () {
    late FakeComplaintRepository fakeRepository;
    late ComplaintCommentsBloc bloc;

    final sampleComments = [
      ComplaintComment(
        id: 1,
        complaintId: 50,
        userId: 2,
        userName: 'المشرف الميداني',
        comment: 'تم فحص الموقع والبدء بأعمال المعالجة',
        createdAt: DateTime(2026, 11, 24, 10, 0),
      ),
      ComplaintComment(
        id: 2,
        complaintId: 50,
        userId: 3,
        userName: 'مهندس الكهرباء',
        comment: 'تم إصلاح الكابل التالف',
        createdAt: DateTime(2026, 11, 24, 12, 30),
      ),
    ];

    setUp(() {
      fakeRepository = FakeComplaintRepository();
      bloc = ComplaintCommentsBloc(repository: fakeRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is ComplaintCommentsInitialState', () {
      expect(bloc.state, equals(const ComplaintCommentsInitialState()));
    });

    test(
      'emits [ComplaintCommentsLoadingState, ComplaintCommentsLoadedState] on load success',
      () async {
        fakeRepository.commentsResult = sampleComments;

        final expected = [
          const ComplaintCommentsLoadingState(),
          ComplaintCommentsLoadedState(comments: sampleComments),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const LoadComplaintCommentsEvent(50));
        await Future.delayed(const Duration(milliseconds: 50));

        final state = bloc.state as ComplaintCommentsLoadedState;
        expect(state.comments.length, equals(2));
        expect(state.comments.first.comment, contains('تم فحص الموقع'));
      },
    );

    test(
      'emits [ComplaintCommentsLoadingState, ComplaintCommentsErrorState] on load failure',
      () async {
        fakeRepository.commentsFailure = const ServerFailure(
          'حدث خطأ في تحميل الملاحظات',
        );

        final expected = [
          const ComplaintCommentsLoadingState(),
          const ComplaintCommentsErrorState('حدث خطأ في تحميل الملاحظات'),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const LoadComplaintCommentsEvent(50));
      },
    );

    test(
      'rejects empty comment with validation error without calling repository',
      () async {
        bloc.add(
          const AddComplaintCommentEvent(complaintId: 50, comment: '   '),
        );
        await Future.delayed(const Duration(milliseconds: 20));

        expect(bloc.state, isA<ComplaintCommentsErrorState>());
        final state = bloc.state as ComplaintCommentsErrorState;
        expect(state.isSubmissionError, isTrue);
        expect(state.message, contains('نص الملاحظة مطلوب'));
        expect(fakeRepository.addCommentCallCount, equals(0));
      },
    );

    test(
      'submits valid comment, emits submitting state and appends new comment',
      () async {
        fakeRepository.commentsResult = sampleComments;
        bloc.add(const LoadComplaintCommentsEvent(50));
        await Future.delayed(const Duration(milliseconds: 50));

        fakeRepository.addCommentResult = ComplaintComment(
          id: 3,
          complaintId: 50,
          userId: 2,
          userName: 'المشرف الميداني',
          comment: 'ملاحظة جديدة',
          createdAt: DateTime.now(),
        );

        bloc.add(
          const AddComplaintCommentEvent(
            complaintId: 50,
            comment: 'ملاحظة جديدة',
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        expect(fakeRepository.addCommentCallCount, equals(1));
        final state = bloc.state as ComplaintCommentsLoadedState;
        expect(state.comments.length, equals(3));
        expect(state.comments.last.comment, equals('ملاحظة جديدة'));
        expect(state.submissionMessage, equals('تم إضافة الملاحظة بنجاح.'));
      },
    );

    test(
      'emits ComplaintCommentsErrorState with isSubmissionError when addComment fails',
      () async {
        fakeRepository.commentsResult = sampleComments;
        bloc.add(const LoadComplaintCommentsEvent(50));
        await Future.delayed(const Duration(milliseconds: 50));

        fakeRepository.addCommentFailure = const NetworkFailure(
          'فشل الاتصال بالخادم.',
        );

        bloc.add(
          const AddComplaintCommentEvent(
            complaintId: 50,
            comment: 'ملاحظة تفشل',
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        expect(bloc.state, isA<ComplaintCommentsErrorState>());
        final state = bloc.state as ComplaintCommentsErrorState;
        expect(state.isSubmissionError, isTrue);
        expect(state.message, equals('فشل الاتصال بالخادم.'));
        // Verifies original comments are retained in error state
        expect(state.currentComments.length, equals(2));
      },
    );
  });
}
