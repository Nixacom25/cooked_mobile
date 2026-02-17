import 'package:app_ecommerce/models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  bool includeInstallation; // Livraison + Montage ?

  CartItem({
    required this.product,
    this.quantity = 1,
    this.includeInstallation = false,
  });

  // Product subtotal (price × quantity)
  int get subtotal => product.numericPrice * quantity;

  // Delivery fee (same regardless of quantity)
  int get deliveryFee => product.deliveryFee;

  // Installation fee (if selected and available)
  int get installationFee {
    if (!includeInstallation || !product.hasInstallationOption) {
      return 0;
    }
    return product.installationFee;
  }

  // Total for this item
  int get total => subtotal + deliveryFee + installationFee;

  // Format price with FCFA
  String formatPrice(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} FCFA';
  }

  String get formattedSubtotal => formatPrice(subtotal);
  String get formattedDeliveryFee => formatPrice(deliveryFee);
  String get formattedInstallationFee => formatPrice(installationFee);
  String get formattedTotal => formatPrice(total);
}
