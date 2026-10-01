import 'package:flutter/material.dart';

import '../core/widgets/ios_toast.dart';
import '../routes/app_routes.dart';
import '../screens/onboarding/onboarding_screen.dart';
import 'revenuecat_service.dart';
import 'user_service.dart';

/// Where a signed-in user goes (after login or on app start):
/// - account created but onboarding abandoned at the subscription step
///   → back into onboarding at that step (the only case that is blocked);
/// - everyone else, including lapsed subscriptions → Home. Premium actions
///   then open the paywall on their own (see SubscriptionAwareClient).
class AccountRouter {
  static Future<void> routeSignedInUser(NavigatorState nav, {bool announce = true}) async {
    // Fresh subscription state from RevenueCat first (bounded, so a slow
    // store can never hold the user on the login/splash screen).
    try {
      await RevenueCatService.instance.identifyNow().timeout(const Duration(seconds: 5));
    } catch (_) {}

    final user = UserService.instance.currentUserNotifier.value;
    // Older backends don't send the flag: treat as completed.
    final completed = user?['onboardingCompleted'] != false;

    if (!completed && !UserService.instance.isPremium) {
      if (announce) {
        final ctx = nav.context;
        IosToast.show(
          ctx,
          message: 'Your account isn\'t finished yet - complete the last step to start cooking.',
          type: ToastType.warning,
        );
      }
      nav.pushNamedAndRemoveUntil(
        AppRoutes.preferences,
        (route) => false,
        arguments: {'resumeAtPage': OnboardingScreen.subscriptionStartPage},
      );
      return;
    }

    nav.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }
}
