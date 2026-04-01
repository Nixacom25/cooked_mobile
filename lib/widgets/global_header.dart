import 'package:flutter/material.dart';
import 'package:app_ecommerce/widgets/search_bar_widget.dart';
import 'package:app_ecommerce/services/cart_service.dart';
import 'package:app_ecommerce/models/cart_item.dart';
import 'package:app_ecommerce/screens/cart_screen.dart';
import 'package:app_ecommerce/services/auth_service.dart';
import 'package:app_ecommerce/widgets/login_modal.dart';
import 'package:app_ecommerce/services/notification_service.dart';
import 'package:app_ecommerce/widgets/notifications_modal.dart';
import 'package:app_ecommerce/models/notification.dart';

class GlobalHeader extends StatelessWidget {
  final Function(String) onSearch;
  final VoidCallback? onNotificationTap;
  final String? initialSearchQuery;

  const GlobalHeader({
    super.key,
    required this.onSearch,
    this.onNotificationTap,
    this.initialSearchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            children: [
              // Row 1: Logo & Notification
              Row(
                children: [
                  // Logo Section
                  Row(
                    children: [
                      SizedBox(
                        height: 48,
                        width: 48,
                        child: Center(
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 48,
                              width: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Text(
                                    '😎',
                                    style: TextStyle(fontSize: 32),
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bawane',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E2832),
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'C\'EST LA VIE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.orange[800],
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Login/Logout Section
                  ValueListenableBuilder<bool>(
                    valueListenable: AuthService().isLoggedIn,
                    builder: (context, isLoggedIn, _) {
                      if (!isLoggedIn) {
                        return GestureDetector(
                          onTap: () => LoginModal.show(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6F00).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFF6F00).withOpacity(0.2),
                              ),
                            ),
                            child: const Text(
                              'CONNEXION',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFF6F00),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () => AuthService().logout(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            size: 20,
                            color: Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 5),
                  // Notification Icon (Always Visible)
                  ValueListenableBuilder<List<NotificationModel>>(
                    valueListenable: NotificationService().notifications,
                    builder: (context, notifications, _) {
                      final bool hasUnread =
                          NotificationService().unreadCount > 0;
                      return GestureDetector(
                        onTap:
                            onNotificationTap ??
                            () => NotificationsModal.show(context),
                        child: Stack(
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              size: 30,
                              color: Color(0xFF1E2832),
                            ),
                            if (hasUnread)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.orange[800],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Row 2: Search Bar & Cart
              ValueListenableBuilder<List<CartItem>>(
                valueListenable: CartService().itemsNotifier,
                builder: (context, items, _) {
                  final count = CartService().uniqueProductCount;
                  return Row(
                    children: [
                      Expanded(
                        child: SearchBarWidget(
                          onSearch: onSearch,
                          hintText: 'Rechercher des produits, catégories...',
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 12),
                        // Cart Icon Wrapper
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartScreen(),
                              ),
                            );
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF1F2F6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Color(0xFF1E2832),
                                  size: 24,
                                ),
                              ),
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF6F00),
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
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
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
