import 'package:equatable/equatable.dart';

abstract class ServicesEvent extends Equatable {
  const ServicesEvent();
  @override
  List<Object> get props => [];
}

class GetServicesEvent extends ServicesEvent {
  final String type;
  final String lang;
  const GetServicesEvent({required this.type, this.lang = 'en'});

  @override
  List<Object> get props => [type, lang];
}
