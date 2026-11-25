import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/core/errors/failures.dart';
import 'package:shakwa_app/core/network/attachment_upload_service.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_category.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_status.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/complaint_submission_bloc.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/complaint_submission_event.dart';
import 'package:shakwa_app/features/complaints/presentation/bloc/complaint_submission_state.dart';
import 'fake_complaint_repository.dart';

void main() {
  group('ComplaintSubmissionBloc Unit Tests', () {
    late FakeComplaintRepository fakeRepository;
    late ComplaintSubmissionBloc bloc;

    setUp(() {
      fakeRepository = FakeComplaintRepository();
      bloc = ComplaintSubmissionBloc(repository: fakeRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is ComplaintSubmissionInitialState', () {
      expect(bloc.state, equals(const ComplaintSubmissionInitialState()));
    });

    test('loads categories successfully and updates initial state', () async {
      fakeRepository.categoriesResult = [
        const ComplaintCategory(id: 1, name: 'الكهرباء'),
        const ComplaintCategory(id: 2, name: 'المياه'),
      ];

      final expected = [
        const ComplaintSubmissionInitialState(isLoadingCategories: true),
        const ComplaintSubmissionInitialState(
          isLoadingCategories: false,
          categories: [
            ComplaintCategory(id: 1, name: 'الكهرباء'),
            ComplaintCategory(id: 2, name: 'المياه'),
          ],
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const LoadSubmissionCategoriesEvent());
    });

    test('submits complaint successfully without attachments', () async {
      final sampleComplaint = Complaint(
        id: 105,
        userId: 10,
        categoryId: 1,
        statusId: 1,
        status: ComplaintStatus.pending,
        priorityId: 2,
        priority: ComplaintPriority.medium,
        title: 'بلاغ جديد',
        description: 'تفاصيل البلاغ',
        createdAt: DateTime.now(),
      );
      fakeRepository.createResult = sampleComplaint;

      final expected = [
        const ComplaintSubmittingState(
          progressMessage: 'جاري تسجيل البلاغ في النظام...',
        ),
        isA<ComplaintSubmissionSuccessState>().having(
          (s) => s.complaint.id,
          'complaint.id',
          equals(105),
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(
        const SubmitComplaintEvent(
          title: 'بلاغ جديد',
          description: 'تفاصيل البلاغ',
          categoryId: 1,
          priorityId: 2,
        ),
      );
    });

    test('submits complaint and uploads attachments sequentially', () async {
      final sampleComplaint = Complaint(
        id: 106,
        userId: 10,
        categoryId: 1,
        statusId: 1,
        status: ComplaintStatus.pending,
        priorityId: 1,
        priority: ComplaintPriority.low,
        title: 'بلاغ بمرفقات',
        description: 'تفاصيل',
        createdAt: DateTime.now(),
      );
      fakeRepository.createResult = sampleComplaint;

      final expected = [
        const ComplaintSubmittingState(
          progressMessage: 'جاري تسجيل البلاغ في النظام...',
        ),
        isA<ComplaintSubmissionSuccessState>().having(
          (s) => s.hasPartialAttachmentFailures,
          'hasPartialAttachmentFailures',
          isFalse,
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(
        SubmitComplaintEvent(
          title: 'بلاغ بمرفقات',
          description: 'تفاصيل',
          categoryId: 1,
          priorityId: 1,
          attachments: [
            AttachmentUploadItem(
              id: '1',
              fileName: 'p1.jpg',
              fileBytes: Uint8List(10),
            ),
            AttachmentUploadItem(
              id: '2',
              fileName: 'p2.jpg',
              fileBytes: Uint8List(20),
            ),
          ],
        ),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      expect(fakeRepository.uploadCallCount, equals(2));
    });

    test(
      'handles partial attachment failure while preserving created complaint ID',
      () async {
        fakeRepository.createResult = Complaint(
          id: 107,
          userId: 10,
          categoryId: 1,
          statusId: 1,
          status: ComplaintStatus.pending,
          priorityId: 1,
          priority: ComplaintPriority.low,
          title: 'بلاغ مرفق فاشل',
          description: 'تفاصيل',
          createdAt: DateTime.now(),
        );
        fakeRepository.uploadFailure = const UploadFailure('فشل رفع الملف');

        final expected = [
          const ComplaintSubmittingState(
            progressMessage: 'جاري تسجيل البلاغ في النظام...',
          ),
          isA<ComplaintSubmissionSuccessState>()
              .having((s) => s.complaint.id, 'complaint.id', equals(107))
              .having(
                (s) => s.hasPartialAttachmentFailures,
                'hasPartialAttachmentFailures',
                isTrue,
              ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(
          SubmitComplaintEvent(
            title: 'بلاغ مرفق فاشل',
            description: 'تفاصيل',
            categoryId: 1,
            priorityId: 1,
            attachments: [
              AttachmentUploadItem(
                id: '1',
                fileName: 'f.jpg',
                fileBytes: Uint8List(10),
              ),
            ],
          ),
        );
      },
    );

    test(
      'retries failed attachments only without re-creating complaint',
      () async {
        fakeRepository.getByIdResult = Complaint(
          id: 107,
          userId: 10,
          categoryId: 1,
          statusId: 1,
          status: ComplaintStatus.pending,
          priorityId: 1,
          priority: ComplaintPriority.low,
          title: 'بلاغ تم رفعه',
          description: 'تفاصيل',
          createdAt: DateTime.now(),
        );

        final expected = [
          const ComplaintSubmittingState(
            progressMessage: 'جاري إعادة محاولة رفع المرفقات...',
          ),
          isA<ComplaintSubmissionSuccessState>().having(
            (s) => s.hasPartialAttachmentFailures,
            'hasPartialAttachmentFailures',
            isFalse,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(
          RetryFailedAttachmentsEvent(
            complaintId: 107,
            failedAttachments: [
              AttachmentUploadItem(
                id: '1',
                fileName: 'retry.jpg',
                fileBytes: Uint8List(10),
              ),
            ],
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));
        expect(fakeRepository.uploadCallCount, equals(1));
      },
    );

    test('updates complaint successfully', () async {
      fakeRepository.updateResult = Complaint(
        id: 50,
        userId: 10,
        categoryId: 1,
        statusId: 1,
        status: ComplaintStatus.pending,
        priorityId: 1,
        priority: ComplaintPriority.low,
        title: 'عنوان معدل',
        description: 'تفاصيل معدلة',
        createdAt: DateTime.now(),
      );

      final expected = [
        const ComplaintSubmittingState(
          progressMessage: 'جاري حفظ التعديلات...',
        ),
        isA<ComplaintSubmissionSuccessState>().having(
          (s) => s.complaint.title,
          'complaint.title',
          equals('عنوان معدل'),
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(
        const UpdateComplaintEvent(
          id: 50,
          title: 'عنوان معدل',
          description: 'تفاصيل معدلة',
          categoryId: 1,
          priorityId: 1,
        ),
      );
    });

    test(
      'emits ComplaintSubmissionFailureState on conflict when complaint is closed',
      () async {
        fakeRepository.updateFailure = const ConflictFailure(
          'Complaint is already closed.',
        );

        final expected = [
          const ComplaintSubmittingState(
            progressMessage: 'جاري حفظ التعديلات...',
          ),
          const ComplaintSubmissionFailureState('Complaint is already closed.'),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(
          const UpdateComplaintEvent(
            id: 50,
            title: 'تعديل',
            description: 'تفاصيل',
            categoryId: 1,
            priorityId: 1,
          ),
        );
      },
    );
  });
}
