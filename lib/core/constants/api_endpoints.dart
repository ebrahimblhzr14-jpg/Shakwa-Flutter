/// Centralized API endpoint routes verified against ASP.NET Core controllers.
class ApiEndpoints {
  // Authentication & Session
  static const String login = '/Auth/login';

  /// Exact spelling from AuthController.cs#L54 (contains letter 'g').
  static const String register = '/Auth/SingIn';

  static const String refreshToken = '/Auth/refresh';
  static const String logout = '/Auth/logout';

  // Attachments
  static String uploadAttachment(int complaintId) =>
      '/Attachment/Upload/$complaintId';
  static String getImagePath(int complaintId) =>
      '/Attachment/GetImagePath/$complaintId';
  static String updateAttachment(int id) => '/Attachment/Update/$id';
  static String deleteAttachment(int id) => '/Attachment/Delete/$id';

  // Complaints
  static const String allComplaints = '/Complaints/All';
  static const String assignedToMe = '/Complaints/AssignedToMe';
  static String complaintsByUserId(int userId) =>
      '/Complaints/AllByUserID/$userId';
  static String complaintById(int id) => '/Complaints/FindBy/$id';
  static const String createComplaint = '/Complaints/Create';
  static String updateComplaint(int id) => '/Complaints/Update/$id';
  static const String assignComplaint = '/Complaints/assign';
  static String updateComplaintStatus(int id) => '/Complaints/$id/status';

  // Comments
  static String getComments(int complaintId) =>
      '/ComplaintComments/GetAll/$complaintId';
  static const String createComment = '/ComplaintComments/Create';
  static String commentById(int id) => '/ComplaintComments/$id';

  // Feedback
  static String getFeedback(int complaintId) => '/Feedback/FindBy/$complaintId';
  static const String createFeedback = '/Feedback/create';
  static String updateFeedback(int complaintId, int feedbackId) =>
      '/Feedback/Update/$complaintId/$feedbackId';

  // History & Audit
  static const String globalHistory = '/ComplaintHistory';
  static String complaintHistory(int complaintId) =>
      '/ComplaintHistory?complaintId=$complaintId';

  // Dashboard Analytics (Admin / SuperAdmin only)
  static const String dashboardSummary = '/Dashboard/summary';
  static const String dashboardByStatus = '/Dashboard/complaints-by-status';
  static const String dashboardByPriority = '/Dashboard/complaints-by-priority';
  static const String dashboardByCategory = '/Dashboard/complaints-by-category';

  // Metadata / Lookups
  static const String categories = '/Categories/All';
  static const String departments = '/Departments/All';
  static const String priorities = '/Priorities/All';
  static const String statuses = '/Statuses/All';

  // User Management
  static const String allUsers = '/Users/All';
  static String userById(int id) => '/Users/FindBy/$id';
  static const String createUser = '/Users/Create';
  static String updateUser(int id) => '/Users/Update/$id';
  static String activateUser(int id) => '/Users/$id/activate';
  static String deactivateUser(int id) => '/Users/$id/deactivate';
  static String changeMyPassword = '/Users/me/password';
  static String changeUserPassword(int id) => '/Users/$id/password';
}
