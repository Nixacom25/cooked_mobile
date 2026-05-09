import 'package:flutter/material.dart';
import '../screens/premium/paywall_screen.dart';
import '../services/paywall_service.dart';
import '../services/auth_service.dart';
import '../core/api_config.dart';

class PaywallHelper {
  static Future<void> show(BuildContext context) async {
    final token = await AuthService.instance.getToken();
    if (token == null) return;

    final paywallService = PaywallService(
      baseUrl: ApiConfig.baseUrl,
      authToken: token,
    );

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: PaywallScreen(paywallService: paywallService),
      ),
    );
  }

  // Vérifie si l'erreur nécessite l'affichage du paywall
  static bool handleError(BuildContext context, dynamic error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('402') || 
        errorStr.contains('payment required') || 
        errorStr.contains('premium required') ||
        errorStr.contains('subscription required')) {
      show(context);
      return true;
    }
    return false;
  }
}
