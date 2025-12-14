import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class SecureApiService {
  static const String _baseUrl = "https://thepinkclub.net/admin/api/api_secure.php";
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static String? _apiKey;

  static String _getCurrentLanguage(BuildContext context) {
    final locale = Localizations.localeOf(context);
    debugPrint('App-selected language: ${locale.languageCode}');
    return locale.languageCode == 'ar' ? 'ar' : 'en';
  }


  static Future<void> init() async {
    if (_apiKey != null) return;

    final key = utf8.encode('mobile-app-key');
    final secret = utf8.encode('your-256-bit-encryption-key-here!123');
    final hmacSha256 = Hmac(sha256, secret);
    final digest = hmacSha256.convert(key);
    _apiKey = 'flt-${digest.toString()}';
    debugPrint('✅ API Key: $_apiKey');

    // Store the API key in secure storage for future use
    await _storage.write(key: 'api_key', value: _apiKey);
  }
  static Future<String> _getApiKey() async {
    try {
      // First try to get from memory
      if (_apiKey != null) return _apiKey!;

      // Fall back to secure storage
      final apiKey = await _storage.read(key: 'api_key');
      if (apiKey == null) {
        await init(); // Initialize if not found
        return _apiKey!;
      }
      return apiKey;
    } catch (e) {
      debugPrint('Error getting API key: $e');
      throw Exception('Failed to retrieve API key');
    }
  }

  static Future<Map<String, dynamic>> _makeRequest(
      BuildContext context,
      String method,
      String action,
      Map<String, dynamic>? body,
      ) async {
    try {
      final apiKey = await _getApiKey();
      final currentLang = _getCurrentLanguage(context);
      debugPrint('Sending request with language: $currentLang');

      final uri = Uri.parse("$_baseUrl?action=$action&lang=$currentLang");
      final headers = {
        'X-API-Key': apiKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await (method == 'GET'
          ? http.get(uri, headers: headers)
          : http.post(uri, headers: headers, body: jsonEncode(body)))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Secure request error: $e');
      throw Exception('API request failed');
    }
  }

  static Future<List<Map<String, dynamic>>> getServices(BuildContext context) async {
    final response = await _makeRequest(context, 'GET', 'services', null);
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  static Future<List<Map<String, dynamic>>> getSubscriptions(BuildContext context) async {
    final response = await _makeRequest(context, 'GET', 'subscriptions', null);
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  static Future<List<Map<String, dynamic>>> getConciergeServices(BuildContext context) async {
    try {
      final response = await _makeRequest(context, 'GET', 'concierge', null);
      final List<dynamic> data = response['data'] ?? [];

      return data.map((service) {
        return {
          'id': service['id'] ?? 0,
          'title': service['title'] ?? 'Service',
          'icon': service['icon'] ?? 'question-circle',
          'color': service['color'] ?? '#E91E63',
          'description': service['description'] ?? '',
          'price': service['price'] ?? 0.0,
          'duration': service['duration'] ?? '',
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting concierge services: $e');
      throw Exception('Failed to load concierge services');
    }
  }

  static Future<Map<String, String>> getAbout(BuildContext context) async {
    try {
      final response = await _makeRequest(context, 'GET', 'about', null);
      final data = response['data'] ?? {};
      return {
        'vision': data['vision'] ?? '',
        'mission': data['mission'] ?? '',
      };
    } catch (e) {
      debugPrint('Error getting about info: $e');
      throw Exception('Failed to load about info');
    }
  }

  static Future<Map<String, dynamic>> getAppSettings(BuildContext context) async {
    try {
      final response = await _makeRequest(context, 'GET', 'app_settings', null);
      final data = response['data'] ?? {};

      return {
        'name': data['app_name'] ?? '',
        'description': data['app_description'] ?? '',
        'primaryColor': data['primary_color'] ?? '#E91E63',
        'secondaryColor': data['secondary_color'] ?? '#C2185B',
        'logo': data['logo'] ?? null,
        'favicon': data['favicon'] ?? null,
      };
    } catch (e) {
      debugPrint('Error loading app settings: $e');
      throw Exception('Failed to load app settings');
    }
  }

  static Future<List<Map<String, dynamic>>> getAdvisoryServices(BuildContext context) async {
    final response = await _makeRequest(context, 'GET', 'advisory_services', null);
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }
  static Future<List<Map<String, dynamic>>> getMedicalAdvisory(BuildContext context) async {
    final response = await _makeRequest(context, 'GET', 'MedicalAdvisory', null);
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }
  static Future<List<Map<String, dynamic>>> getMedicalServices(BuildContext context) async {
    final response = await _makeRequest(context, 'GET', 'MedicalServices', null);
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  static Future<List<Map<String, dynamic>>> getLicenseServices(BuildContext context) async {
    final response = await _makeRequest(context, 'GET', 'license_services', null);
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }
  static Future<List<Map<String, dynamic>>> getMoreServices(BuildContext context) async {
    final response = await _makeRequest(context, 'GET', 'MoreServices', null);
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  static Future<List<Map<String, dynamic>>> getAutomotiveSupplies(BuildContext context) async {
    final response = await _makeRequest(context, 'GET', 'automotive_supplies', null);
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  static Future<List<Map<String, dynamic>>> getSecondMedicalOpinion(BuildContext context) async {
    final response = await _makeRequest(context, 'GET', 'second_medical_opinion', null);
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  static Future<List<Map<String, dynamic>>> getProviderAds() async {
    try {
      final response = await http
          .get(Uri.parse('https://thepinkclub.net/admin/api/providers_ads.php'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        return [];
      } else {
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting provider ads: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> sendContactMessage({
    required BuildContext context,
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'phone': phone,
      'message': message,
    };

    return await _makeRequest(context, 'POST', 'send_contact', body);
  }
  static Future<bool> submitSubscription({
    required BuildContext context,
    required String fullName,
    required String birthday,
    required String gender,
    required String phone,
    required String address,
    required String carBrand,
    required String carModel,
    required String carMadeYear,
    required String carChassis,
    required String carPlate,
    required int packageId,
    required String paymentMethod,
  }) async {
    try {
      final apiKey = await _getApiKey();
      final lang = Localizations.localeOf(context).languageCode;

      final response = await http.post(
        Uri.parse('https://thepinkclub.net/admin/api/api_secure.php?action=subscribe&lang=$lang'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
        },
        body: jsonEncode({
          'full_name': fullName,
          'birthday': birthday,
          'gender': gender,
          'phone': phone,
          'address': address,
          'car_brand': carBrand,
          'car_model': carModel,
          'car_made_year': carMadeYear,
          'car_chassis': carChassis,
          'car_plate': carPlate,
          'package_id': packageId,
          'payment_method': paymentMethod,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Secure request error: $e');
      rethrow;
    }
  }
}
