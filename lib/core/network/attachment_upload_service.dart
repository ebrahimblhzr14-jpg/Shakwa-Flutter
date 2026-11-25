import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../errors/exceptions.dart';
import 'api_client.dart';

enum AttachmentUploadStatus { pending, uploading, uploaded, failed, retrying }

/// Represents an attachment item in the upload pipeline.
class AttachmentUploadItem {
  final String id;
  final String fileName;
  final Uint8List fileBytes;
  final String contentType;
  AttachmentUploadStatus status;
  double progress;
  String? errorMessage;
  String? serverFileName;

  AttachmentUploadItem({
    required this.id,
    required this.fileName,
    required this.fileBytes,
    this.contentType = 'image/jpeg',
    this.status = AttachmentUploadStatus.pending,
    this.progress = 0.0,
    this.errorMessage,
    this.serverFileName,
  });

  bool get isSuccessful => status == AttachmentUploadStatus.uploaded;
  bool get isFailed => status == AttachmentUploadStatus.failed;
}

/// Service managing sequential multipart attachment uploads and failed-only retries.
class AttachmentUploadService {
  final ApiClient _apiClient;

  AttachmentUploadService({required ApiClient apiClient})
    : _apiClient = apiClient;

  /// Uploads a single image attachment to POST api/Attachment/Upload/{complainId}.
  /// Uses multipart field 'imageFile' verified in AttachmentController.cs#L41.
  Future<AttachmentUploadItem> uploadSingleAttachment({
    required int complaintId,
    required AttachmentUploadItem item,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    if (complaintId <= 0) {
      throw const ValidationException(message: 'معرف الشكوى غير صالح.');
    }

    // Client-side pre-validation
    if (item.fileBytes.length > AppConfig.maxFileSizeBytes) {
      item.status = AttachmentUploadStatus.failed;
      item.errorMessage = 'حجم الملف يتجاوز الحد المسموح (5 ميجابايت).';
      throw const PayloadTooLargeException();
    }

    item.status = AttachmentUploadStatus.uploading;
    item.progress = 0.0;
    item.errorMessage = null;

    try {
      final multipartFile = MultipartFile.fromBytes(
        item.fileBytes,
        filename: item.fileName,
        contentType: DioMediaType.parse(item.contentType),
      );

      final formData = FormData.fromMap({'imageFile': multipartFile});

      final response = await _apiClient.post(
        ApiEndpoints.uploadAttachment(complaintId),
        data: formData,
        cancelToken: cancelToken,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        item.serverFileName = data['fileName']?.toString();
        item.status = AttachmentUploadStatus.uploaded;
        item.progress = 1.0;
        return item;
      }

      item.status = AttachmentUploadStatus.failed;
      item.errorMessage = 'استجابة غير متوقعة من الخادم.';
      return item;
    } on DioException catch (e) {
      item.status = AttachmentUploadStatus.failed;
      item.errorMessage = _apiClient.mapDioException(e).message;
      rethrow;
    } catch (e) {
      item.status = AttachmentUploadStatus.failed;
      item.errorMessage = e.toString();
      rethrow;
    }
  }

  /// Uploads multiple attachments sequentially for a single complaint.
  /// Sequential execution prevents concurrent saturation and ensures predictable progress.
  Future<List<AttachmentUploadItem>> uploadSequentialAttachments({
    required int complaintId,
    required List<AttachmentUploadItem> items,
    void Function(int index, double progress)? onItemProgress,
    CancelToken? cancelToken,
  }) async {
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.isSuccessful) continue; // Skip already uploaded

      try {
        await uploadSingleAttachment(
          complaintId: complaintId,
          item: item,
          onProgress: (p) => onItemProgress?.call(i, p),
          cancelToken: cancelToken,
        );
      } catch (_) {
        // Continue sequential attempts for remaining items; error is recorded on item.status
      }
    }
    return items;
  }

  /// Retries ONLY failed attachments without re-creating the complaint or re-uploading succeeded items.
  Future<List<AttachmentUploadItem>> retryFailedAttachments({
    required int complaintId,
    required List<AttachmentUploadItem> items,
    void Function(int index, double progress)? onItemProgress,
    CancelToken? cancelToken,
  }) async {
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.status != AttachmentUploadStatus.failed) continue;

      item.status = AttachmentUploadStatus.retrying;
      try {
        await uploadSingleAttachment(
          complaintId: complaintId,
          item: item,
          onProgress: (p) => onItemProgress?.call(i, p),
          cancelToken: cancelToken,
        );
      } catch (_) {
        // Keep as failed
      }
    }
    return items;
  }
}
