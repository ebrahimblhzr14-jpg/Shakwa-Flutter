import '../models/complaint_model.dart';
import '../models/comment_model.dart';
import '../models/history_model.dart';
import '../models/priority_model.dart';
import '../models/status_model.dart';
import '../mock_data/mock_database.dart';

abstract class ComplaintRepository {
  Future<List<ComplaintModel>> getAllComplaints();
  Future<List<ComplaintModel>> getUserComplaints(String userId);
  Future<List<ComplaintModel>> getAssignedComplaints(String adminUserId);
  Future<ComplaintModel?> getComplaintById(String id);
  Future<ComplaintModel> createComplaint({
    required String title,
    required String description,
    required String category,
    required PriorityLevel priority,
    required String location,
    List<String> attachments = const [],
  });
  Future<ComplaintModel> updateComplaint(ComplaintModel complaint);
  Future<void> deleteComplaint(String id);
  Future<ComplaintModel> updateStatus(
    String complaintId,
    ComplaintStatus newStatus, {
    String? notes,
  });
  Future<ComplaintModel> assignComplaint({
    required String complaintId,
    required String employeeId,
    required String employeeName,
    String? department,
    String? notes,
  });
  Future<CommentModel> addComment({
    required String complaintId,
    required String message,
  });
  Future<void> submitFeedback({
    required String complaintId,
    required int rating,
    String? feedbackText,
  });
  Future<List<HistoryModel>> getComplaintHistory({String? complaintId});
}

class MockComplaintRepository implements ComplaintRepository {
  final MockDatabase _db = MockDatabase.instance;

  @override
  Future<List<ComplaintModel>> getAllComplaints() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_db.complaints);
  }

  @override
  Future<List<ComplaintModel>> getUserComplaints(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _db.complaints.where((c) => c.submittedByUserId == userId).toList();
  }

  @override
  Future<List<ComplaintModel>> getAssignedComplaints(String adminUserId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _db.complaints
        .where((c) => c.assignedToUserId == adminUserId)
        .toList();
  }

  @override
  Future<ComplaintModel?> getComplaintById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _db.complaints.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ComplaintModel> createComplaint({
    required String title,
    required String description,
    required String category,
    required PriorityLevel priority,
    required String location,
    List<String> attachments = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final currentUser = _db.currentUser ?? _db.users.first;
    final newId = 'c-${DateTime.now().millisecondsSinceEpoch}';
    final complaintNumber = 'SHK-2026-${(_db.complaints.length + 101)}';

    final newComplaint = ComplaintModel(
      id: newId,
      complaintNumber: complaintNumber,
      title: title.trim(),
      description: description.trim(),
      category: category,
      priority: priority,
      status: ComplaintStatus.pending,
      location: location.trim(),
      attachments: attachments,
      submittedByUserId: currentUser.id,
      submittedByName: currentUser.fullName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      comments: [],
    );

    _db.complaints.insert(0, newComplaint);

    // Record activity history
    _db.history.insert(
      0,
      HistoryModel(
        id: 'h-${DateTime.now().millisecondsSinceEpoch}',
        complaintId: newId,
        complaintNumber: complaintNumber,
        actionTitle: 'تسجيل بلاغ جديد',
        actionDescription: 'تم تقديم البلاغ بنجاح عبر النظام',
        performedByUserId: currentUser.id,
        performedByName: currentUser.fullName,
        performedByRole: currentUser.role.shortNameArabic,
        timestamp: DateTime.now(),
        newStatus: ComplaintStatus.pending,
      ),
    );

    return newComplaint;
  }

  @override
  Future<ComplaintModel> updateComplaint(
    ComplaintModel updatedComplaint,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _db.complaints.indexWhere((c) => c.id == updatedComplaint.id);
    if (index != -1) {
      final updated = updatedComplaint.copyWith(updatedAt: DateTime.now());
      _db.complaints[index] = updated;

      _db.history.insert(
        0,
        HistoryModel(
          id: 'h-${DateTime.now().millisecondsSinceEpoch}',
          complaintId: updated.id,
          complaintNumber: updated.complaintNumber,
          actionTitle: 'تعديل بيانات الشكوى',
          actionDescription: 'تم تحديث معلومات وتفاصيل الشكوى',
          performedByUserId: _db.currentUser?.id ?? 'sys',
          performedByName: _db.currentUser?.fullName ?? 'المستخدم',
          performedByRole: _db.currentUser?.role.shortNameArabic ?? 'مستخدم',
          timestamp: DateTime.now(),
        ),
      );

      return updated;
    }
    throw Exception('Complaint not found');
  }

  @override
  Future<void> deleteComplaint(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _db.complaints.removeWhere((c) => c.id == id);
  }

  @override
  Future<ComplaintModel> updateStatus(
    String complaintId,
    ComplaintStatus newStatus, {
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _db.complaints.indexWhere((c) => c.id == complaintId);
    if (index == -1) throw Exception('Complaint not found');

    final old = _db.complaints[index];
    final updated = old.copyWith(status: newStatus, updatedAt: DateTime.now());
    _db.complaints[index] = updated;

    // Record activity history
    _db.history.insert(
      0,
      HistoryModel(
        id: 'h-${DateTime.now().millisecondsSinceEpoch}',
        complaintId: old.id,
        complaintNumber: old.complaintNumber,
        actionTitle: 'تحديث حالة الشكوى',
        actionDescription:
            notes ?? 'تم تغيير الحالة إلى ${newStatus.displayNameArabic}',
        performedByUserId: _db.currentUser?.id ?? 'admin',
        performedByName: _db.currentUser?.fullName ?? 'مشرف النظام',
        performedByRole: _db.currentUser?.role.shortNameArabic ?? 'مشرف',
        timestamp: DateTime.now(),
        previousStatus: old.status,
        newStatus: newStatus,
      ),
    );

    return updated;
  }

  @override
  Future<ComplaintModel> assignComplaint({
    required String complaintId,
    required String employeeId,
    required String employeeName,
    String? department,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _db.complaints.indexWhere((c) => c.id == complaintId);
    if (index == -1) throw Exception('Complaint not found');

    final old = _db.complaints[index];
    final updated = old.copyWith(
      assignedToUserId: employeeId,
      assignedToName: employeeName,
      department: department ?? old.department,
      status: old.status == ComplaintStatus.pending
          ? ComplaintStatus.underReview
          : old.status,
      updatedAt: DateTime.now(),
    );
    _db.complaints[index] = updated;

    _db.history.insert(
      0,
      HistoryModel(
        id: 'h-${DateTime.now().millisecondsSinceEpoch}',
        complaintId: old.id,
        complaintNumber: old.complaintNumber,
        actionTitle: 'إسناد الشكوى',
        actionDescription:
            'تم إسناد الشكوى إلى $employeeName ${notes != null ? '($notes)' : ''}',
        performedByUserId: _db.currentUser?.id ?? 'super',
        performedByName: _db.currentUser?.fullName ?? 'المسؤول العام',
        performedByRole: _db.currentUser?.role.shortNameArabic ?? 'مسؤول',
        timestamp: DateTime.now(),
        previousStatus: old.status,
        newStatus: updated.status,
      ),
    );

    return updated;
  }

  @override
  Future<CommentModel> addComment({
    required String complaintId,
    required String message,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _db.complaints.indexWhere((c) => c.id == complaintId);
    if (index == -1) throw Exception('Complaint not found');

    final currentUser = _db.currentUser ?? _db.users.first;
    final newComment = CommentModel(
      id: 'cm-${DateTime.now().millisecondsSinceEpoch}',
      complaintId: complaintId,
      userId: currentUser.id,
      userName: currentUser.fullName,
      userRoleText: currentUser.role.shortNameArabic,
      message: message.trim(),
      createdAt: DateTime.now(),
    );

    final currentComments = List<CommentModel>.from(
      _db.complaints[index].comments,
    );
    currentComments.add(newComment);

    _db.complaints[index] = _db.complaints[index].copyWith(
      comments: currentComments,
      updatedAt: DateTime.now(),
    );

    return newComment;
  }

  @override
  Future<void> submitFeedback({
    required String complaintId,
    required int rating,
    String? feedbackText,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _db.complaints.indexWhere((c) => c.id == complaintId);
    if (index != -1) {
      _db.complaints[index] = _db.complaints[index].copyWith(
        rating: rating,
        feedbackText: feedbackText,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<List<HistoryModel>> getComplaintHistory({String? complaintId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (complaintId != null) {
      return _db.history.where((h) => h.complaintId == complaintId).toList();
    }
    return List.from(_db.history);
  }
}
