import 'package:flutter/material.dart';
import 'package:app_ecommerce/screens/order_details_screen.dart';
import 'package:app_ecommerce/widgets/global_header.dart';
import 'package:app_ecommerce/widgets/empty_state_widget.dart';
import 'package:app_ecommerce/models/order.dart';
import 'package:app_ecommerce/services/order_service.dart';
import 'package:app_ecommerce/services/auth_service.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String selectedFilter = 'En cours';
  List<Order> _allOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final user = AuthService().currentUser.value;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final fetchedOrders = await OrderService.getOrdersByClient(user['id']);
      if (mounted) {
        setState(() {
          _allOrders = fetchedOrders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Order> get filteredOrders {
    if (selectedFilter == 'En cours') {
      return _allOrders
          .where(
            (o) =>
                o.status != OrderStatus.delivered &&
                o.status != OrderStatus.cancelled,
          )
          .toList();
    } else if (selectedFilter == 'Livrés') {
      return _allOrders
          .where((o) => o.status == OrderStatus.delivered)
          .toList();
    } else if (selectedFilter == 'Annulées') {
      return _allOrders
          .where((o) => o.status == OrderStatus.cancelled)
          .toList();
    }
    return _allOrders;
  }

  void _handleGeneralSearch(String query) {
    // When searching from a sub-page, we target the main navigation's search logic.
    // Since we're pushed onto the stack, we'll pop back to MainNavigation and search would normally be there.
    // For now, simplicity: pop and let MainNavigation handle it if we had a way to pass data back.
    // Improved: Navigator.popUntil the root, then we'd need a way to trigger search.
    // Given the current architecture, we'll just implement the visual for now.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          // Persist GlobalHeader
          GlobalHeader(onSearch: _handleGeneralSearch),

          // Sub-Header: Back Button and Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: Color(0xFF1E2832),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                const Text(
                  'Mes Commandes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2832),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Filters / Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('En cours', Icons.local_shipping_outlined),
                const SizedBox(width: 12),
                _buildFilterChip('Livrés', Icons.inventory_2_outlined),
                const SizedBox(width: 12),
                _buildFilterChip('Annulées', Icons.cancel_outlined),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.shopping_basket_outlined,
                    title: 'Aucune commande',
                    subtitle: 'Vous n\'avez pas encore passé de commande.',
                  )
                : RefreshIndicator(
                    onRefresh: _fetchOrders,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return _buildOrderCard(order);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final currencyFormatter = NumberFormat('#,###', 'fr_FR');
    String statusLabel = 'En attente';
    Color statusColor = const Color(0xFF3B82F6);

    switch (order.status) {
      case OrderStatus.pending:
        statusLabel = 'En attente';
        statusColor = const Color(0xFFF59E0B);
        break;
      case OrderStatus.on_the_way:
        statusLabel = 'En cours';
        statusColor = const Color(0xFF3B82F6);
        break;
      case OrderStatus.delivered:
        statusLabel = 'Livrée';
        statusColor = const Color(0xFF059669);
        break;
      case OrderStatus.cancelled:
        statusLabel = 'Annulée';
        statusColor = const Color(0xFFEF4444);
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CMD-${order.id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF1E2832),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat('dd MMM yyyy', 'fr_FR').format(order.createdAt),
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.items.length} article(s)',
                  style: const TextStyle(color: Colors.grey, fontSize: 15),
                ),
                Text(
                  '${currencyFormatter.format(order.totalAmount)} FCFA',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Color(0xFF1E2832),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
