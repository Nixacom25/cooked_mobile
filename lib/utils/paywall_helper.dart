import 'package:flutter/material.dart';
import '../screens/premium/paywall_screen.dart';
import '../services/paywall_service.dart';
import '../services/auth_service.dart';
import '../core/api_config.dart';

class PaywallHelper {
  static Future<void> show(BuildContext context, {PaywallFlowType flowType = PaywallFlowType.standard}) async {
    final token = await AuthService.instance.getToken();
    if (token == null) return;

    final paywallService = PaywallService(
      baseUrl: ApiConfig.baseUrl,
      authToken: token,
    );

    if (!context.mounted) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaywallScreen(
          paywallService: paywallService,
          flowType: flowType,
        ),
        fullscreenDialog: true,
      ),
    );

    // If dismissed without purchase and was standard flow, show the offer flow
    if (result != true && flowType == PaywallFlowType.standard) {
      if (context.mounted) {
        // Short delay for smoother transition
        await Future.delayed(const Duration(milliseconds: 300));
        if (context.mounted) {
          show(context, flowType: PaywallFlowType.offer);
        }
      }
    }
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
