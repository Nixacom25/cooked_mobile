import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/services/product_service.dart';
import 'package:app_ecommerce/screens/reels_viewer_screen.dart';
import 'package:app_ecommerce/widgets/dark_product_card.dart';
import 'package:app_ecommerce/widgets/empty_state_widget.dart';
import 'package:app_ecommerce/utils/constants.dart';
import 'package:app_ecommerce/services/auth_service.dart';

class ReelsScreen extends StatefulWidget {
  final String? searchQuery;
  const ReelsScreen({super.key, this.searchQuery});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen>
    with SingleTickerProviderStateMixin {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _error;

  String _selectedCategory = 'Tous';
  List<String> _categories = ['Tous'];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    // Refresh every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted &&
          (widget.searchQuery == null || widget.searchQuery!.isEmpty)) {
        _loadProducts();
      }
    });
  }

  @override
  void didUpdateWidget(ReelsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _applyFilters();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      if (_allProducts.isEmpty) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final user = AuthService().currentUser.value;
      final clientId = user != null
          ? '${user['firstName']} ${user['lastName']}'
          : 'client123';

      final products = await ProductService.getProducts(clientId: clientId);

      if (mounted) {
        setState(() {
          _allProducts = products;

          // Extract unique categories
          final uniqueCategories = products
              .map((p) => p.category)
              .where((c) => c.isNotEmpty)
              .toSet()
              .toList();
          uniqueCategories.sort();
          _categories = ['Tous', ...uniqueCategories];

          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Erreur lors du chargement des produits";
          _isLoading = false;
        });
      }
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _applyFilters() {
    final query = (widget.searchQuery ?? "").toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        final matchesQuery =
            p.title.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query) ||
            p.keywords.any((k) => k.toLowerCase().contains(query));
        final matchesCategory =
            _selectedCategory == 'Tous' || p.category == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Découvrir',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E2832),
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Categories
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => _onCategorySelected(category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1E2832)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Products Grid
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _allProducts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_error != null && _allProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: const Text(
                "Réessayer",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.search_off,
        title: "Aucun produit trouvé",
        subtitle: "Essayez de modifier votre recherche ou catégorie.",
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _filteredProducts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return DarkProductCard(
          product: product,
          margin: EdgeInsets.zero,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReelsViewerScreen(
                  products: _filteredProducts,
                  initialIndex: index,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
