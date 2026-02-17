import 'package:flutter/material.dart';
import 'package:app_ecommerce/utils/constants.dart';
import 'package:app_ecommerce/data/mock_database.dart';
import 'package:app_ecommerce/screens/order_details_screen.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Order History Data
    final List<Map<String, dynamic>> orders = [
      {
        'id': '#CMD-2024-001',
        'date': '2 Fév 2026',
        'status': 'En cours',
        'total': '35 000 FCFA',
        'items': [MockDatabase.products[0], MockDatabase.products[1]],
      },
      {
        'id': '#CMD-2024-002',
        'date': '28 Jan 2026',
        'status': 'Livré',
        'total': '12 500 FCFA',
        'items': [MockDatabase.products[2]],
      },
      {
        'id': '#CMD-2024-003',
        'date': '15 Jan 2026',
        'status': 'Livré',
        'total': '45 000 FCFA',
        'items': [MockDatabase.products[0], MockDatabase.products[3]],
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.primary, // Dark Background
      appBar: AppBar(
        title: const Text(
          'Mes Activités',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final statusColor = order['status'] == 'Livré'
              ? AppColors.success
              : AppColors.accent;
          final statusIcon = order['status'] == 'Livré'
              ? Icons.check_circle
              : Icons.local_shipping;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight, // Dark Card
              borderRadius: BorderRadius.circular(12),
              // Removed shadow for flat dark mode look, or keep subtle black shadow
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: ID + Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order['id'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white, // White text
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2), // Darker opacity
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            order['status'],
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Commandé le ${order['date']}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ), // Grey text
                ),
                const Divider(
                  height: 24,
                  color: Colors.white24,
                ), // Light divider
                // Products Preview
                Row(
                  children: [
                    ...List.generate((order['items'] as List).length, (i) {
                      final product = (order['items'] as List)[i];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(product.thumbnailUrl ?? ''),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }),
                    if ((order['items'] as List).length > 3)
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white12, // Dark placeholder
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            '+2',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Footer: Total + Re-order button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        Text(
                          order['total'],
                          style: const TextStyle(
                            color: AppColors.accent, // Orange total
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailsScreen(order: order),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(color: Colors.white24),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Détails'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
