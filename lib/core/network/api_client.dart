import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../error/failures.dart';

class ApiClient {
  static const String _baseUrl = "https://thepinkclub.net/admin/api/api_secure.php";
  final http.Client client;
  final FlutterSecureStorage storage;
  String? _apiKey;

  ApiClient({required this.client, required this.storage});

  Future<void> init() async {
    if (_apiKey != null) return;

    try {
      final storedKey = await storage.read(key: 'api_key');
      if (storedKey != null) {
        _apiKey = storedKey;
      } else {
        // Generate Key
        final key = utf8.encode('mobile-app-key');
        final secret = utf8.encode('your-256-bit-encryption-key-here!123');
        final hmacSha256 = Hmac(sha256, secret);
        final digest = hmacSha256.convert(key);
        _apiKey = 'flt-${digest.toString()}';
        await storage.write(key: 'api_key', value: _apiKey);
      }
      debugPrint('✅ API Key: $_apiKey');
    } catch (e) {
      debugPrint('Error initializing API Key: $e');
    }
  }

  Future<dynamic> get(String action, {String lang = 'en'}) async {
    return _request('GET', action, lang: lang);
  }

  Future<dynamic> post(String action, Map<String, dynamic> body, {String lang = 'en'}) async {
    return _request('POST', action, body: body, lang: lang);
  }

  Future<dynamic> _request(String method, String action, {Map<String, dynamic>? body, String lang = 'en'}) async {
    await init();
    if (_apiKey == null) throw const ServerFailure('API Key not initialized');

    final uri = Uri.parse("$_baseUrl?action=$action&lang=$lang");
    final headers = {
      'X-API-Key': _apiKey!,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final response = await (method == 'GET'
              ? client.get(uri, headers: headers)
              : client.post(uri, headers: headers, body: jsonEncode(body)))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ServerFailure('API Request Failed: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
