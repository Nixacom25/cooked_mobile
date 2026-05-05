import 'package:flutter/material.dart';
import '../screens/premium/paywall_screen.dart';
import '../services/paywall_service.dart';

class PaywallHelper {
  static void show(BuildContext context, PaywallService paywallService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: PaywallScreen(paywallService: paywallService),
      ),
    );
  }

  // Vérifie si la réponse API nécessite l'affichage du paywall
  static bool handleApiResponse(BuildContext context, int statusCode, PaywallService paywallService) {
    if (statusCode == 402) {
      show(context, paywallService);
      return true;
    }
    return false;
  }
}
