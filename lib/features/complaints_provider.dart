import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/complaint_model.dart';
import '../data/models/comment_model.dart';
import '../data/models/history_model.dart';
import '../data/models/priority_model.dart';
import '../data/models/status_model.dart';
import '../data/repositories/complaint_repository.dart';

final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  return MockComplaintRepository();
});

class ComplaintsState {
  final List<ComplaintModel> complaints;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final ComplaintStatus? statusFilter;
  final String? categoryFilter;

  const ComplaintsState({
    this.complaints = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.statusFilter,
    this.categoryFilter,
  });

  ComplaintsState copyWith({
    List<ComplaintModel>? complaints,
    bool? isLoading,
    String? error,
    String? searchQuery,
    ComplaintStatus? statusFilter,
    bool clearStatusFilter = false,
    String? categoryFilter,
    bool clearCategoryFilter = false,
  }) {
    return ComplaintsState(
      complaints: complaints ?? this.complaints,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
      categoryFilter: clearCategoryFilter
          ? null
          : (categoryFilter ?? this.categoryFilter),
    );
  }
}

class ComplaintsNotifier extends StateNotifier<ComplaintsState> {
  final ComplaintRepository _repository;

  ComplaintsNotifier(this._repository) : super(const ComplaintsState()) {
    loadComplaints();
  }

  Future<void> loadComplaints() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.getAllComplaints();
      state = state.copyWith(complaints: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'تعذر تحميل الشكاوى');
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStatusFilter(ComplaintStatus? status) {
    if (status == null) {
      state = state.copyWith(clearStatusFilter: true);
    } else {
      state = state.copyWith(statusFilter: status);
    }
  }

  void setCategoryFilter(String? category) {
    if (category == null) {
      state = state.copyWith(clearCategoryFilter: true);
    } else {
      state = state.copyWith(categoryFilter: category);
    }
  }

  Future<ComplaintModel> createComplaint({
    required String title,
    required String description,
    required String category,
    required PriorityLevel priority,
    required String location,
    List<String> attachments = const [],
  }) async {
    state = state.copyWith(isLoading: true);
    final created = await _repository.createComplaint(
      title: title,
      description: description,
      category: category,
      priority: priority,
      location: location,
      attachments: attachments,
    );
    final updatedList = [created, ...state.complaints];
    state = state.copyWith(complaints: updatedList, isLoading: false);
    return created;
  }

  Future<ComplaintModel> updateComplaint(ComplaintModel updated) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.updateComplaint(updated);
    final updatedList = state.complaints
        .map((c) => c.id == result.id ? result : c)
        .toList();
    state = state.copyWith(complaints: updatedList, isLoading: false);
    return result;
  }

  Future<void> deleteComplaint(String id) async {
    state = state.copyWith(isLoading: true);
    await _repository.deleteComplaint(id);
    final updatedList = state.complaints.where((c) => c.id != id).toList();
    state = state.copyWith(complaints: updatedList, isLoading: false);
  }

  Future<void> updateStatus(
    String complaintId,
    ComplaintStatus newStatus, {
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.updateStatus(
      complaintId,
      newStatus,
      notes: notes,
    );
    final updatedList = state.complaints
        .map((c) => c.id == result.id ? result : c)
        .toList();
    state = state.copyWith(complaints: updatedList, isLoading: false);
  }

  Future<void> assignComplaint({
    required String complaintId,
    required String employeeId,
    required String employeeName,
    String? department,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.assignComplaint(
      complaintId: complaintId,
      employeeId: employeeId,
      employeeName: employeeName,
      department: department,
      notes: notes,
    );
    final updatedList = state.complaints
        .map((c) => c.id == result.id ? result : c)
        .toList();
    state = state.copyWith(complaints: updatedList, isLoading: false);
  }

  Future<CommentModel> addComment({
    required String complaintId,
    required String message,
  }) async {
    final comment = await _repository.addComment(
      complaintId: complaintId,
      message: message,
    );
    await loadComplaints();
    return comment;
  }

  Future<void> submitRating({
    required String complaintId,
    required int rating,
    String? feedbackText,
  }) async {
    await _repository.submitFeedback(
      complaintId: complaintId,
      rating: rating,
      feedbackText: feedbackText,
    );
    await loadComplaints();
  }
}

final complaintsProvider =
    StateNotifierProvider<ComplaintsNotifier, ComplaintsState>((ref) {
      final repo = ref.watch(complaintRepositoryProvider);
      return ComplaintsNotifier(repo);
    });

/// History Provider
final complaintHistoryProvider = FutureProvider<List<HistoryModel>>((
  ref,
) async {
  final repo = ref.watch(complaintRepositoryProvider);
  return repo.getComplaintHistory();
});
