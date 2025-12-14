import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/repositories/ads_repository.dart';
import '../../../../core/models/provider_ad.dart';

class AdsRepositoryImpl implements AdsRepository {
  final http.Client client;

  AdsRepositoryImpl({required this.client});

  @override
  Future<List<ProviderAd>> fetchAds() async {
    try {
      final response = await client
          .get(Uri.parse('https://thepinkclub.net/admin/api/providers_ads.php'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> adsList = data['data'];
          return adsList.map((json) => ProviderAd.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load ads: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load ads: $e');
    }
  }
}
