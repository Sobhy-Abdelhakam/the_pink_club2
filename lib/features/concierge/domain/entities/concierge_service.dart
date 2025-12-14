import 'package:equatable/equatable.dart';

class ConciergeService extends Equatable {
  final int id;
  final String title;
  final String icon;
  final String color;
  final String description;
  final double price;
  final String duration;

  const ConciergeService({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.price,
    required this.duration,
  });

  @override
  List<Object?> get props => [id, title, icon, color, description, price, duration];
}
