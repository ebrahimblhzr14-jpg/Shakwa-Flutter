import 'package:equatable/equatable.dart';
import '../../domain/entities/complaint_details.dart';

abstract class ComplaintDetailsState extends Equatable {
  const ComplaintDetailsState();

  @override
  List<Object?> get props => [];
}

class ComplaintDetailsInitialState extends ComplaintDetailsState {
  const ComplaintDetailsInitialState();
}

class ComplaintDetailsLoadingState extends ComplaintDetailsState {
  const ComplaintDetailsLoadingState();
}

class ComplaintDetailsLoadedState extends ComplaintDetailsState {
  final ComplaintDetails details;

  const ComplaintDetailsLoadedState({required this.details});

  @override
  List<Object?> get props => [details];
}

class ComplaintDetailsErrorState extends ComplaintDetailsState {
  final String message;
  final bool isNotFound;
  final bool isNetworkError;

  const ComplaintDetailsErrorState(
    this.message, {
    this.isNotFound = false,
    this.isNetworkError = false,
  });

  @override
  List<Object?> get props => [message, isNotFound, isNetworkError];
}
