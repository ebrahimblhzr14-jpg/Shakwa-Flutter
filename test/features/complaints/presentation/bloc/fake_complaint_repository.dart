import 'package:dartz/dartz.dart';
import 'package:shakwa_app/core/errors/failures.dart';
import 'package:shakwa_app/core/network/attachment_upload_service.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_category.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_comment.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_details.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_history_item.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_status.dart';
import 'package:shakwa_app/features/complaints/domain/repositories/i_complaint_repository.dart';

class FakeComplaintRepository implements IComplaintRepository {
  List<Complaint>? myComplaintsResult;
  Failure? myComplaintsFailure;

  List<Complaint>? assignedComplaintsResult;
  Failure? assignedComplaintsFailure;

  Failure? updateStatusFailure;
  int updateStatusCallCount = 0;
  int? lastUpdatedStatusId;

  List<ComplaintComment>? commentsResult;
  Failure? commentsFailure;

  ComplaintComment? addCommentResult;
  Failure? addCommentFailure;
  int addCommentCallCount = 0;

  Complaint? getByIdResult;
  Failure? getByIdFailure;

  ComplaintDetails? getDetailsResult;
  Failure? getDetailsFailure;

  Complaint? createResult;
  Failure? createFailure;

  Complaint? updateResult;
  Failure? updateFailure;

  List<ComplaintCategory>? categoriesResult;
  Failure? categoriesFailure;

  List<ComplaintHistoryItem>? historyResult;
  Failure? historyFailure;

  String? imageUrlResult;
  Failure? imageUrlFailure;

  AttachmentUploadItem? uploadResult;
  Failure? uploadFailure;
  int uploadCallCount = 0;

  @override
  Future<Either<Failure, List<Complaint>>> getMyComplaints({
    int? userId,
  }) async {
    if (myComplaintsFailure != null) return Left(myComplaintsFailure!);
    return Right(myComplaintsResult ?? []);
  }

  @override
  Future<Either<Failure, Complaint>> getComplaintById(int id) async {
    if (getByIdFailure != null) return Left(getByIdFailure!);
    return Right(
      getByIdResult ??
          Complaint(
            id: id,
            userId: 10,
            categoryId: 1,
            statusId: 1,
            status: ComplaintStatus.pending,
            priorityId: 1,
            priority: ComplaintPriority.low,
            title: 'شكوى تجريبية',
            description: 'تفاصيل',
            createdAt: DateTime.now(),
          ),
    );
  }

  @override
  Future<Either<Failure, ComplaintDetails>> getComplaintDetails(int id) async {
    if (getDetailsFailure != null) return Left(getDetailsFailure!);
    final c =
        getByIdResult ??
        Complaint(
          id: id,
          userId: 10,
          categoryId: 1,
          statusId: 1,
          status: ComplaintStatus.pending,
          priorityId: 1,
          priority: ComplaintPriority.low,
          title: 'شكوى مفصلة',
          description: 'تفاصيل الشكوى',
          createdAt: DateTime.now(),
        );

    return Right(
      getDetailsResult ??
          ComplaintDetails(
            complaint: c,
            history: historyResult ?? [],
            primaryAttachmentUrl: imageUrlResult,
          ),
    );
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
    if (createFailure != null) return Left(createFailure!);

    if (attachments != null && attachments.isNotEmpty) {
      for (final att in attachments) {
        await uploadAttachment(complaintId: 100, item: att);
      }
    }

    return Right(
      createResult ??
          Complaint(
            id: 100,
            userId: 10,
            categoryId: categoryId,
            statusId: 1,
            status: ComplaintStatus.pending,
            priorityId: priorityId,
            priority: ComplaintPriority.fromId(priorityId),
            title: title,
            description: description,
            createdAt: DateTime.now(),
          ),
    );
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
    if (updateFailure != null) return Left(updateFailure!);
    return Right(
      updateResult ??
          Complaint(
            id: id,
            userId: 10,
            categoryId: categoryId,
            statusId: 1,
            status: ComplaintStatus.pending,
            priorityId: priorityId,
            priority: ComplaintPriority.fromId(priorityId),
            title: title,
            description: description,
            createdAt: DateTime.now(),
          ),
    );
  }

  @override
  Future<Either<Failure, List<ComplaintCategory>>> getCategories() async {
    if (categoriesFailure != null) return Left(categoriesFailure!);
    return Right(
      categoriesResult ??
          [
            const ComplaintCategory(id: 1, name: 'الكهرباء والإنارة'),
            const ComplaintCategory(id: 2, name: 'المياه والصرف الصحي'),
            const ComplaintCategory(id: 3, name: 'النظافة والبيئة'),
          ],
    );
  }

  @override
  Future<Either<Failure, List<ComplaintHistoryItem>>> getComplaintHistory(
    int complaintId,
  ) async {
    if (historyFailure != null) return Left(historyFailure!);
    return Right(historyResult ?? []);
  }

  @override
  Future<Either<Failure, String>> getComplaintImageUrl(int complaintId) async {
    if (imageUrlFailure != null) return Left(imageUrlFailure!);
    return Right(imageUrlResult ?? '');
  }

  @override
  Future<Either<Failure, AttachmentUploadItem>> uploadAttachment({
    required int complaintId,
    required AttachmentUploadItem item,
  }) async {
    uploadCallCount++;
    if (uploadFailure != null) {
      item.status = AttachmentUploadStatus.failed;
      item.errorMessage = uploadFailure!.message;
      return Left(uploadFailure!);
    }
    item.status = AttachmentUploadStatus.uploaded;
    return Right(uploadResult ?? item);
  }

  @override
  Future<Either<Failure, List<Complaint>>> getAssignedComplaints() async {
    if (assignedComplaintsFailure != null) {
      return Left(assignedComplaintsFailure!);
    }
    return Right(assignedComplaintsResult ?? []);
  }

  @override
  Future<Either<Failure, void>> updateComplaintStatus({
    required int id,
    required int statusId,
  }) async {
    updateStatusCallCount++;
    lastUpdatedStatusId = statusId;
    if (updateStatusFailure != null) return Left(updateStatusFailure!);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<ComplaintComment>>> getComplaintComments(
    int complaintId,
  ) async {
    if (commentsFailure != null) return Left(commentsFailure!);
    return Right(commentsResult ?? []);
  }

  @override
  Future<Either<Failure, ComplaintComment>> addComplaintComment({
    required int complaintId,
    required String comment,
  }) async {
    addCommentCallCount++;
    if (addCommentFailure != null) return Left(addCommentFailure!);
    return Right(
      addCommentResult ??
          ComplaintComment(
            id: 99,
            complaintId: complaintId,
            userId: 5,
            userName: 'المشرف الميداني',
            comment: comment,
            createdAt: DateTime.now(),
          ),
    );
  }

  // SuperAdmin Operations
  List<Complaint>? allComplaintsResult;
  Failure? allComplaintsFailure;

  Failure? assignComplaintFailure;
  int assignComplaintCallCount = 0;
  int? lastAssignedComplaintId;
  int? lastAssignedUserId;
  String? lastAssignNotes;

  Map<String, int>? dashboardSummaryResult;
  Failure? dashboardSummaryFailure;

  List<ComplaintHistoryItem>? globalHistoryResult;
  Failure? globalHistoryFailure;

  @override
  Future<Either<Failure, List<Complaint>>> getAllComplaints() async {
    if (allComplaintsFailure != null) return Left(allComplaintsFailure!);
    return Right(allComplaintsResult ?? []);
  }

  @override
  Future<Either<Failure, void>> assignComplaint({
    required int complaintId,
    required int assignedToUserId,
    String? notes,
  }) async {
    assignComplaintCallCount++;
    lastAssignedComplaintId = complaintId;
    lastAssignedUserId = assignedToUserId;
    lastAssignNotes = notes;
    if (assignComplaintFailure != null) return Left(assignComplaintFailure!);
    return const Right(null);
  }

  @override
  Future<Either<Failure, Map<String, int>>> getDashboardSummary() async {
    if (dashboardSummaryFailure != null) return Left(dashboardSummaryFailure!);
    return Right(
      dashboardSummaryResult ??
          {
            'totalComplaints': 10,
            'pendingComplaints': 3,
            'inProgressComplaints': 4,
            'resolvedComplaints': 2,
            'closedComplaints': 1,
          },
    );
  }

  @override
  Future<Either<Failure, List<ComplaintHistoryItem>>>
  getGlobalComplaintHistory() async {
    if (globalHistoryFailure != null) return Left(globalHistoryFailure!);
    return Right(globalHistoryResult ?? []);
  }
}
