import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/entities/complaint_status.dart';
import '../../domain/repositories/i_complaint_repository.dart';
import 'assigned_complaints_event.dart';
import 'assigned_complaints_state.dart';

class AssignedComplaintsBloc
    extends Bloc<AssignedComplaintsEvent, AssignedComplaintsState> {
  final IComplaintRepository _repository;

  List<Complaint> _cachedComplaints = [];

  AssignedComplaintsBloc({required IComplaintRepository repository})
    : _repository = repository,
      super(const AssignedComplaintsInitialState()) {
    on<LoadAssignedComplaintsEvent>(_onLoadAssignedComplaints);
    on<FilterAssignedComplaintsByStatusEvent>(_onFilterByStatus);
    on<SearchAssignedComplaintsEvent>(_onSearch);
    on<ChangeAssignedComplaintStatusEvent>(_onChangeStatus);
  }

  Future<void> _onLoadAssignedComplaints(
    LoadAssignedComplaintsEvent event,
    Emitter<AssignedComplaintsState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const AssignedComplaintsLoadingState());
    }

    final result = await _repository.getAssignedComplaints();

    result.fold(
      (failure) {
        emit(
          AssignedComplaintsErrorState(
            failure.message,
            isNetworkError: failure is NetworkFailure,
          ),
        );
      },
      (complaints) {
        _cachedComplaints = complaints;
        if (complaints.isEmpty) {
          emit(const AssignedComplaintsEmptyState());
        } else {
          emit(
            AssignedComplaintsLoadedState(
              complaints: complaints,
              filteredComplaints: complaints,
            ),
          );
        }
      },
    );
  }

  void _onFilterByStatus(
    FilterAssignedComplaintsByStatusEvent event,
    Emitter<AssignedComplaintsState> emit,
  ) {
    if (state is! AssignedComplaintsLoadedState) return;

    final currentState = state as AssignedComplaintsLoadedState;
    final filtered = _applyFilters(
      _cachedComplaints,
      event.status,
      currentState.searchQuery,
    );

    emit(
      currentState.copyWith(
        selectedStatus: event.status,
        clearStatusFilter: event.status == null,
        filteredComplaints: filtered,
      ),
    );
  }

  void _onSearch(
    SearchAssignedComplaintsEvent event,
    Emitter<AssignedComplaintsState> emit,
  ) {
    if (state is! AssignedComplaintsLoadedState) return;

    final currentState = state as AssignedComplaintsLoadedState;
    final filtered = _applyFilters(
      _cachedComplaints,
      currentState.selectedStatus,
      event.query,
    );

    emit(
      currentState.copyWith(
        searchQuery: event.query,
        filteredComplaints: filtered,
      ),
    );
  }

  Future<void> _onChangeStatus(
    ChangeAssignedComplaintStatusEvent event,
    Emitter<AssignedComplaintsState> emit,
  ) async {
    final currentState = state is AssignedComplaintsLoadedState
        ? state as AssignedComplaintsLoadedState
        : null;

    if (currentState != null) {
      emit(currentState.copyWith(isUpdatingStatus: true));
    }

    final result = await _repository.updateComplaintStatus(
      id: event.complaintId,
      statusId: event.status.id,
    );

    await result.fold(
      (failure) async {
        final isForbidden = failure is ForbiddenFailure;
        if (currentState != null) {
          emit(currentState.copyWith(isUpdatingStatus: false));
        }
        emit(
          AssignedComplaintsErrorState(
            failure.message,
            isForbidden: isForbidden,
            isNetworkError: failure is NetworkFailure,
          ),
        );
      },
      (_) async {
        // Refresh assigned complaints from backend after successful mutation
        final refreshRes = await _repository.getAssignedComplaints();
        refreshRes.fold(
          (failure) {
            emit(AssignedComplaintsErrorState(failure.message));
          },
          (updatedList) {
            _cachedComplaints = updatedList;
            final filtered = currentState != null
                ? _applyFilters(
                    updatedList,
                    currentState.selectedStatus,
                    currentState.searchQuery,
                  )
                : updatedList;

            emit(
              AssignedComplaintsLoadedState(
                complaints: updatedList,
                filteredComplaints: filtered,
                selectedStatus: currentState?.selectedStatus,
                searchQuery: currentState?.searchQuery,
                statusUpdateSuccessMessage:
                    'تم تحديث حالة الشكوى بنجاح إلى ${event.status.displayNameArabic}.',
                isUpdatingStatus: false,
              ),
            );
          },
        );
      },
    );
  }

  List<Complaint> _applyFilters(
    List<Complaint> list,
    ComplaintStatus? status,
    String? query,
  ) {
    var result = list;

    if (status != null) {
      result = result.where((c) => c.status == status).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((c) {
        final title = c.title.toLowerCase();
        final desc = c.description.toLowerCase();
        final cat = (c.categoryName ?? '').toLowerCase();
        final idStr = c.id.toString();
        return title.contains(q) ||
            desc.contains(q) ||
            cat.contains(q) ||
            idStr.contains(q);
      }).toList();
    }

    return result;
  }
}
