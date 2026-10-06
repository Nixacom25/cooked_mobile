import 'package:flutter/material.dart';
import '../screens/premium/paywall_screen.dart';
import '../services/paywall_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../core/api_config.dart';

class PaywallHelper {
  /// Bumped right before the paywall opens. Panels that live in the root
  /// overlay (above every route, e.g. the import search panel) listen and
  /// close, so nothing can ever sit in front of the paywall.
  static final ValueNotifier<int> opening = ValueNotifier<int>(0);

  /// True when [error] means "no active subscription" (402 / 403 gate).
  static bool isSubscriptionError(dynamic error) {
    final s = error.toString().toLowerCase();
    return s.contains('402') || s.contains('payment required') || s.contains('premium required') ||
        s.contains('subscription required') || s.contains('subscription_required');
  }

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

    opening.value++;
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

  static bool _gateOpen = false;
  static DateTime? _lastGateAt;

  /// Called by the network layer when the backend answers
  /// SUBSCRIPTION_REQUIRED: opens the paywall once (several refused calls
  /// in a row must not stack paywalls), from anywhere in the app.
  static void showForExpiredSubscription(BuildContext? context) {
    if (context == null || _gateOpen) return;
    final now = DateTime.now();
    if (_lastGateAt != null && now.difference(_lastGateAt!) < const Duration(seconds: 3)) return;
    _lastGateAt = now;
    _gateOpen = true;
    show(context).whenComplete(() => _gateOpen = false);
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
