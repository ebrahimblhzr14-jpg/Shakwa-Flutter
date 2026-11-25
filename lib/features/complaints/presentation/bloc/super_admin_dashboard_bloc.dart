import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_complaint_repository.dart';
import 'super_admin_dashboard_event.dart';
import 'super_admin_dashboard_state.dart';

class SuperAdminDashboardBloc
    extends Bloc<SuperAdminDashboardEvent, SuperAdminDashboardState> {
  final IComplaintRepository _repository;

  SuperAdminDashboardBloc({required IComplaintRepository repository})
    : _repository = repository,
      super(const SuperAdminDashboardInitialState()) {
    on<LoadSuperAdminDashboardEvent>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadSuperAdminDashboardEvent event,
    Emitter<SuperAdminDashboardState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const SuperAdminDashboardLoadingState());
    }

    final summaryResult = await _repository.getDashboardSummary();
    final allComplaintsResult = await _repository.getAllComplaints();

    summaryResult.fold(
      (failure) => emit(SuperAdminDashboardErrorState(failure.message)),
      (summary) {
        final recentComplaints = allComplaintsResult.fold(
          (_) => const <dynamic>[],
          (complaints) => complaints.take(5).toList(),
        );

        emit(
          SuperAdminDashboardLoadedState(
            totalComplaints: summary['totalComplaints'] ?? 0,
            pendingComplaints: summary['pendingComplaints'] ?? 0,
            inProgressComplaints: summary['inProgressComplaints'] ?? 0,
            resolvedComplaints: summary['resolvedComplaints'] ?? 0,
            closedComplaints: summary['closedComplaints'] ?? 0,
            recentComplaints: recentComplaints.cast(),
          ),
        );
      },
    );
  }
}
