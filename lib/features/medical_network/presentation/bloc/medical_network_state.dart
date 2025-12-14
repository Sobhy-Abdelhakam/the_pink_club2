import 'package:equatable/equatable.dart';
import '../../domain/entities/medical_provider.dart';

abstract class MedicalNetworkState extends Equatable {
  const MedicalNetworkState();

  @override
  List<Object> get props => [];
}

class MedicalNetworkInitial extends MedicalNetworkState {}

class MedicalNetworkLoading extends MedicalNetworkState {}

class MedicalNetworkLoaded extends MedicalNetworkState {
  final List<MedicalProvider> allProviders; // Cache
  final List<MedicalProvider> filteredProviders; // Display

  const MedicalNetworkLoaded({
    required this.allProviders,
    required this.filteredProviders,
  });

  @override
  List<Object> get props => [allProviders, filteredProviders];
}

class MedicalNetworkError extends MedicalNetworkState {
  final String message;

  const MedicalNetworkError(this.message);

  @override
  List<Object> get props => [message];
}
