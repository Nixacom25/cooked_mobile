import 'package:flutter/material.dart';
import 'package:app_ecommerce/services/cart_service.dart';
import 'package:app_ecommerce/widgets/cart_modal.dart';
import 'package:app_ecommerce/models/cart_item.dart';

class FloatingCartOverlay extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  // Global control for visibility
  static final ValueNotifier<bool> isFloatingCartVisible = ValueNotifier<bool>(
    true,
  );

  const FloatingCartOverlay({super.key, required this.navigatorKey});

  @override
  State<FloatingCartOverlay> createState() => _FloatingCartOverlayState();
}

class _FloatingCartOverlayState extends State<FloatingCartOverlay> {
  Offset? position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (position == null) {
      final size = MediaQuery.of(context).size;
      // Default to Bottom-Right
      position = Offset(size.width - 80, size.height - 130);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: FloatingCartOverlay.isFloatingCartVisible,
      builder: (context, isVisible, child) {
        if (!isVisible) return const SizedBox.shrink();

        return ValueListenableBuilder<List<CartItem>>(
          valueListenable: CartService().itemsNotifier,
          builder: (context, items, _) {
            if (items.isEmpty) return const SizedBox.shrink();

            int count = 0;
            for (var i in items) count += i.quantity;

            // Ensure position is valid (handling screen rotation/resize)
            final size = MediaQuery.of(context).size;
            final safeWidth = size.width - 60;
            final safeHeight = size.height - 100;

            if (position != null) {
              double dx = position!.dx.clamp(0.0, safeWidth);
              double dy = position!.dy.clamp(0.0, safeHeight);
              if (dx != position!.dx || dy != position!.dy) {
                position = Offset(dx, dy);
              }
            } else {
              position = Offset(size.width - 80, size.height - 150);
            }

            return Stack(
              children: [
                Positioned(
                  left: position!.dx,
                  top: position!.dy,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        final size = MediaQuery.of(context).size;
                        final maxX = size.width - 60;
                        final maxY = size.height - 100;

                        double newX = position!.dx + details.delta.dx;
                        double newY = position!.dy + details.delta.dy;

                        position = Offset(
                          newX.clamp(0.0, maxX),
                          newY.clamp(0.0, maxY),
                        );
                      });
                    },
                    onTap: () async {
                      final navContext =
                          widget.navigatorKey.currentState?.context;
                      if (navContext != null) {
                        // Show Centered Dialog (Popup)
                        await showDialog(
                          context: navContext,
                          routeSettings: const RouteSettings(
                            name: '/cart_popup',
                          ),
                          builder: (context) => const CartPopup(),
                        );
                      }
                    },
                    child: _buildCartButton(count),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCartButton(int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Circular Main Button
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFE65100), // Orange
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.shopping_cart, color: Colors.white, size: 28),
        ),

        // Badge
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
