import 'package:equatable/equatable.dart';

abstract class ConciergeEvent extends Equatable {
  const ConciergeEvent();
  @override
  List<Object> get props => [];
}

class GetConciergeServicesEvent extends ConciergeEvent {
  final String lang;
  const GetConciergeServicesEvent({this.lang = 'en'});

  @override
  List<Object> get props => [lang];
}
