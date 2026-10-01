import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/subscription_payment.dart';
import 'auth_service.dart';
import '../core/l10n/l10n.dart';

class SubscriptionService {
  SubscriptionService._privateConstructor();
  static final SubscriptionService instance =
      SubscriptionService._privateConstructor();

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.instance.getToken();
    return {
      ...ApiConfig.defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getPlan() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/subscriptions/plan');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load subscription plan');
    }
  }

  Future<Map<String, dynamic>> getMySubscription() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/subscriptions/me');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load subscription status');
    }
  }

  Future<void> paySubscription({
    required bool isYearly,
    required String stripeToken,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/subscriptions/pay');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({'isYearly': isYearly, 'stripeToken': stripeToken}),
    );

    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? appL10n.errPayment);
    }
  }

  Future<void> verifyReceipt({
    required String productId,
    required String purchaseToken,
    required String platform,
    String? packageName,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/subscriptions/verify-receipt');
    final body = jsonEncode({
      'productId': productId,
      'purchaseToken': purchaseToken,
      'platform': platform,
      'packageName': packageName ?? 'com.cookedapp.app', // Fallback or use package_info
    });


    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: body,
    );

    if (response.statusCode == 200) {
    } else {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? appL10n.errVerification);
    }
  }

  Future<List<SubscriptionPayment>> getPaymentHistory() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/subscriptions/history');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .map((json) => SubscriptionPayment.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load payment history');
    }
  }
}
