import 'package:flutter/material.dart';
import 'package:app_ecommerce/screens/review_form_screen.dart';
import 'package:app_ecommerce/widgets/global_header.dart';
import 'package:app_ecommerce/widgets/empty_state_widget.dart';
import 'package:app_ecommerce/services/order_service.dart';
import 'package:app_ecommerce/services/auth_service.dart';
import 'package:app_ecommerce/models/order.dart';

class ReviewsListScreen extends StatefulWidget {
  const ReviewsListScreen({super.key});

  @override
  State<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends State<ReviewsListScreen> {
  List<Order> _deliveredOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final clientId = AuthService().currentUser.value?['id'];
    if (clientId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final orders = await OrderService.getOrdersByClient(clientId);
    if (mounted) {
      setState(() {
        // Filter for orders that are DELIVERED or COMPLETED to allow reviews
        _deliveredOrders = orders
            .where(
              (o) =>
                  o.status == OrderStatus.delivered ||
                  o.status == OrderStatus.confirmed,
            )
            .toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          // Global Header
          GlobalHeader(
            onSearch: (query) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),

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
                  'Je donne mon avis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2832),
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFF6F00),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6F00)),
                  )
                : _deliveredOrders.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.rate_review_outlined,
                    title: 'Aucun avis à donner',
                    subtitle:
                        'Une fois vos produits livrés, vous pourrez laisser un avis ici.',
                  )
                : RefreshIndicator(
                    onRefresh: _fetchOrders,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Sélectionnez une commande livrée pour laisser un avis.',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _deliveredOrders.length,
                            itemBuilder: (context, index) {
                              final order = _deliveredOrders[index];

                              return Container(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '#${order.id.substring(0, 8).toUpperCase()}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Color(0xFF1E2832),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDCFCE7),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Text(
                                            order.status ==
                                                    OrderStatus.delivered
                                                ? 'Livré'
                                                : 'Confirmé',
                                            style: const TextStyle(
                                              color: Color(0xFF16A34A),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Divider(
                                        height: 1,
                                        color: Color(0xFFF1F5F9),
                                      ),
                                    ),
                                    Text(
                                      '${order.items.length} article(s) - ${order.totalAmount.toStringAsFixed(0)} FCFA',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ReviewFormScreen(
                                                    order: order.toJson(),
                                                  ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.star_border,
                                          size: 20,
                                          color: Color(0xFFFF6F00),
                                        ),
                                        label: const Text(
                                          'Laisser un avis',
                                          style: TextStyle(
                                            color: Color(0xFFFF6F00),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFFFF4EB,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 0,
                                          side: const BorderSide(
                                            color: Color(0xFFFF6F00),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
