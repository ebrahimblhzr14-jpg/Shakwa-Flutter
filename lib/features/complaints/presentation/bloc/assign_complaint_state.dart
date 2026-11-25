import 'package:equatable/equatable.dart';
import '../../domain/entities/complaint.dart';

abstract class AssignComplaintState extends Equatable {
  const AssignComplaintState();

  @override
  List<Object?> get props => [];
}

class AssignComplaintInitialState extends AssignComplaintState {
  const AssignComplaintInitialState();
}

class AssignComplaintLoadingState extends AssignComplaintState {
  const AssignComplaintLoadingState();
}

class AssignComplaintLoadedState extends AssignComplaintState {
  final Complaint complaint;
  final List<dynamic> eligibleEmployees;
  final bool isSubmitting;
  final String? successMessage;

  const AssignComplaintLoadedState({
    required this.complaint,
    required this.eligibleEmployees,
    this.isSubmitting = false,
    this.successMessage,
  });

  AssignComplaintLoadedState copyWith({
    Complaint? complaint,
    List<dynamic>? eligibleEmployees,
    bool? isSubmitting,
    String? successMessage,
  }) {
    return AssignComplaintLoadedState(
      complaint: complaint ?? this.complaint,
      eligibleEmployees: eligibleEmployees ?? this.eligibleEmployees,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    complaint,
    eligibleEmployees,
    isSubmitting,
    successMessage,
  ];
}

class AssignComplaintSuccessState extends AssignComplaintState {
  final String message;
  const AssignComplaintSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

class AssignComplaintErrorState extends AssignComplaintState {
  final String message;
  const AssignComplaintErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
