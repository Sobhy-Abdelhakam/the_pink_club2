import '../../../../core/network/api_client.dart';
import '../models/service_model.dart';

abstract class ServiceRemoteDataSource {
  Future<List<ServiceModel>> getServices(String type, String lang);
}

class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final ApiClient apiClient;

  ServiceRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ServiceModel>> getServices(String type, String lang) async {
    String endpoint;
    switch (type) {
      case 'advisory':
        endpoint = 'advisory_services';
        break;
      case 'license':
        endpoint = 'license_services';
        break;
      case 'medical':
        endpoint = 'MedicalAdvisory';
        break;
      case 'medical_service':
        endpoint = 'MedicalServices';
        break;
      case 'more':
        endpoint = 'MoreServices';
        break;
      case 'automotive_supplies':
        endpoint = 'automotive_supplies';
        break;
      case 'second_medical_opinion':
        endpoint = 'second_medical_opinion';
        break;
      case 'car':
      default:
        endpoint = 'services';
        break;
    }

    final response = await apiClient.get(endpoint, lang: lang);
    final List<dynamic> data = response['data'] ?? [];
    return data.map((e) => ServiceModel.fromJson(e)).toList();
  }
}
