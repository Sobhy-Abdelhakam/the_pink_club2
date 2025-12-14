import 'package:equatable/equatable.dart';

class ServiceEntity extends Equatable {
  final int id;
  final String title;
  final String icon;
  final String color;
  final String description;
  final double price;
  final String duration;
  final List<String> features;

  const ServiceEntity({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.price,
    required this.duration,
    this.features = const [],
  });

  @override
  List<Object?> get props => [id, title, icon, color, description, price, duration, features];
}
