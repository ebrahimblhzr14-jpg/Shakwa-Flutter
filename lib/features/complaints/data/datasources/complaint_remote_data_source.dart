import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/attachment_upload_service.dart';
import '../models/complaint_category_model.dart';
import '../models/complaint_comment_model.dart';
import '../models/complaint_dto.dart';
import '../models/complaint_history_model.dart';
import '../models/create_assignment_dto.dart';
import '../models/create_comment_request_dto.dart';
import '../models/create_complaint_request_dto.dart';
import '../models/dashboard_summary_model.dart';
import '../models/update_complaint_status_request_dto.dart';

/// Contract for Citizen & General Complaints Remote Data Source.
abstract class IComplaintRemoteDataSource {
  /// Calls GET /api/Complaints/All (SuperAdmin only).
  Future<List<ComplaintDto>> getAllComplaints();

  /// Calls PATCH /api/Complaints/assign (SuperAdmin only).
  Future<void> assignComplaint(CreateAssignmentDto request);

  /// Calls GET /api/Dashboard/summary (Admin/SuperAdmin).
  Future<DashboardSummaryModel> getDashboardSummary();

  /// Calls GET /api/ComplaintHistory (Global, SuperAdmin only).
  Future<List<ComplaintHistoryModel>> getGlobalComplaintHistory();

  /// Calls GET /api/Complaints/AllByUserID/{userId}.
  Future<List<ComplaintDto>> getMyComplaints(int userId);

  /// Calls GET /api/Complaints/AssignedToMe.
  Future<List<ComplaintDto>> getAssignedComplaints();

  /// Calls PATCH /api/Complaints/{id}/status.
  Future<void> updateComplaintStatus(int id, int statusId);

  /// Calls GET /api/ComplaintComments/GetAll/{complaintId}.
  Future<List<ComplaintCommentModel>> getComplaintComments(int complaintId);

  /// Calls POST /api/ComplaintComments/Create.
  Future<ComplaintCommentModel> addComplaintComment(
    int complaintId,
    String comment,
  );

  /// Calls GET /api/Complaints/FindBy/{id}.
  Future<ComplaintDto> getComplaintById(int id);

  /// Calls POST /api/Complaints/Create.
  Future<ComplaintDto> createComplaint(CreateComplaintRequestDto request);

  /// Calls PUT /api/Complaints/Update/{id}.
  Future<ComplaintDto> updateComplaint(
    int id,
    CreateComplaintRequestDto request,
  );

  /// Calls GET /api/Categories/All.
  Future<List<ComplaintCategoryModel>> getCategories();

  /// Calls GET /api/ComplaintHistory?complaintId={complaintId}.
  Future<List<ComplaintHistoryModel>> getComplaintHistory(int complaintId);

  /// Calls GET /api/Attachment/GetImagePath/{complaintId}.
  Future<String> getImagePath(int complaintId);

  /// Uploads single attachment via [AttachmentUploadService].
  Future<AttachmentUploadItem> uploadAttachment(
    int complaintId,
    AttachmentUploadItem item,
  );
}

/// Implementation of [IComplaintRemoteDataSource] backed by [ApiClient].
class ComplaintRemoteDataSourceImpl implements IComplaintRemoteDataSource {
  final ApiClient _apiClient;
  final AttachmentUploadService _attachmentUploadService;

  ComplaintRemoteDataSourceImpl({
    required ApiClient apiClient,
    required AttachmentUploadService attachmentUploadService,
  }) : _apiClient = apiClient,
       _attachmentUploadService = attachmentUploadService;

  @override
  Future<List<ComplaintDto>> getAllComplaints() async {
    final response = await _apiClient.get(ApiEndpoints.allComplaints);
    if (response.data is List) {
      final list = response.data as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => ComplaintDto.fromJson(json))
          .toList();
    }
    return [];
  }

  @override
  Future<void> assignComplaint(CreateAssignmentDto request) async {
    await _apiClient.patch(
      ApiEndpoints.assignComplaint,
      data: request.toJson(),
    );
  }

  @override
  Future<DashboardSummaryModel> getDashboardSummary() async {
    final response = await _apiClient.get(ApiEndpoints.dashboardSummary);
    return DashboardSummaryModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<List<ComplaintHistoryModel>> getGlobalComplaintHistory() async {
    final response = await _apiClient.get(ApiEndpoints.globalHistory);
    if (response.data is List) {
      final list = response.data as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => ComplaintHistoryModel.fromJson(json))
          .toList();
    }
    return [];
  }

  @override
  Future<List<ComplaintDto>> getMyComplaints(int userId) async {
    final response = await _apiClient.get(
      ApiEndpoints.complaintsByUserId(userId),
    );
    if (response.data is List) {
      final list = response.data as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => ComplaintDto.fromJson(json))
          .toList();
    }
    return [];
  }

  @override
  Future<List<ComplaintDto>> getAssignedComplaints() async {
    final response = await _apiClient.get(ApiEndpoints.assignedToMe);
    if (response.data is List) {
      final list = response.data as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => ComplaintDto.fromJson(json))
          .toList();
    }
    return [];
  }

  @override
  Future<void> updateComplaintStatus(int id, int statusId) async {
    await _apiClient.patch(
      ApiEndpoints.updateComplaintStatus(id),
      data: UpdateComplaintStatusRequestDto(statusId: statusId).toJson(),
    );
  }

  @override
  Future<List<ComplaintCommentModel>> getComplaintComments(
    int complaintId,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.getComments(complaintId),
    );
    if (response.data is List) {
      final list = response.data as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => ComplaintCommentModel.fromJson(json))
          .toList();
    }
    return [];
  }

  @override
  Future<ComplaintCommentModel> addComplaintComment(
    int complaintId,
    String comment,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.createComment,
      data: CreateCommentRequestDto(
        complaintId: complaintId,
        comment: comment,
      ).toJson(),
    );
    return ComplaintCommentModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<ComplaintDto> getComplaintById(int id) async {
    final response = await _apiClient.get(ApiEndpoints.complaintById(id));
    return ComplaintDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ComplaintDto> createComplaint(
    CreateComplaintRequestDto request,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.createComplaint,
      data: request.toJson(),
    );
    return ComplaintDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ComplaintDto> updateComplaint(
    int id,
    CreateComplaintRequestDto request,
  ) async {
    final response = await _apiClient.put(
      ApiEndpoints.updateComplaint(id),
      data: request.toJson(),
    );
    if (response.data is Map<String, dynamic>) {
      return ComplaintDto.fromJson(response.data as Map<String, dynamic>);
    }
    // Fallback if 200 OK without body: fetch updated complaint
    return getComplaintById(id);
  }

  @override
  Future<List<ComplaintCategoryModel>> getCategories() async {
    final response = await _apiClient.get(ApiEndpoints.categories);
    if (response.data is List) {
      final list = response.data as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => ComplaintCategoryModel.fromJson(json))
          .toList();
    }
    return [];
  }

  @override
  Future<List<ComplaintHistoryModel>> getComplaintHistory(
    int complaintId,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.complaintHistory(complaintId),
    );
    if (response.data is List) {
      final list = response.data as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => ComplaintHistoryModel.fromJson(json))
          .toList();
    }
    return [];
  }

  @override
  Future<String> getImagePath(int complaintId) async {
    final response = await _apiClient.get(
      ApiEndpoints.getImagePath(complaintId),
    );
    if (response.data is String) {
      return (response.data as String).trim();
    }
    return response.data?.toString().trim() ?? '';
  }

  @override
  Future<AttachmentUploadItem> uploadAttachment(
    int complaintId,
    AttachmentUploadItem item,
  ) {
    return _attachmentUploadService.uploadSingleAttachment(
      complaintId: complaintId,
      item: item,
    );
  }
}
