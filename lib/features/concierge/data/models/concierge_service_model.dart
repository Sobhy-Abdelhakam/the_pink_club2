import '../../domain/entities/concierge_service.dart';

class ConciergeServiceModel extends ConciergeService {
  const ConciergeServiceModel({
    required int id,
    required String title,
    required String icon,
    required String color,
    required String description,
    required double price,
    required String duration,
  }) : super(
          id: id,
          title: title,
          icon: icon,
          color: color,
          description: description,
          price: price,
          duration: duration,
        );

  factory ConciergeServiceModel.fromJson(Map<String, dynamic> json) {
    return ConciergeServiceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'question-circle',
      color: json['color']?.toString() ?? '#E91E63',
      description: json['description']?.toString() ?? '',
      price: json['price'] is num ? (json['price'] as num).toDouble() : double.tryParse(json['price'].toString()) ?? 0.0,
      duration: json['duration']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'color': color,
      'description': description,
      'price': price,
      'duration': duration,
    };
  }
}
