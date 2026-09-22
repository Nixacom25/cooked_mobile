import 'package:flutter/material.dart';
import '../screens/premium/paywall_screen.dart';
import '../services/paywall_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../core/api_config.dart';

class PaywallHelper {
  static Future<void> show(BuildContext context, {PaywallFlowType flowType = PaywallFlowType.standard}) async {
    final token = await AuthService.instance.getToken();
    if (token == null) return;

    // Check if user is creator, admin, or editor - they should not see paywall
    final user = UserService.instance.currentUserNotifier.value;
    if (user != null && (user['role'] == 'CREATOR' || user['role'] == 'ADMIN' || user['role'] == 'EDITOR' || user['subscriptionStatus'] == 'INFINITE')) {
      return; // Creators, Admins, Editors, and INFINITE users don't see paywall
    }

    final paywallService = PaywallService(
      baseUrl: ApiConfig.baseUrl,
      authToken: token,
    );

    if (!context.mounted) return;

    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaywallScreen(
          paywallService: paywallService,
          flowType: flowType,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  // Vérifie si l'erreur nécessite l'affichage du paywall
  static bool handleError(BuildContext context, dynamic error) {
    // Check if user is creator, admin, or editor - they should not see paywall even on errors
    final user = UserService.instance.currentUserNotifier.value;
    if (user != null && (user['role'] == 'CREATOR' || user['role'] == 'ADMIN' || user['role'] == 'EDITOR' || user['subscriptionStatus'] == 'INFINITE')) {
      return false; // Creators, Admins, Editors, and INFINITE users don't see paywall even on errors
    }

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
