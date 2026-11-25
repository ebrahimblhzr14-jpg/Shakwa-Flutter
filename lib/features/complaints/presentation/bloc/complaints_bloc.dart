import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/repositories/i_complaint_repository.dart';
import 'complaints_event.dart';
import 'complaints_state.dart';

class ComplaintsBloc extends Bloc<ComplaintsEvent, ComplaintsState> {
  final IComplaintRepository _repository;
  List<Complaint> _cachedComplaints = [];

  ComplaintsBloc({required IComplaintRepository repository})
    : _repository = repository,
      super(const ComplaintsInitialState()) {
    on<LoadMyComplaintsEvent>(_onLoadMyComplaints);
    on<FilterComplaintsByStatusEvent>(_onFilterByStatus);
    on<SearchComplaintsEvent>(_onSearch);
  }

  Future<void> _onLoadMyComplaints(
    LoadMyComplaintsEvent event,
    Emitter<ComplaintsState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const ComplaintsLoadingState());
    }

    final result = await _repository.getMyComplaints();

    result.fold(
      (failure) {
        emit(
          ComplaintsErrorState(
            failure.message,
            isNetworkError: failure is NetworkFailure,
          ),
        );
      },
      (complaints) {
        _cachedComplaints = complaints;
        if (complaints.isEmpty) {
          emit(const ComplaintsEmptyState());
        } else {
          emit(
            ComplaintsLoadedState(
              complaints: complaints,
              filteredComplaints: complaints,
            ),
          );
        }
      },
    );
  }

  void _onFilterByStatus(
    FilterComplaintsByStatusEvent event,
    Emitter<ComplaintsState> emit,
  ) {
    final current = state;
    if (current is ComplaintsLoadedState) {
      final newStatus = event.status;
      final filtered = _applyFilters(
        _cachedComplaints,
        newStatus,
        current.searchQuery,
      );

      emit(
        current.copyWith(
          selectedStatus: newStatus,
          clearStatus: newStatus == null,
          filteredComplaints: filtered,
        ),
      );
    }
  }

  void _onSearch(SearchComplaintsEvent event, Emitter<ComplaintsState> emit) {
    final current = state;
    if (current is ComplaintsLoadedState) {
      final query = event.query.trim().toLowerCase();
      final filtered = _applyFilters(
        _cachedComplaints,
        current.selectedStatus,
        query,
      );

      emit(current.copyWith(searchQuery: query, filteredComplaints: filtered));
    }
  }

  List<Complaint> _applyFilters(
    List<Complaint> all,
    dynamic status,
    String query,
  ) {
    var result = List<Complaint>.from(all);

    if (status != null) {
      result = result.where((c) => c.status == status).toList();
    }

    if (query.isNotEmpty) {
      result = result.where((c) {
        final title = c.title.toLowerCase();
        final desc = c.description.toLowerCase();
        final id = c.id.toString();
        final cat = (c.categoryName ?? '').toLowerCase();
        final dept = (c.departmentName ?? '').toLowerCase();
        return title.contains(query) ||
            desc.contains(query) ||
            id.contains(query) ||
            cat.contains(query) ||
            dept.contains(query);
      }).toList();
    }

    return result;
  }
}
