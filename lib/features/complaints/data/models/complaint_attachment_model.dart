import '../../domain/entities/complaint_attachment.dart';

/// Data model representing Attachment DTO from ASP.NET Core API.
class ComplaintAttachmentModel {
  final int id;
  final int complaintId;
  final int uploadedByUserId;
  final String? uploadedByUserName;
  final String? uploadedByUserImageUrl;
  final String fileName;
  final String filePath;
  final String? fileType;
  final int? fileSize;
  final DateTime uploadedAt;

  const ComplaintAttachmentModel({
    required this.id,
    required this.complaintId,
    required this.uploadedByUserId,
    this.uploadedByUserName,
    this.uploadedByUserImageUrl,
    required this.fileName,
    required this.filePath,
    this.fileType,
    this.fileSize,
    required this.uploadedAt,
  });

  factory ComplaintAttachmentModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['uploadedAt'] ?? json['UploadedAt'];
    final parsedDate = rawDate != null
        ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now()
        : DateTime.now();

    final rawSize =
        json['fileSize'] ??
        json['FileSize'] ??
        json['fileSizeBytes'] ??
        json['FileSizeBytes'];
    final parsedSize = rawSize is num
        ? rawSize.toInt()
        : (rawSize != null ? int.tryParse(rawSize.toString()) : null);

    return ComplaintAttachmentModel(
      id: json['id'] ?? json['Id'] ?? 0,
      complaintId: json['complaintId'] ?? json['ComplaintId'] ?? 0,
      uploadedByUserId:
          json['uploadedByUserId'] ?? json['UploadedByUserId'] ?? 0,
      uploadedByUserName:
          (json['uploadedByUserName'] ?? json['UploadedByUserName'])
              ?.toString(),
      uploadedByUserImageUrl:
          (json['uploadedByUserImageUrl'] ?? json['UploadedByUserImageUrl'])
              ?.toString(),
      fileName: (json['fileName'] ?? json['FileName'] ?? '').toString(),
      filePath: (json['filePath'] ?? json['FilePath'] ?? '').toString(),
      fileType:
          (json['fileType'] ??
                  json['FileType'] ??
                  json['contentType'] ??
                  json['ContentType'])
              ?.toString(),
      fileSize: parsedSize,
      uploadedAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaintId': complaintId,
      'uploadedByUserId': uploadedByUserId,
      'uploadedByUserName': uploadedByUserName,
      'uploadedByUserImageUrl': uploadedByUserImageUrl,
      'fileName': fileName,
      'filePath': filePath,
      'fileType': fileType,
      'fileSize': fileSize,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  ComplaintAttachment toEntity({String? publicUrl}) {
    return ComplaintAttachment(
      id: id,
      complaintId: complaintId,
      uploadedByUserId: uploadedByUserId,
      uploadedByUserName: uploadedByUserName,
      uploadedByUserImageUrl: uploadedByUserImageUrl,
      fileName: fileName,
      filePath: filePath,
      fileType: fileType,
      fileSize: fileSize,
      uploadedAt: uploadedAt,
      publicUrl: publicUrl,
    );
  }
}
