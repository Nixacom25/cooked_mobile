import 'package:app_ecommerce/models/cart_item.dart';
import 'package:app_ecommerce/models/order_form.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service to generate and send WhatsApp messages
class WhatsAppService {
  // Vendor WhatsApp number (replace with actual number)
  static const String vendorPhone = '+221785304869'; // Updated vendor number

  /// Send general question to vendor
  static Future<void> sendGeneralQuestion() async {
    final message = 'Bonjour,\nJe souhaite poser une question.';
    await _sendWhatsApp(message);
  }

  /// Send order with cart items and client form
  static Future<void> sendOrder({
    required List<CartItem> items,
    required OrderForm form,
  }) async {
    final message = _generateOrderMessage(items, form);
    await _sendWhatsApp(message);
  }

  /// Generate formatted order message
  static String _generateOrderMessage(List<CartItem> items, OrderForm form) {
    final buffer = StringBuffer();

    buffer.writeln('Bonjour,');
    buffer.writeln('Je souhaite passer une commande.\n');

    // Products section
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      buffer.writeln('📦 PRODUIT ${i + 1}');
      buffer.writeln('Nom du produit : ${item.product.title}');
      buffer.writeln('Catégorie : ${item.product.category}');
      // buffer.writeln('Lien du produit : ${item.product.videoUrl}'); // Optional
      buffer.writeln('🔢 Quantité : ${item.quantity}');
      buffer.writeln();

      // Service chosen
      buffer.writeln('🔧 SERVICE CHOISI');
      if (item.includeInstallation && item.product.hasInstallationOption) {
        buffer.writeln('Livraison + montage');
      } else {
        buffer.writeln('Livraison uniquement');
      }
      buffer.writeln();

      // Price detail
      buffer.writeln('💰 DÉTAIL DU PRIX');
      buffer.writeln('Prix du produit : ${item.formattedSubtotal}');
      buffer.writeln('Frais de livraison : ${item.formattedDeliveryFee}');
      if (item.includeInstallation && item.product.hasInstallationOption) {
        buffer.writeln('Frais de montage : ${item.formattedInstallationFee}');
      }
      buffer.writeln('─────────────────');
      buffer.writeln('TOTAL : ${item.formattedTotal}');
      buffer.writeln();
    }

    // Grand total
    if (items.length > 1) {
      final grandTotal = items.fold(0, (sum, item) => sum + item.total);
      final formattedGrandTotal = items.first.formatPrice(grandTotal);
      buffer.writeln('💰 TOTAL À PAYER : $formattedGrandTotal');
      buffer.writeln();
    }

    // Client information
    buffer.writeln('👤 INFORMATIONS CLIENT');
    buffer.writeln('Nom : ${form.lastName}');
    buffer.writeln('Prénom : ${form.firstName}');
    buffer.writeln('Numéro principal : ${form.primaryPhone}');
    if (form.secondaryPhone != null && form.secondaryPhone!.isNotEmpty) {
      buffer.writeln('Deuxième numéro : ${form.secondaryPhone}');
    }
    buffer.writeln();

    // Location
    buffer.writeln('📍 LOCALISATION');
    buffer.writeln('Lien Google Maps : ${form.googleMapsLink ?? "Non fourni"}');
    buffer.writeln();

    // Delivery date
    buffer.writeln('📅 DATE DE LIVRAISON');
    buffer.writeln(form.deliveryDateText);
    buffer.writeln();

    // Delivery time
    buffer.writeln('⏰ HEURE DE LIVRAISON');
    buffer.writeln(form.deliveryTimeText);
    buffer.writeln();

    // Comments
    if (form.comments != null && form.comments!.isNotEmpty) {
      buffer.writeln('📝 COMMENTAIRES');
      buffer.writeln(form.comments);
    }

    return buffer.toString();
  }

  /// Send WhatsApp message
  static Future<void> _sendWhatsApp(String message) async {
    // Format phone number (remove + and spaces)
    final phone = vendorPhone.replaceAll(RegExp(r'[^\d]'), '');

    // 1. Try Native WhatsApp URL Scheme first (whatsapp://send?phone=...)
    final nativeUrl = Uri.parse(
      'whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}',
    );

    // 2. Fallback Web/Universal Link (https://wa.me/...)
    final webUrl = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );

    try {
      if (await canLaunchUrl(nativeUrl)) {
        await launchUrl(nativeUrl);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        // Last resort: try launching webUrl in browser without specific mode
        await launchUrl(webUrl, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      print('Error launching WhatsApp: $e');
      throw Exception(
        'Impossible d\'ouvrir WhatsApp. Vérifiez s\'il est installé.',
      );
    }
  }
}
