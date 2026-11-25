/// Model representing dashboard complaint metrics summary from GET /api/Dashboard/summary.
/// Matches Backend `ComplaintManagement.Business.DTOs.Dashboard.ComplaintSummaryDto`.
class DashboardSummaryModel {
  final int totalComplaints;
  final int pendingComplaints;
  final int inProgressComplaints;
  final int resolvedComplaints;
  final int closedComplaints;

  const DashboardSummaryModel({
    required this.totalComplaints,
    required this.pendingComplaints,
    required this.inProgressComplaints,
    required this.resolvedComplaints,
    required this.closedComplaints,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalComplaints: json['totalComplaints'] ?? json['TotalComplaints'] ?? 0,
      pendingComplaints:
          json['pendingComplaints'] ?? json['PendingComplaints'] ?? 0,
      inProgressComplaints:
          json['inProgressComplaints'] ?? json['InProgressComplaints'] ?? 0,
      resolvedComplaints:
          json['resolvedComplaints'] ?? json['ResolvedComplaints'] ?? 0,
      closedComplaints:
          json['closedComplaints'] ?? json['ClosedComplaints'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalComplaints': totalComplaints,
      'pendingComplaints': pendingComplaints,
      'inProgressComplaints': inProgressComplaints,
      'resolvedComplaints': resolvedComplaints,
      'closedComplaints': closedComplaints,
    };
  }
}
