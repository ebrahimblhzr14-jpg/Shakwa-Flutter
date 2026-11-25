import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/repositories/i_complaint_repository.dart';
import 'all_complaints_event.dart';
import 'all_complaints_state.dart';

class AllComplaintsBloc extends Bloc<AllComplaintsEvent, AllComplaintsState> {
  final IComplaintRepository _repository;

  AllComplaintsBloc({required IComplaintRepository repository})
    : _repository = repository,
      super(const AllComplaintsInitialState()) {
    on<LoadAllComplaintsEvent>(_onLoadComplaints);
    on<SearchAllComplaintsEvent>(_onSearchComplaints);
    on<FilterAllComplaintsEvent>(_onFilterComplaints);
  }

  Future<void> _onLoadComplaints(
    LoadAllComplaintsEvent event,
    Emitter<AllComplaintsState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const AllComplaintsLoadingState());
    }

    final result = await _repository.getAllComplaints();

    result.fold((failure) => emit(AllComplaintsErrorState(failure.message)), (
      complaints,
    ) {
      emit(
        AllComplaintsLoadedState(
          allComplaints: complaints,
          filteredComplaints: complaints,
        ),
      );
    });
  }

  void _onSearchComplaints(
    SearchAllComplaintsEvent event,
    Emitter<AllComplaintsState> emit,
  ) {
    final currentState = state;
    if (currentState is AllComplaintsLoadedState) {
      final query = event.query.trim().toLowerCase();
      final filtered = _applyFilters(
        currentState.allComplaints,
        query,
        currentState.onlyUnassigned,
        currentState.selectedStatusId,
      );
      emit(
        currentState.copyWith(
          searchQuery: event.query,
          filteredComplaints: filtered,
        ),
      );
    }
  }

  void _onFilterComplaints(
    FilterAllComplaintsEvent event,
    Emitter<AllComplaintsState> emit,
  ) {
    final currentState = state;
    if (currentState is AllComplaintsLoadedState) {
      final filtered = _applyFilters(
        currentState.allComplaints,
        currentState.searchQuery.trim().toLowerCase(),
        event.onlyUnassigned,
        event.statusId,
      );
      emit(
        currentState.copyWith(
          onlyUnassigned: event.onlyUnassigned,
          selectedStatusId: event.statusId,
          clearStatus: event.statusId == null,
          filteredComplaints: filtered,
        ),
      );
    }
  }

  List<Complaint> _applyFilters(
    List<Complaint> list,
    String query,
    bool onlyUnassigned,
    int? statusId,
  ) {
    var result = list;

    if (onlyUnassigned) {
      result = result
          .where((c) => c.statusId == 1 || c.status.isPending)
          .toList();
    }

    if (statusId != null) {
      result = result.where((c) => c.statusId == statusId).toList();
    }

    if (query.isNotEmpty) {
      result = result.where((c) {
        return c.title.toLowerCase().contains(query) ||
            c.id.toString().contains(query) ||
            (c.categoryName?.toLowerCase().contains(query) ?? false) ||
            c.description.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }
}
