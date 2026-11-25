/// Request DTO for assigning a complaint to an employee (SuperAdmin).
/// Matches Backend `ComplaintManagement.Business.DTOs.Assignments.CreateAssignmentDto`.
class CreateAssignmentDto {
  final int complaintId;
  final int assignedToUserId;
  final String? notes;

  const CreateAssignmentDto({
    required this.complaintId,
    required this.assignedToUserId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'complaintId': complaintId,
      'assignedToUserId': assignedToUserId,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }

  factory CreateAssignmentDto.fromJson(Map<String, dynamic> json) {
    return CreateAssignmentDto(
      complaintId: json['complaintId'] ?? json['ComplaintId'] ?? 0,
      assignedToUserId:
          json['assignedToUserId'] ?? json['AssignedToUserId'] ?? 0,
      notes: (json['notes'] ?? json['Notes'])?.toString(),
    );
  }
}
