import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/services/product_service.dart';
import 'package:app_ecommerce/widgets/dark_product_card.dart';
import 'package:app_ecommerce/screens/video_preview_screen.dart';
import 'package:app_ecommerce/utils/constants.dart';

class DealsScreen extends StatefulWidget {
  const DealsScreen({super.key});

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  List<Product> _allDeals = [];
  bool _isLoading = true;
  String? _error;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadDeals();
    // Refresh every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadDeals();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadDeals() async {
    try {
      if (_allDeals.isEmpty) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final products = await ProductService.getProducts();

      final promoProducts = products
          .where((p) => p.originalPrice != null || p.promoLabel != null)
          .toList();

      if (mounted) {
        setState(() {
          _allDeals = promoProducts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Erreur lors du chargement des offres";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '🔥 Offres Spéciales',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadDeals,
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDeals,
              child: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    if (_allDeals.isEmpty) {
      return const Center(
        child: Text(
          "Aucune offre spéciale pour le moment.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final flashSales = _allDeals.take(3).toList();
    final otherPromos = _allDeals.skip(3).toList();
    final gridProducts = otherPromos.isNotEmpty ? otherPromos : _allDeals;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (flashSales.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.flash_on, color: Colors.orange, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'VENTES FLASH',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Fin dans 02:45:12',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 260,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: flashSales.length,
                itemBuilder: (context, index) {
                  final product = flashSales[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 160,
                      child: DarkProductCard(
                        product: product,
                        onTap: () => _openProduct(context, product),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: const [
                Icon(Icons.discount, color: Colors.purple, size: 24),
                SizedBox(width: 8),
                Text(
                  'TOUTES LES PROMOS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: gridProducts.length,
            itemBuilder: (context, index) {
              final product = gridProducts[index];
              return DarkProductCard(
                product: product,
                onTap: () => _openProduct(context, product),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _openProduct(BuildContext context, Product product) {
    final index = _allDeals.indexOf(product);
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) =>
            VideoPreviewScreen(products: _allDeals, initialIndex: index),
      ),
    );
  }
}
