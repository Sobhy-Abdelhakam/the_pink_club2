import '../../domain/entities/medical_provider.dart';

class MedicalProviderModel extends MedicalProvider {
  const MedicalProviderModel({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required String phone,
    required String discount,
    required String type,
  }) : super(
          id: id,
          name: name,
          latitude: latitude,
          longitude: longitude,
          phone: phone,
          discount: discount,
          type: type,
        );

  factory MedicalProviderModel.fromJson(Map<String, dynamic> json) {
    // Generate an ID if missing, similar to original map.dart logic
    final lat = (json['latitude'] as num?)?.toDouble() ?? 0.0;
    final lng = (json['longitude'] as num?)?.toDouble() ?? 0.0;
    final id = (json['id'] ?? '${lat}_$lng').toString();

    return MedicalProviderModel(
      id: id,
      name: (json['name'] ?? 'Unknown').toString(),
      latitude: lat,
      longitude: lng,
      phone: (json['phone'] ?? 'N/A').toString(),
      discount: (json['discount_pct'] ?? 'N/A').toString(),
      type: (json['type'] ?? 'Unknown').toString(),
    );
  }
}
