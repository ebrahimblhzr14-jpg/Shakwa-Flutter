import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/attachment_upload_service.dart';
import '../entities/complaint.dart';
import '../entities/complaint_category.dart';
import '../entities/complaint_comment.dart';
import '../entities/complaint_details.dart';
import '../entities/complaint_history_item.dart';

/// Contract for Citizen & General Complaint Domain Operations.
abstract class IComplaintRepository {
  /// Fetches complaints filed by the citizen.
  /// If [userId] is omitted, uses the current authenticated session userId.
  Future<Either<Failure, List<Complaint>>> getMyComplaints({int? userId});

  /// Fetches complaints actively assigned to the logged-in employee/supervisor.
  Future<Either<Failure, List<Complaint>>> getAssignedComplaints();

  /// Updates status of an actively assigned complaint.
  Future<Either<Failure, void>> updateComplaintStatus({
    required int id,
    required int statusId,
  });

  /// Fetches technical comments for a specific complaint.
  Future<Either<Failure, List<ComplaintComment>>> getComplaintComments(
    int complaintId,
  );

  /// Adds a new technical comment to a complaint.
  Future<Either<Failure, ComplaintComment>> addComplaintComment({
    required int complaintId,
    required String comment,
  });

  /// Fetches a single complaint by its ID.
  Future<Either<Failure, Complaint>> getComplaintById(int id);

  /// Fetches aggregated details of a complaint (metadata, history, primary image).
  Future<Either<Failure, ComplaintDetails>> getComplaintDetails(int id);

  /// Creates a new complaint.
  /// If [attachments] are provided, sequentially uploads them via [AttachmentUploadService].
  Future<Either<Failure, Complaint>> createComplaint({
    required String title,
    required String description,
    required int categoryId,
    required int priorityId,
    int? departmentId,
    List<AttachmentUploadItem>? attachments,
  });

  /// Updates an existing pending complaint owned by the citizen.
  Future<Either<Failure, Complaint>> updateComplaint({
    required int id,
    required String title,
    required String description,
    required int categoryId,
    required int priorityId,
    int? departmentId,
  });

  /// Fetches available categories for complaint classification.
  Future<Either<Failure, List<ComplaintCategory>>> getCategories();

  /// Fetches all system complaints (SuperAdmin only).
  Future<Either<Failure, List<Complaint>>> getAllComplaints();

  /// Assigns a complaint to an employee (SuperAdmin only).
  Future<Either<Failure, void>> assignComplaint({
    required int complaintId,
    required int assignedToUserId,
    String? notes,
  });

  /// Fetches global dashboard summary metrics from GET /api/Dashboard/summary.
  Future<Either<Failure, Map<String, int>>> getDashboardSummary();

  /// Fetches global audit history across all complaints (SuperAdmin only).
  Future<Either<Failure, List<ComplaintHistoryItem>>>
  getGlobalComplaintHistory();

  /// Fetches chronological audit history for a specific complaint.
  Future<Either<Failure, List<ComplaintHistoryItem>>> getComplaintHistory(
    int complaintId,
  );

  /// Fetches the primary attachment image URL for a complaint.
  Future<Either<Failure, String>> getComplaintImageUrl(int complaintId);

  /// Uploads a single attachment to a complaint.
  Future<Either<Failure, AttachmentUploadItem>> uploadAttachment({
    required int complaintId,
    required AttachmentUploadItem item,
  });
}
