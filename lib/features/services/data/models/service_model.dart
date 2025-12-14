import '../../domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required int id,
    required String title,
    required String icon,
    required String color,
    required String description,
    required double price,
    required String duration,
    List<String> features = const [],
  }) : super(
          id: id,
          title: title,
          icon: icon,
          color: color,
          description: description,
          price: price,
          duration: duration,
          features: features,
        );

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      icon: json['icon'] ?? 'question-circle',
      color: json['color'] ?? '#E91E63',
      description: json['description'] ?? '',
      price: json['price'] is num ? (json['price'] as num).toDouble() : double.tryParse(json['price'].toString()) ?? 0.0,
      duration: json['duration'] ?? '',
      features: (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
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
      'features': features,
    };
  }
}
