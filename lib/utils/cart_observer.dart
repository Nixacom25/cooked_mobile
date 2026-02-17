import 'package:flutter/material.dart';
import 'package:app_ecommerce/widgets/floating_cart_overlay.dart';

class CartVisibilityObserver extends NavigatorObserver {
  static final List<String> _hiddenRoutes = [
    '/validation',
    '/status_view',
    '/cart_popup',
    '/map_picker',
  ];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateVisibility(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _updateVisibility(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _updateVisibility(newRoute);
    }
  }

  void _updateVisibility(Route<dynamic> route) {
    // Check if the route name is in our hidden list
    final bool shouldHide = _hiddenRoutes.contains(route.settings.name);

    // Also check for specific screen types if names aren't used correctly
    // But using names is more reliable if we set them.

    FloatingCartOverlay.isFloatingCartVisible.value = !shouldHide;
  }
}
