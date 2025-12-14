import '../../../../core/network/api_client.dart';
import '../models/concierge_service_model.dart';

abstract class ConciergeRemoteDataSource {
  Future<List<ConciergeServiceModel>> getServices(String lang);
}

class ConciergeRemoteDataSourceImpl implements ConciergeRemoteDataSource {
  final ApiClient apiClient;

  ConciergeRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ConciergeServiceModel>> getServices(String lang) async {
    final response = await apiClient.get('concierge', lang: lang);
    final List<dynamic> data = response['data'] ?? [];
    return data.map((e) => ConciergeServiceModel.fromJson(e)).toList();
  }
}
