import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_complaint_repository.dart';
import '../../../super_admin/domain/repositories/i_super_admin_user_repository.dart';
import 'assign_complaint_event.dart';
import 'assign_complaint_state.dart';

class AssignComplaintBloc
    extends Bloc<AssignComplaintEvent, AssignComplaintState> {
  final IComplaintRepository _complaintRepository;
  final ISuperAdminUserRepository _userRepository;

  AssignComplaintBloc({
    required IComplaintRepository complaintRepository,
    required ISuperAdminUserRepository userRepository,
  }) : _complaintRepository = complaintRepository,
       _userRepository = userRepository,
       super(const AssignComplaintInitialState()) {
    on<LoadAssignmentDataEvent>(_onLoadData);
    on<SubmitAssignmentEvent>(_onSubmitAssignment);
  }

  Future<void> _onLoadData(
    LoadAssignmentDataEvent event,
    Emitter<AssignComplaintState> emit,
  ) async {
    emit(const AssignComplaintLoadingState());

    final complaintResult = await _complaintRepository.getComplaintById(
      event.complaintId,
    );
    final employeesResult = await _userRepository.getEligibleEmployees();

    complaintResult.fold(
      (failure) => emit(AssignComplaintErrorState(failure.message)),
      (complaint) {
        final employees = employeesResult.fold(
          (_) => const <dynamic>[],
          (emps) => emps,
        );

        emit(
          AssignComplaintLoadedState(
            complaint: complaint,
            eligibleEmployees: employees,
          ),
        );
      },
    );
  }

  Future<void> _onSubmitAssignment(
    SubmitAssignmentEvent event,
    Emitter<AssignComplaintState> emit,
  ) async {
    final currentState = state;
    if (currentState is AssignComplaintLoadedState) {
      emit(currentState.copyWith(isSubmitting: true));

      final result = await _complaintRepository.assignComplaint(
        complaintId: event.complaintId,
        assignedToUserId: event.assignedToUserId,
        notes: event.notes,
      );

      result.fold(
        (failure) {
          emit(currentState.copyWith(isSubmitting: false));
          emit(AssignComplaintErrorState(failure.message));
        },
        (_) {
          emit(
            const AssignComplaintSuccessState(
              'تم إسناد الشكوى إلى الموظف المسؤول بنجاح.',
            ),
          );
        },
      );
    }
  }
}
