import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/failures.dart';
import '../models/medical_provider_model.dart';

abstract class MedicalNetworkRemoteDataSource {
  Future<List<MedicalProviderModel>> getProviders();
}

class MedicalNetworkRemoteDataSourceImpl implements MedicalNetworkRemoteDataSource {
  final http.Client client;
  final String _url = "https://providers.euro-assist.com/api/arabic-providers";

  MedicalNetworkRemoteDataSourceImpl({required this.client});

  @override
  Future<List<MedicalProviderModel>> getProviders() async {
    final response = await client
        .get(Uri.parse(_url), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => MedicalProviderModel.fromJson(e)).toList();
    } else {
      throw ServerFailure('API Error: ${response.statusCode}');
    }
  }
}
