import 'package:flutter/material.dart';
import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/models/cart_item.dart';

class CartService {
  // Singleton
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final ValueNotifier<List<CartItem>> itemsNotifier = ValueNotifier([]);
  // Using int for total to match CartItem model
  final ValueNotifier<int> totalNotifier = ValueNotifier(0);

  List<CartItem> get items => itemsNotifier.value;

  // --- Actions ---

  // Compatibility Alias
  void addProduct(
    Product product, {
    int quantity = 1,
    bool includeInstallation = false,
  }) {
    addToCart(
      product,
      quantity: quantity,
      includeInstallation: includeInstallation,
    );
  }

  void addToCart(
    Product product, {
    int quantity = 1,
    bool includeInstallation = false,
  }) {
    List<CartItem> currentItems = List.from(itemsNotifier.value);

    final index = currentItems.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (index >= 0) {
      currentItems[index].quantity += quantity;
      // If the new addition requests installation, ensure it is enabled.
      // If not, we leave it as is (don't disable if already enabled).
      if (includeInstallation) {
        currentItems[index].includeInstallation = true;
      }
    } else {
      currentItems.add(
        CartItem(
          product: product,
          quantity: quantity,
          includeInstallation: includeInstallation,
        ),
      );
    }

    itemsNotifier.value = currentItems;
    _updateTotal();
  }

  // Compatibility Alias
  void removeProduct(Product product) => removeFromCart(product);

  void removeFromCart(Product product) {
    List<CartItem> currentItems = List.from(itemsNotifier.value);

    final index = currentItems.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (index >= 0) {
      if (currentItems[index].quantity > 1) {
        currentItems[index].quantity--;
      } else {
        currentItems.removeAt(index);
      }
      itemsNotifier.value = currentItems;
      _updateTotal();
    }
  }

  void removeItemCompletely(Product product) {
    List<CartItem> currentItems = List.from(itemsNotifier.value);
    currentItems.removeWhere((item) => item.product.id == product.id);
    itemsNotifier.value = currentItems;
    _updateTotal();
  }

  // Compatibility Alias
  void clear() => clearCart();

  void clearCart() {
    itemsNotifier.value = [];
    _updateTotal();
  }

  void updateQuantity(Product product, int quantity) {
    List<CartItem> currentItems = List.from(itemsNotifier.value);
    final index = currentItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (quantity <= 0) {
      removeItemCompletely(product);
      return;
    }

    if (index >= 0) {
      currentItems[index].quantity = quantity;
      itemsNotifier.value = currentItems;
      _updateTotal();
    } else {
      // Logic if updating quantity for non-existent item (add it)
      addToCart(product, quantity: quantity);
    }
  }

  void _updateTotal() {
    int total = 0;
    for (var item in itemsNotifier.value) {
      total += item.total;
    }
    totalNotifier.value = total;
  }

  // --- Getters for Legacy Screens (Checkout, CartScreen) ---

  int get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  int get totalInstallationFees =>
      items.fold(0, (sum, item) => sum + item.installationFee);
  int get grandTotal => items.fold(0, (sum, item) => sum + item.total);

  String formatPrice(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} FCFA';
  }

  String get formattedSubtotal => formatPrice(subtotal);
  String get formattedInstallationFees => formatPrice(totalInstallationFees);
  String get formattedGrandTotal => formatPrice(grandTotal);
}
