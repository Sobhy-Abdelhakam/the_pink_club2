import 'package:equatable/equatable.dart';
import '../../domain/entities/concierge_service.dart';

abstract class ConciergeState extends Equatable {
  const ConciergeState();
  @override
  List<Object> get props => [];
}

class ConciergeInitial extends ConciergeState {}

class ConciergeLoading extends ConciergeState {}

class ConciergeLoaded extends ConciergeState {
  final List<ConciergeService> services;
  const ConciergeLoaded(this.services);
  @override
  List<Object> get props => [services];
}

class ConciergeError extends ConciergeState {
  final String message;
  const ConciergeError(this.message);
  @override
  List<Object> get props => [message];
}
