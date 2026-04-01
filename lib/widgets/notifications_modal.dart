import 'package:flutter/material.dart';
import 'package:app_ecommerce/models/notification.dart';
import 'package:app_ecommerce/services/notification_service.dart';
import 'package:intl/intl.dart';

// Screens for navigation
import 'package:app_ecommerce/screens/orders_screen.dart';
import 'package:app_ecommerce/screens/invoices_screen.dart';
import 'package:app_ecommerce/screens/reviews_list_screen.dart';

class NotificationsModal extends StatefulWidget {
  const NotificationsModal({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notifications',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const NotificationsModal(),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutQuart)),
          child: child,
        );
      },
    );
  }

  @override
  State<NotificationsModal> createState() => _NotificationsModalState();
}

class _NotificationsModalState extends State<NotificationsModal> {
  @override
  void initState() {
    super.initState();
    NotificationService().fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(-5, 0),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              bottomLeft: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 60, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: Color(0xFFFF6F00),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Alertes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E2832),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Action Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ValueListenableBuilder<List<NotificationModel>>(
                      valueListenable: NotificationService().notifications,
                      builder: (context, items, _) {
                        final unread = NotificationService().unreadCount;
                        return Text(
                          unread > 0 ? '$unread non lues' : 'Toutes lues',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                    TextButton.icon(
                      onPressed: () => NotificationService().markAllAsRead(),
                      icon: const Icon(Icons.done_all_rounded, size: 16),
                      label: const Text('Tout marquer'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFF6F00),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Notification List
              Expanded(
                child: ValueListenableBuilder<List<NotificationModel>>(
                  valueListenable: NotificationService().notifications,
                  builder: (context, items, _) {
                    if (items.isEmpty) {
                      return _buildEmptyState();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _NotificationCard(notification: items[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Rien à signaler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E2832),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous recevrez ici vos alertes de commandes\net nos meilleurs bons plans.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final bool isRead = notification.isRead;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isRead ? Colors.white.withOpacity(0.5) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isRead
                    ? Colors.transparent
                    : const Color(0xFFFF6F00).withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: [
                if (!isRead)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon with glow
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getIconColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_getIcon(), color: _getIconColor(), size: 22),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: isRead
                                    ? const Color(0xFF1E2832).withOpacity(0.6)
                                    : const Color(0xFF1E2832),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          Text(
                            _formatShortTime(notification.timestamp),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isRead ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isRead)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6F00),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.product:
        return Icons.rocket_launch_rounded;
      case NotificationType.order:
        return Icons.local_shipping_rounded;
      case NotificationType.invoice:
        return Icons.receipt_long_rounded;
      case NotificationType.review:
        return Icons.stars_rounded;
      case NotificationType.payment:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case NotificationType.product:
        return const Color(0xFF8E24AA);
      case NotificationType.order:
        return const Color(0xFF1976D2);
      case NotificationType.invoice:
        return const Color(0xFF388E3C);
      case NotificationType.review:
        return const Color(0xFFFF6F00);
      case NotificationType.payment:
        return const Color(0xFF00796B);
    }
  }

  String _formatShortTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    if (diff.inHours < 24) return "${diff.inHours}h";
    return DateFormat('dd MMM').format(dt);
  }

  void _handleTap(BuildContext context) {
    NotificationService().markAsRead(notification.id);
    Navigator.pop(context); // Close modal

    // Navigate to page
    Widget? targetScreen;
    switch (notification.type) {
      case NotificationType.order:
        targetScreen = const OrdersScreen();
        break;
      case NotificationType.payment:
      case NotificationType.invoice:
        targetScreen = const InvoicesScreen();
        break;
      case NotificationType.review:
        targetScreen = const ReviewsListScreen();
        break;
      case NotificationType.product:
        // By default go home to see products
        break;
    }

    if (targetScreen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetScreen!),
      );
    }
  }
}
