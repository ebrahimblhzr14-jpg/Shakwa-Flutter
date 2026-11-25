import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/i_complaint_repository.dart';
import 'complaint_details_event.dart';
import 'complaint_details_state.dart';

class ComplaintDetailsBloc
    extends Bloc<ComplaintDetailsEvent, ComplaintDetailsState> {
  final IComplaintRepository _repository;

  ComplaintDetailsBloc({required IComplaintRepository repository})
    : _repository = repository,
      super(const ComplaintDetailsInitialState()) {
    on<LoadComplaintDetailsEvent>(_onLoadDetails);
    on<RefreshComplaintDetailsEvent>(_onRefreshDetails);
  }

  Future<void> _onLoadDetails(
    LoadComplaintDetailsEvent event,
    Emitter<ComplaintDetailsState> emit,
  ) async {
    emit(const ComplaintDetailsLoadingState());
    await _fetchDetails(event.complaintId, emit);
  }

  Future<void> _onRefreshDetails(
    RefreshComplaintDetailsEvent event,
    Emitter<ComplaintDetailsState> emit,
  ) async {
    await _fetchDetails(event.complaintId, emit);
  }

  Future<void> _fetchDetails(
    int complaintId,
    Emitter<ComplaintDetailsState> emit,
  ) async {
    final result = await _repository.getComplaintDetails(complaintId);

    result.fold(
      (failure) {
        emit(
          ComplaintDetailsErrorState(
            failure.message,
            isNotFound: failure is NotFoundFailure,
            isNetworkError: failure is NetworkFailure,
          ),
        );
      },
      (details) {
        emit(ComplaintDetailsLoadedState(details: details));
      },
    );
  }
}
