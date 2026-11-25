/// DTO for creating a new comment on POST /api/ComplaintComments/Create.
class CreateCommentRequestDto {
  final int complaintId;
  final String comment;

  const CreateCommentRequestDto({
    required this.complaintId,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {'complaintId': complaintId, 'comment': comment.trim()};
  }
}
