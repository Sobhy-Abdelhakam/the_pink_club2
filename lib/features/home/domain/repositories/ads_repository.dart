
import '../../../../core/models/provider_ad.dart';

abstract class AdsRepository {
  Future<List<ProviderAd>> fetchAds();
}
