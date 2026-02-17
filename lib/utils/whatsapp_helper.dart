import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  // Replace with actual business number
  static const String _phoneNumber = '221770000000';

  static Future<void> launchWhatsApp({
    required String productTitle,
    required String productPrice,
  }) async {
    final String message =
        'Bonjour, je suis intéressé par ce produit : $productTitle à $productPrice';

    // Create the URL
    // Use 'https://wa.me/' format which is robust
    final Uri whatsappUrl = Uri.parse(
      'https://wa.me/$_phoneNumber?text=${Uri.encodeComponent(message)}',
    );

    try {
      if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch WhatsApp');
      }
    } catch (e) {
      print('Error launching WhatsApp: $e');
      // In a real app, show a snackbar or fallback
    }
  }
}
