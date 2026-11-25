/// DTO for creating or updating a complaint on POST /api/Complaints/Create or PUT /api/Complaints/Update/{id}.
class CreateComplaintRequestDto {
  final String title;
  final String description;
  final int categoryId;
  final int priorityId;
  final int? departmentId;

  const CreateComplaintRequestDto({
    required this.title,
    required this.description,
    required this.categoryId,
    required this.priorityId,
    this.departmentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title.trim(),
      'description': description.trim(),
      'categoryId': categoryId,
      'priorityId': priorityId,
      if (departmentId != null) 'departmentId': departmentId,
    };
  }
}
