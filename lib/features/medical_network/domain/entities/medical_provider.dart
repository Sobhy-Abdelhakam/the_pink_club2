import 'package:equatable/equatable.dart';

class MedicalProvider extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String phone;
  final String discount;
  final String type;

  const MedicalProvider({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.discount,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, latitude, longitude, phone, discount, type];
}
