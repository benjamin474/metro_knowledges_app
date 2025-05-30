import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TdxAuth {
  static String? _accessToken;
  static DateTime? _expiresAt;

  static Future<String> getToken() async {
    if (_accessToken != null && _expiresAt != null && DateTime.now().isBefore(_expiresAt!)) {
      return _accessToken!;
    }

    final clientId = dotenv.env['TDX_CLIENT_ID']!;
    final clientSecret = dotenv.env['TDX_CLIENT_SECRET']!;
    final response = await http.post(
      Uri.parse('https://tdx.transportdata.tw/auth/realms/TDXConnect/protocol/openid-connect/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      _expiresAt = DateTime.now().add(Duration(seconds: data['expires_in']));
      return _accessToken!;
    } else {
      throw Exception('取得 Access Token 失敗');
    }
  }
}
