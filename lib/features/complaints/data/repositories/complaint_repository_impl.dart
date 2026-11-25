import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/attachment_upload_service.dart';
import '../../../../core/security/token_manager.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/entities/complaint_attachment.dart';
import '../../domain/entities/complaint_category.dart';
import '../../domain/entities/complaint_comment.dart';
import '../../domain/entities/complaint_details.dart';
import '../../domain/entities/complaint_history_item.dart';
import '../../domain/repositories/i_complaint_repository.dart';
import '../datasources/complaint_remote_data_source.dart';
import '../models/create_assignment_dto.dart';
import '../models/create_complaint_request_dto.dart';

/// Concrete implementation of [IComplaintRepository].
class ComplaintRepositoryImpl implements IComplaintRepository {
  final IComplaintRemoteDataSource _remoteDataSource;
  final TokenManager _tokenManager;

  ComplaintRepositoryImpl({
    required IComplaintRemoteDataSource remoteDataSource,
    required TokenManager tokenManager,
  }) : _remoteDataSource = remoteDataSource,
       _tokenManager = tokenManager;

  @override
  Future<Either<Failure, List<Complaint>>> getMyComplaints({
    int? userId,
  }) async {
    try {
      final targetUserId = userId ?? _tokenManager.claims?.userId;
      if (targetUserId == null || targetUserId <= 0) {
        return const Left(
          AuthFailure('تعذر تحديد هوية المستخدم من الجلسة الحالية.'),
        );
      }

      final dtos = await _remoteDataSource.getMyComplaints(targetUserId);
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Complaint>>> getAssignedComplaints() async {
    try {
      final dtos = await _remoteDataSource.getAssignedComplaints();
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateComplaintStatus({
    required int id,
    required int statusId,
  }) async {
    try {
      if (id <= 0) {
        return const Left(ValidationFailure('معرف الشكوى غير صالح.'));
      }
      if (statusId < 1 || statusId > 5) {
        return const Left(ValidationFailure('حالة الشكوى المحددة غير صالحة.'));
      }
      await _remoteDataSource.updateComplaintStatus(id, statusId);
      return const Right(null);
    } on ForbiddenException {
      return const Left(
        ForbiddenFailure('أنت لست مسنداً لهذه الشكوى حالياً أو تم نقلها.'),
      );
    } catch (e) {
      if (e is ForbiddenException) {
        return const Left(
          ForbiddenFailure('أنت لست مسنداً لهذه الشكوى حالياً أو تم نقلها.'),
        );
      }
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Complaint>>> getAllComplaints() async {
    try {
      final dtos = await _remoteDataSource.getAllComplaints();
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> assignComplaint({
    required int complaintId,
    required int assignedToUserId,
    String? notes,
  }) async {
    try {
      if (complaintId <= 0 || assignedToUserId <= 0) {
        return const Left(ValidationFailure('معرف الشكوى أو الموظف غير صالح.'));
      }
      await _remoteDataSource.assignComplaint(
        CreateAssignmentDto(
          complaintId: complaintId,
          assignedToUserId: assignedToUserId,
          notes: notes,
        ),
      );
      return const Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getDashboardSummary() async {
    try {
      final model = await _remoteDataSource.getDashboardSummary();
      return Right({
        'totalComplaints': model.totalComplaints,
        'pendingComplaints': model.pendingComplaints,
        'inProgressComplaints': model.inProgressComplaints,
        'resolvedComplaints': model.resolvedComplaints,
        'closedComplaints': model.closedComplaints,
      });
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ComplaintHistoryItem>>>
  getGlobalComplaintHistory() async {
    try {
      final models = await _remoteDataSource.getGlobalComplaintHistory();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ComplaintComment>>> getComplaintComments(
    int complaintId,
  ) async {
    try {
      if (complaintId <= 0) {
        return const Left(ValidationFailure('معرف الشكوى غير صالح.'));
      }
      final models = await _remoteDataSource.getComplaintComments(complaintId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ComplaintComment>> addComplaintComment({
    required int complaintId,
    required String comment,
  }) async {
    try {
      if (complaintId <= 0) {
        return const Left(ValidationFailure('معرف الشكوى غير صالح.'));
      }
      if (comment.trim().isEmpty) {
        return const Left(ValidationFailure('نص التعليق مطلوب.'));
      }
      final model = await _remoteDataSource.addComplaintComment(
        complaintId,
        comment.trim(),
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Complaint>> getComplaintById(int id) async {
    try {
      if (id <= 0) {
        return const Left(ValidationFailure('معرف الشكوى غير صالح.'));
      }
      final dto = await _remoteDataSource.getComplaintById(id);
      return Right(dto.toEntity());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ComplaintDetails>> getComplaintDetails(int id) async {
    try {
      if (id <= 0) {
        return const Left(ValidationFailure('معرف الشكوى غير صالح.'));
      }

      final complaintDto = await _remoteDataSource.getComplaintById(id);

      List<ComplaintHistoryItem> history = [];
      try {
        final historyModels = await _remoteDataSource.getComplaintHistory(id);
        history = historyModels.map((h) => h.toEntity()).toList();
      } catch (_) {
        // Scoped history may return 404 or be empty; non-fatal for complaint view
      }

      String? primaryUrl;
      List<ComplaintAttachment> attachments = [];
      try {
        final url = await _remoteDataSource.getImagePath(id);
        if (url.isNotEmpty) {
          primaryUrl = url;
          attachments.add(
            ComplaintAttachment(
              id: 0,
              complaintId: id,
              uploadedByUserId: complaintDto.userId,
              fileName: url.split('/').last,
              filePath: url,
              uploadedAt: complaintDto.createdAt,
              publicUrl: url,
            ),
          );
        }
      } catch (_) {
        // Missing attachment returns 404; non-fatal
      }

      return Right(
        ComplaintDetails(
          complaint: complaintDto.toEntity(),
          history: history,
          attachments: attachments,
          primaryAttachmentUrl: primaryUrl,
        ),
      );
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Complaint>> createComplaint({
    required String title,
    required String description,
    required int categoryId,
    required int priorityId,
    int? departmentId,
    List<AttachmentUploadItem>? attachments,
  }) async {
    try {
      if (title.trim().isEmpty) {
        return const Left(ValidationFailure('عنوان الشكوى مطلوب.'));
      }
      if (description.trim().isEmpty) {
        return const Left(ValidationFailure('تفاصيل الشكوى مطلوبة.'));
      }
      if (categoryId <= 0) {
        return const Left(ValidationFailure('يرجى اختيار تصنيف صالح للشكوى.'));
      }
      if (priorityId <= 0) {
        return const Left(ValidationFailure('يرجى تحديد أولوية الشكوى.'));
      }

      final request = CreateComplaintRequestDto(
        title: title,
        description: description,
        categoryId: categoryId,
        priorityId: priorityId,
        departmentId: departmentId,
      );

      final createdDto = await _remoteDataSource.createComplaint(request);

      // Upload attachments sequentially if present
      if (attachments != null && attachments.isNotEmpty) {
        for (final item in attachments) {
          try {
            await _remoteDataSource.uploadAttachment(createdDto.id, item);
          } catch (_) {
            // Upload failure for individual photo is recorded on item
          }
        }
      }

      return Right(createdDto.toEntity());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Complaint>> updateComplaint({
    required int id,
    required String title,
    required String description,
    required int categoryId,
    required int priorityId,
    int? departmentId,
  }) async {
    try {
      if (id <= 0) {
        return const Left(ValidationFailure('معرف الشكوى غير صالح.'));
      }
      if (title.trim().isEmpty) {
        return const Left(ValidationFailure('عنوان الشكوى مطلوب.'));
      }
      if (description.trim().isEmpty) {
        return const Left(ValidationFailure('تفاصيل الشكوى مطلوبة.'));
      }

      final request = CreateComplaintRequestDto(
        title: title,
        description: description,
        categoryId: categoryId,
        priorityId: priorityId,
        departmentId: departmentId,
      );

      final updatedDto = await _remoteDataSource.updateComplaint(id, request);
      return Right(updatedDto.toEntity());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ComplaintCategory>>> getCategories() async {
    try {
      final models = await _remoteDataSource.getCategories();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ComplaintHistoryItem>>> getComplaintHistory(
    int complaintId,
  ) async {
    try {
      if (complaintId <= 0) {
        return const Left(ValidationFailure('معرف الشكوى غير صالح.'));
      }
      final models = await _remoteDataSource.getComplaintHistory(complaintId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> getComplaintImageUrl(int complaintId) async {
    try {
      if (complaintId <= 0) {
        return const Left(ValidationFailure('معرف الشكوى غير صالح.'));
      }
      final url = await _remoteDataSource.getImagePath(complaintId);
      return Right(url);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AttachmentUploadItem>> uploadAttachment({
    required int complaintId,
    required AttachmentUploadItem item,
  }) async {
    try {
      if (complaintId <= 0) {
        return const Left(ValidationFailure('معرف الشكوى غير صالح.'));
      }
      final uploaded = await _remoteDataSource.uploadAttachment(
        complaintId,
        item,
      );
      return Right(uploaded);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(Object exception) {
    if (exception is ValidationException) {
      return ValidationFailure(
        exception.message,
        fieldErrors: exception.fieldErrors,
      );
    }
    if (exception is UnauthorizedException) {
      return UnauthorizedFailure(exception.message);
    }
    if (exception is SessionExpiredException) {
      return SessionExpiredFailure(exception.message);
    }
    if (exception is ForbiddenException) {
      return ForbiddenFailure(exception.message);
    }
    if (exception is NotFoundException) {
      return NotFoundFailure(exception.message);
    }
    if (exception is ConflictException) {
      return ConflictFailure(exception.message);
    }
    if (exception is PayloadTooLargeException) {
      return UploadFailure(exception.message);
    }
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    }
    if (exception is ServerException) {
      return ServerFailure(exception.message);
    }
    return ServerFailure('حدث خطأ غير متوقع: $exception');
  }
}
