/// DTO for updating complaint status on PATCH /api/Complaints/{id}/status.
class UpdateComplaintStatusRequestDto {
  final int statusId;

  const UpdateComplaintStatusRequestDto({required this.statusId});

  Map<String, dynamic> toJson() {
    return {'statusId': statusId};
  }
}
