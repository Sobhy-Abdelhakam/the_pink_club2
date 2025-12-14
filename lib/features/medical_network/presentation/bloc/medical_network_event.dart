import 'package:equatable/equatable.dart';

abstract class MedicalNetworkEvent extends Equatable {
  const MedicalNetworkEvent();

  @override
  List<Object> get props => [];
}

class LoadMedicalProvidersEvent extends MedicalNetworkEvent {}

class FilterMedicalProvidersEvent extends MedicalNetworkEvent {
  final Set<String> selectedTypes; // Empty means all

  const FilterMedicalProvidersEvent(this.selectedTypes);

  @override
  List<Object> get props => [selectedTypes];
}
