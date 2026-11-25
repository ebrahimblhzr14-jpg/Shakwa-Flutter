import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/core/errors/exceptions.dart';
import 'package:shakwa_app/core/errors/failures.dart';
import 'package:shakwa_app/core/network/attachment_upload_service.dart';
import 'package:shakwa_app/core/security/secure_token_storage.dart';
import 'package:shakwa_app/core/security/token_manager.dart';
import 'package:shakwa_app/core/security/token_record.dart';
import 'package:shakwa_app/features/complaints/data/datasources/complaint_remote_data_source.dart';
import 'package:shakwa_app/features/complaints/data/models/complaint_category_model.dart';
import 'package:shakwa_app/features/complaints/data/models/complaint_comment_model.dart';
import 'package:shakwa_app/features/complaints/data/models/complaint_dto.dart';
import 'package:shakwa_app/features/complaints/data/models/complaint_history_model.dart';
import 'package:shakwa_app/features/complaints/data/models/create_complaint_request_dto.dart';
import 'package:shakwa_app/features/complaints/data/models/create_assignment_dto.dart';
import 'package:shakwa_app/features/complaints/data/models/dashboard_summary_model.dart';
import 'package:shakwa_app/features/complaints/data/repositories/complaint_repository_impl.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_status.dart';

class MockComplaintRemoteDataSource implements IComplaintRemoteDataSource {
  List<ComplaintDto>? myComplaintsResult;
  Exception? myComplaintsException;

  ComplaintDto? getByIdResult;
  Exception? getByIdException;

  ComplaintDto? createResult;
  Exception? createException;

  ComplaintDto? updateResult;
  Exception? updateException;

  List<ComplaintCategoryModel>? categoriesResult;
  Exception? categoriesException;

  List<ComplaintHistoryModel>? historyResult;
  Exception? historyException;

  String? imagePathResult;
  Exception? imagePathException;

  AttachmentUploadItem? uploadResult;
  Exception? uploadException;
  int uploadCallCount = 0;

  List<ComplaintDto>? assignedComplaintsResult;
  Exception? assignedComplaintsException;

  Exception? updateStatusException;
  int updateStatusCallCount = 0;
  int? lastUpdatedStatusId;

  List<ComplaintCommentModel>? commentsResult;
  Exception? commentsException;

  ComplaintCommentModel? addCommentResult;
  Exception? addCommentException;
  int addCommentCallCount = 0;

  @override
  Future<List<ComplaintDto>> getMyComplaints(int userId) async {
    if (myComplaintsException != null) throw myComplaintsException!;
    return myComplaintsResult ?? [];
  }

  @override
  Future<ComplaintDto> getComplaintById(int id) async {
    if (getByIdException != null) throw getByIdException!;
    return getByIdResult ??
        ComplaintDto(
          id: id,
          userId: 10,
          categoryId: 1,
          statusId: 1,
          priorityId: 1,
          title: 'شكوى تجريبية',
          description: 'تفاصيل',
          createdAt: DateTime.now(),
        );
  }

  @override
  Future<ComplaintDto> createComplaint(
    CreateComplaintRequestDto request,
  ) async {
    if (createException != null) throw createException!;
    return createResult ??
        ComplaintDto(
          id: 100,
          userId: 10,
          categoryId: request.categoryId,
          statusId: 1,
          priorityId: request.priorityId,
          title: request.title,
          description: request.description,
          createdAt: DateTime.now(),
        );
  }

  @override
  Future<ComplaintDto> updateComplaint(
    int id,
    CreateComplaintRequestDto request,
  ) async {
    if (updateException != null) throw updateException!;
    return updateResult ??
        ComplaintDto(
          id: id,
          userId: 10,
          categoryId: request.categoryId,
          statusId: 1,
          priorityId: request.priorityId,
          title: request.title,
          description: request.description,
          createdAt: DateTime.now(),
        );
  }

  @override
  Future<List<ComplaintCategoryModel>> getCategories() async {
    if (categoriesException != null) throw categoriesException!;
    return categoriesResult ?? [];
  }

  @override
  Future<List<ComplaintHistoryModel>> getComplaintHistory(
    int complaintId,
  ) async {
    if (historyException != null) throw historyException!;
    return historyResult ?? [];
  }

  @override
  Future<String> getImagePath(int complaintId) async {
    if (imagePathException != null) throw imagePathException!;
    return imagePathResult ?? '';
  }

  @override
  Future<AttachmentUploadItem> uploadAttachment(
    int complaintId,
    AttachmentUploadItem item,
  ) async {
    uploadCallCount++;
    if (uploadException != null) throw uploadException!;
    item.status = AttachmentUploadStatus.uploaded;
    return uploadResult ?? item;
  }

  @override
  Future<List<ComplaintDto>> getAssignedComplaints() async {
    if (assignedComplaintsException != null) throw assignedComplaintsException!;
    return assignedComplaintsResult ?? [];
  }

  @override
  Future<void> updateComplaintStatus(int id, int statusId) async {
    updateStatusCallCount++;
    lastUpdatedStatusId = statusId;
    if (updateStatusException != null) throw updateStatusException!;
  }

  @override
  Future<List<ComplaintCommentModel>> getComplaintComments(
    int complaintId,
  ) async {
    if (commentsException != null) throw commentsException!;
    return commentsResult ?? [];
  }

  @override
  Future<ComplaintCommentModel> addComplaintComment(
    int complaintId,
    String comment,
  ) async {
    addCommentCallCount++;
    if (addCommentException != null) throw addCommentException!;
    return addCommentResult ??
        ComplaintCommentModel(
          id: 99,
          complaintId: complaintId,
          userId: 5,
          userName: 'المشرف',
          comment: comment,
          createdAt: DateTime.now(),
        );
  }

  // SuperAdmin Operations
  List<ComplaintDto>? allComplaintsResult;
  Exception? allComplaintsException;

  Exception? assignComplaintException;
  int assignComplaintCallCount = 0;

  DashboardSummaryModel? dashboardSummaryResult;
  Exception? dashboardSummaryException;

  List<ComplaintHistoryModel>? globalHistoryResult;
  Exception? globalHistoryException;

  @override
  Future<List<ComplaintDto>> getAllComplaints() async {
    if (allComplaintsException != null) throw allComplaintsException!;
    return allComplaintsResult ?? [];
  }

  @override
  Future<void> assignComplaint(CreateAssignmentDto dto) async {
    assignComplaintCallCount++;
    if (assignComplaintException != null) throw assignComplaintException!;
  }

  @override
  Future<DashboardSummaryModel> getDashboardSummary() async {
    if (dashboardSummaryException != null) throw dashboardSummaryException!;
    return dashboardSummaryResult ??
        const DashboardSummaryModel(
          totalComplaints: 10,
          pendingComplaints: 3,
          inProgressComplaints: 4,
          resolvedComplaints: 2,
          closedComplaints: 1,
        );
  }

  @override
  Future<List<ComplaintHistoryModel>> getGlobalComplaintHistory() async {
    if (globalHistoryException != null) throw globalHistoryException!;
    return globalHistoryResult ?? [];
  }
}

class _LocalFakeSecureStorage implements ISecureTokenStorage {
  TokenRecord? record;

  @override
  bool get isVolatileSession => false;

  @override
  Future<void> saveTokenRecord(TokenRecord r) async => record = r;

  @override
  Future<TokenRecord?> getTokenRecord() async => record;

  @override
  Future<void> clearTokenRecord() async => record = null;
}

String _buildJwt({required int userId, required String role}) {
  final header = base64Url
      .encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})))
      .replaceAll('=', '');
  final payload = base64Url
      .encode(
        utf8.encode(
          jsonEncode({
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier':
                userId.toString(),
            'http://schemas.microsoft.com/ws/2008/06/identity/claims/role':
                role,
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name':
                'مواطن تجريبي',
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress':
                'citizen@test.local',
            'exp':
                DateTime.now()
                    .add(const Duration(hours: 1))
                    .millisecondsSinceEpoch ~/
                1000,
          }),
        ),
      )
      .replaceAll('=', '');
  return '$header.$payload.signature';
}

void main() {
  group('ComplaintRepositoryImpl', () {
    late MockComplaintRemoteDataSource mockRemoteDataSource;
    late _LocalFakeSecureStorage fakeStorage;
    late TokenManager tokenManager;
    late ComplaintRepositoryImpl repository;

    setUp(() async {
      mockRemoteDataSource = MockComplaintRemoteDataSource();
      fakeStorage = _LocalFakeSecureStorage();
      tokenManager = TokenManager(fakeStorage);

      // Seed valid authenticated session (UserId = 15, Role = User)
      final validJwt = _buildJwt(userId: 15, role: 'User');
      await fakeStorage.saveTokenRecord(
        TokenRecord(
          accessToken: validJwt,
          refreshToken: 'refresh-token',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          createdAt: DateTime.now(),
        ),
      );
      await tokenManager.initialize();

      repository = ComplaintRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        tokenManager: tokenManager,
      );
    });

    group('getMyComplaints', () {
      test('fetches complaints using implicit session userId', () async {
        mockRemoteDataSource.myComplaintsResult = [
          ComplaintDto(
            id: 1,
            userId: 15,
            categoryId: 1,
            statusId: 1,
            priorityId: 2,
            title: 'شكوى 1',
            description: 'تفاصيل 1',
            createdAt: DateTime.now(),
          ),
        ];

        final result = await repository.getMyComplaints();
        expect(result.isRight(), isTrue);
        result.fold((l) => fail('Should succeed'), (complaints) {
          expect(complaints.length, equals(1));
          expect(complaints.first.userId, equals(15));
          expect(complaints.first.title, equals('شكوى 1'));
        });
      });

      test('fetches complaints using explicit userId', () async {
        mockRemoteDataSource.myComplaintsResult = [
          ComplaintDto(
            id: 2,
            userId: 99,
            categoryId: 1,
            statusId: 1,
            priorityId: 1,
            title: 'شكوى مستخدم آخر',
            description: 'تفاصيل',
            createdAt: DateTime.now(),
          ),
        ];

        final result = await repository.getMyComplaints(userId: 99);
        expect(result.isRight(), isTrue);
        result.fold((l) => fail('Should succeed'), (complaints) {
          expect(complaints.length, equals(1));
          expect(complaints.first.userId, equals(99));
        });
      });

      test(
        'returns Left(AuthFailure) if unauthenticated and no explicit userId provided',
        () async {
          await tokenManager.invalidateSession();

          final result = await repository.getMyComplaints();
          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure, isA<AuthFailure>()),
            (_) => fail('Should fail'),
          );
        },
      );

      test('maps UnauthorizedException to UnauthorizedFailure', () async {
        mockRemoteDataSource.myComplaintsException =
            const UnauthorizedException('غير مصرح');

        final result = await repository.getMyComplaints();
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<UnauthorizedFailure>()),
          (_) => fail('Should fail'),
        );
      });

      test('maps NetworkException to NetworkFailure', () async {
        mockRemoteDataSource.myComplaintsException = const NetworkException(
          'تعذر الاتصال',
        );

        final result = await repository.getMyComplaints();
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Should fail'),
        );
      });

      test('maps ServerException to ServerFailure', () async {
        mockRemoteDataSource.myComplaintsException = const ServerException(
          'خطأ خادم',
        );

        final result = await repository.getMyComplaints();
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Should fail'),
        );
      });
    });

    group('getComplaintById', () {
      test('rejects non-positive ID with ValidationFailure', () async {
        final result = await repository.getComplaintById(0);
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Should fail'),
        );
      });

      test('returns Complaint entity on success', () async {
        mockRemoteDataSource.getByIdResult = ComplaintDto(
          id: 55,
          userId: 15,
          categoryId: 1,
          statusId: 3,
          priorityId: 2,
          title: 'شكوى قائمة',
          description: 'تفاصيل',
          createdAt: DateTime.now(),
        );

        final result = await repository.getComplaintById(55);
        expect(result.isRight(), isTrue);
        result.fold((l) => fail('Should succeed'), (complaint) {
          expect(complaint.id, equals(55));
          expect(complaint.status, equals(ComplaintStatus.inProgress));
        });
      });

      test('maps NotFoundException to NotFoundFailure', () async {
        mockRemoteDataSource.getByIdException = const NotFoundException(
          'غير موجود',
        );

        final result = await repository.getComplaintById(55);
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<NotFoundFailure>()),
          (_) => fail('Should fail'),
        );
      });
    });

    group('getComplaintDetails', () {
      test(
        'aggregates complaint, history, and primary attachment URL',
        () async {
          mockRemoteDataSource.getByIdResult = ComplaintDto(
            id: 12,
            userId: 15,
            categoryId: 1,
            statusId: 1,
            priorityId: 1,
            title: 'شكوى مفصلة',
            description: 'شرح تفصيلي',
            createdAt: DateTime.now(),
          );
          mockRemoteDataSource.historyResult = [
            ComplaintHistoryModel(
              id: 1,
              complaintId: 12,
              action: 'Created',
              createdAt: DateTime.now(),
            ),
          ];
          mockRemoteDataSource.imagePathResult = 'https://host/Images/file.jpg';

          final result = await repository.getComplaintDetails(12);
          expect(result.isRight(), isTrue);
          result.fold((l) => fail('Should succeed'), (details) {
            expect(details.complaint.id, equals(12));
            expect(details.history.length, equals(1));
            expect(
              details.primaryAttachmentUrl,
              equals('https://host/Images/file.jpg'),
            );
            expect(details.attachments.length, equals(1));
          });
        },
      );

      test(
        'gracefully continues if history or attachment fails with 404',
        () async {
          mockRemoteDataSource.getByIdResult = ComplaintDto(
            id: 12,
            userId: 15,
            categoryId: 1,
            statusId: 1,
            priorityId: 1,
            title: 'شكوى مفصلة',
            description: 'شرح',
            createdAt: DateTime.now(),
          );
          mockRemoteDataSource.historyException = const NotFoundException(
            'No history',
          );
          mockRemoteDataSource.imagePathException = const NotFoundException(
            'No image',
          );

          final result = await repository.getComplaintDetails(12);
          expect(result.isRight(), isTrue);
          result.fold((l) => fail('Should succeed'), (details) {
            expect(details.complaint.id, equals(12));
            expect(details.history, isEmpty);
            expect(details.primaryAttachmentUrl, isNull);
          });
        },
      );
    });

    group('createComplaint', () {
      test('rejects empty title with ValidationFailure', () async {
        final result = await repository.createComplaint(
          title: '   ',
          description: 'تفاصيل',
          categoryId: 1,
          priorityId: 1,
        );
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Should fail'),
        );
      });

      test('rejects invalid categoryId <= 0 with ValidationFailure', () async {
        final result = await repository.createComplaint(
          title: 'عنوان',
          description: 'تفاصيل',
          categoryId: 0,
          priorityId: 1,
        );
        expect(result.isLeft(), isTrue);
      });

      test('creates complaint and sequentially uploads attachments', () async {
        mockRemoteDataSource.createResult = ComplaintDto(
          id: 77,
          userId: 15,
          categoryId: 1,
          statusId: 1,
          priorityId: 2,
          title: 'بلاغ جديد',
          description: 'وصف البلاغ',
          createdAt: DateTime.now(),
        );

        final attachments = [
          AttachmentUploadItem(
            id: '1',
            fileName: 'f1.jpg',
            fileBytes: Uint8List(10),
          ),
          AttachmentUploadItem(
            id: '2',
            fileName: 'f2.jpg',
            fileBytes: Uint8List(20),
          ),
        ];

        final result = await repository.createComplaint(
          title: 'بلاغ جديد',
          description: 'وصف البلاغ',
          categoryId: 1,
          priorityId: 2,
          attachments: attachments,
        );

        expect(result.isRight(), isTrue);
        expect(mockRemoteDataSource.uploadCallCount, equals(2));
      });

      test('maps ConflictException to ConflictFailure', () async {
        mockRemoteDataSource.createException = const ConflictException(
          'تعارض في البيانات',
        );

        final result = await repository.createComplaint(
          title: 'بلاغ جديد',
          description: 'وصف البلاغ',
          categoryId: 1,
          priorityId: 2,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ConflictFailure>()),
          (_) => fail('Should fail'),
        );
      });
    });

    group('updateComplaint', () {
      test('rejects non-positive ID with ValidationFailure', () async {
        final result = await repository.updateComplaint(
          id: 0,
          title: 'عنوان',
          description: 'تفاصيل',
          categoryId: 1,
          priorityId: 1,
        );
        expect(result.isLeft(), isTrue);
      });

      test('updates complaint successfully', () async {
        mockRemoteDataSource.updateResult = ComplaintDto(
          id: 50,
          userId: 15,
          categoryId: 1,
          statusId: 1,
          priorityId: 1,
          title: 'عنوان محدث',
          description: 'تفاصيل محدثة',
          createdAt: DateTime.now(),
        );

        final result = await repository.updateComplaint(
          id: 50,
          title: 'عنوان محدث',
          description: 'تفاصيل محدثة',
          categoryId: 1,
          priorityId: 1,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (l) => fail('Should succeed'),
          (complaint) => expect(complaint.title, equals('عنوان محدث')),
        );
      });

      test(
        'maps ConflictException to ConflictFailure (closed complaint update guard)',
        () async {
          mockRemoteDataSource.updateException = const ConflictException(
            'Complaint is already closed.',
          );

          final result = await repository.updateComplaint(
            id: 50,
            title: 'تعديل',
            description: 'تفاصيل',
            categoryId: 1,
            priorityId: 1,
          );

          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure, isA<ConflictFailure>()),
            (_) => fail('Should fail'),
          );
        },
      );
    });

    group('getCategories & getComplaintHistory & image', () {
      test('getCategories returns domain entities on success', () async {
        mockRemoteDataSource.categoriesResult = [
          const ComplaintCategoryModel(id: 1, name: 'كهرباء'),
          const ComplaintCategoryModel(id: 2, name: 'مياه'),
        ];

        final result = await repository.getCategories();
        expect(result.isRight(), isTrue);
        result.fold(
          (l) => fail('Should succeed'),
          (cats) => expect(cats.length, equals(2)),
        );
      });

      test(
        'getComplaintHistory returns domain history items on success',
        () async {
          mockRemoteDataSource.historyResult = [
            ComplaintHistoryModel(
              id: 1,
              complaintId: 10,
              action: 'StatusChanged',
              createdAt: DateTime.now(),
            ),
          ];

          final result = await repository.getComplaintHistory(10);
          expect(result.isRight(), isTrue);
          result.fold(
            (l) => fail('Should succeed'),
            (history) => expect(history.length, equals(1)),
          );
        },
      );

      test('getComplaintImageUrl returns image url on success', () async {
        mockRemoteDataSource.imagePathResult = 'https://host/img.jpg';

        final result = await repository.getComplaintImageUrl(10);
        expect(result.isRight(), isTrue);
        result.fold(
          (l) => fail('Should succeed'),
          (url) => expect(url, equals('https://host/img.jpg')),
        );
      });

      test('uploadAttachment returns uploaded item on success', () async {
        final item = AttachmentUploadItem(
          id: '1',
          fileName: 'photo.jpg',
          fileBytes: Uint8List(10),
        );

        final result = await repository.uploadAttachment(
          complaintId: 10,
          item: item,
        );
        expect(result.isRight(), isTrue);
        result.fold(
          (l) => fail('Should succeed'),
          (uploaded) => expect(uploaded.isSuccessful, isTrue),
        );
      });
    });

    group('Phase 2.4 Employee Repository Methods', () {
      test(
        'getAssignedComplaints returns complaints mapped to domain entities',
        () async {
          mockRemoteDataSource.assignedComplaintsResult = [
            ComplaintDto(
              id: 201,
              userId: 15,
              categoryId: 1,
              statusId: 3,
              priorityId: 2,
              title: 'شكوى مسندة',
              description: 'تفاصيل مسندة للمشرف',
              createdAt: DateTime.now(),
            ),
          ];

          final result = await repository.getAssignedComplaints();
          expect(result.isRight(), isTrue);
          result.fold((l) => fail('Expected Right'), (complaints) {
            expect(complaints.length, equals(1));
            expect(complaints.first.id, equals(201));
            expect(complaints.first.status, equals(ComplaintStatus.inProgress));
          });
        },
      );

      test(
        'getAssignedComplaints returns ServerFailure on ServerException',
        () async {
          mockRemoteDataSource.assignedComplaintsException =
              const ServerException('خطأ في الخادم');

          final result = await repository.getAssignedComplaints();
          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure, isA<ServerFailure>()),
            (_) => fail('Expected Left'),
          );
        },
      );

      test('updateComplaintStatus succeeds with Right(null)', () async {
        final result = await repository.updateComplaintStatus(
          id: 201,
          statusId: 4,
        );
        expect(result.isRight(), isTrue);
        expect(mockRemoteDataSource.updateStatusCallCount, equals(1));
        expect(mockRemoteDataSource.lastUpdatedStatusId, equals(4));
      });

      test(
        'updateComplaintStatus maps ForbiddenException to ForbiddenFailure with specific Arabic message',
        () async {
          mockRemoteDataSource.updateStatusException = const ForbiddenException(
            'You are not actively assigned to this complaint.',
          );

          final result = await repository.updateComplaintStatus(
            id: 201,
            statusId: 4,
          );
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<ForbiddenFailure>());
            expect(
              failure.message,
              equals('أنت لست مسنداً لهذه الشكوى حالياً أو تم نقلها.'),
            );
          }, (_) => fail('Expected Left'));
        },
      );

      test(
        'updateComplaintStatus maps ConflictException to ConflictFailure',
        () async {
          mockRemoteDataSource.updateStatusException = const ConflictException(
            'Complaint is already closed and cannot be updated.',
          );

          final result = await repository.updateComplaintStatus(
            id: 201,
            statusId: 4,
          );
          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure, isA<ConflictFailure>()),
            (_) => fail('Expected Left'),
          );
        },
      );

      test(
        'getComplaintComments returns comments mapped to entities',
        () async {
          mockRemoteDataSource.commentsResult = [
            ComplaintCommentModel(
              id: 1,
              complaintId: 201,
              userId: 5,
              userName: 'المشرف الميداني',
              comment: 'جاري فحص الموقع',
              createdAt: DateTime.now(),
            ),
          ];

          final result = await repository.getComplaintComments(201);
          expect(result.isRight(), isTrue);
          result.fold((l) => fail('Expected Right'), (comments) {
            expect(comments.length, equals(1));
            expect(comments.first.comment, equals('جاري فحص الموقع'));
            expect(comments.first.userName, equals('المشرف الميداني'));
          });
        },
      );

      test('addComplaintComment creates and returns new comment', () async {
        final result = await repository.addComplaintComment(
          complaintId: 201,
          comment: 'تمت المعالجة',
        );
        expect(result.isRight(), isTrue);
        result.fold((l) => fail('Expected Right'), (comment) {
          expect(comment.complaintId, equals(201));
          expect(comment.comment, equals('تمت المعالجة'));
        });
        expect(mockRemoteDataSource.addCommentCallCount, equals(1));
      });
    });
  });
}
