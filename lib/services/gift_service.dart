import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import 'auth_service.dart';

class GiftCode {
  final String id;
  final String code;
  final String plan;
  final String planLabel;
  final String status;
  final String redeemUrl;
  final DateTime? createdAt;

  const GiftCode({
    required this.id,
    required this.code,
    required this.plan,
    required this.planLabel,
    required this.status,
    required this.redeemUrl,
    this.createdAt,
  });

  bool get isAvailable => status == 'AVAILABLE';
  bool get isRedeemed => status == 'REDEEMED';

  factory GiftCode.fromJson(Map<String, dynamic> json) => GiftCode(
        id: json['id'].toString(),
        code: json['code']?.toString() ?? '',
        plan: json['plan']?.toString() ?? '',
        planLabel: json['planLabel']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        redeemUrl: json['redeemUrl']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      );
}

class GiftRedeemResult {
  final String planLabel;
  final DateTime? premiumUntil;

  const GiftRedeemResult({required this.planLabel, this.premiumUntil});
}

/// Gift codes are created by the backend from the store-confirmed purchase
/// (RevenueCat webhook); the app only lists and redeems them.
class GiftService {
  GiftService._privateConstructor();
  static final GiftService instance = GiftService._privateConstructor();

  Future<Map<String, String>> _headers() async {
    final token = await AuthService.instance.getToken();
    return token != null ? ApiConfig.authHeaders(token) : ApiConfig.defaultHeaders;
  }

  Future<List<GiftCode>> getMyGifts() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/gifts/mine'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception('Unable to load your gifts.');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => GiftCode.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<GiftRedeemResult> redeem(String code) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/gifts/redeem'),
      headers: await _headers(),
      body: jsonEncode({'code': code}),
    );
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (response.statusCode == 200) {
      return GiftRedeemResult(
        planLabel: body?['planLabel']?.toString() ?? '',
        premiumUntil: DateTime.tryParse(body?['premiumUntil']?.toString() ?? ''),
      );
    }
    final message = body is Map ? body['message']?.toString() : null;
    throw Exception(message ?? 'Unable to redeem this gift code.');
  }
}
