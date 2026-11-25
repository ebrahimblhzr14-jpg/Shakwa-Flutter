import 'package:equatable/equatable.dart';

/// Domain entity representing an attachment associated with a complaint.
class ComplaintAttachment extends Equatable {
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
  final String? publicUrl;

  const ComplaintAttachment({
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
    this.publicUrl,
  });

  @override
  List<Object?> get props => [
    id,
    complaintId,
    uploadedByUserId,
    uploadedByUserName,
    uploadedByUserImageUrl,
    fileName,
    filePath,
    fileType,
    fileSize,
    uploadedAt,
    publicUrl,
  ];
}
