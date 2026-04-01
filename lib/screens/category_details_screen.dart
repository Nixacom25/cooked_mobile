import 'package:flutter/material.dart';
import 'package:app_ecommerce/models/category.dart';
import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/widgets/global_header.dart';
import 'package:app_ecommerce/widgets/reel_thumbnail_card.dart';
import 'package:app_ecommerce/screens/video_preview_screen.dart';
import 'package:app_ecommerce/widgets/empty_state_widget.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final Category initialCategory;
  final List<Category> allCategories;
  final List<Product> products;

  const CategoryDetailsScreen({
    super.key,
    required this.initialCategory,
    required this.allCategories,
    required this.products,
  });

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  late List<Category> _displayCategories;
  int _selectedCategoryIndex = 0;
  late List<Product> _filteredProducts;
  final String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Build categories list starting with "Tous"
    _displayCategories = [
      Category(id: 'all', name: 'Tous', imageUrl: ''),
      ...widget.allCategories,
    ];

    // Find initial category index if it's not "Tous"
    final initialIndex = _displayCategories.indexWhere(
      (c) => c.name == widget.initialCategory.name,
    );
    if (initialIndex != -1) {
      _selectedCategoryIndex = initialIndex;
    }

    _applyFilters();
  }

  void _onCategoryToggled(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = widget.products.where((product) {
        // Search Filter
        final matchesSearch =
            _searchQuery.isEmpty ||
            product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.keywords.any(
              (k) => k.toLowerCase().contains(_searchQuery.toLowerCase()),
            );
        if (!matchesSearch) return false;

        // Category Filter
        if (_selectedCategoryIndex != 0) {
          // If not "Tous"
          final selectedCatName =
              _displayCategories[_selectedCategoryIndex].name;
          if (product.category != selectedCatName &&
              product.category !=
                  _displayCategories[_selectedCategoryIndex].id) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2832),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Global Header
          GlobalHeader(
            onSearch: (query) {
              // Navigation back to home tabs would normally happen here
            },
          ),

          // Secondary Header: Back Button and Category Title
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
                Text(
                  widget.initialCategory.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2832),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Presentation Section
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?auto=format&fit=crop&q=80',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                          // Présentation Badge
                          Positioned(
                            top: 15,
                            left: 15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Présentation',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Center Play Button
                          const Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 80,
                            ),
                          ),
                          // Video Controls Placeholder
                          Positioned(
                            bottom: 12,
                            left: 12,
                            right: 12,
                            child: Column(
                              children: [
                                // Progress Bar
                                Container(
                                  height: 3,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 3,
                                    width: 120,
                                    color: const Color(0xFFFF6F00),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.pause,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      '0:00 / 0:15',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.volume_up,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 15),
                                    const Icon(
                                      Icons.fullscreen,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 15),
                                    const Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Store Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6F00),
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: const AssetImage(
                                    'assets/images/logo.png',
                                  ), // Mock logo or placeholder
                                  onError: (e, s) {},
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: const Icon(
                                Icons.storefront,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bawane',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E2832),
                                  ),
                                ),
                                Text(
                                  "C'EST LA VIE",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF6F00),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        // 2x2 Grid
                        Row(
                          children: [
                            _buildInfoCard(
                              Icons.location_on_outlined,
                              'ADRESSE',
                              'Jaxay 56',
                            ),
                            const SizedBox(width: 15),
                            _buildInfoCard(
                              Icons.access_time_rounded,
                              'LIVRAISON',
                              'Immédiat',
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            _buildInfoCard(
                              Icons.headset_mic_outlined,
                              'ASSISTANT',
                              'Disponible H24',
                            ),
                            const SizedBox(width: 15),
                            _buildInfoCard(
                              Icons.info_outline_rounded,
                              'À SAVOIR',
                              'Tous nos produits sont neufs...',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Sous catégories
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Sous catégories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2832),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Pills Row
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: _displayCategories.length,
                      itemBuilder: (context, index) {
                        final cat = _displayCategories[index];
                        final isSelected = _selectedCategoryIndex == index;
                        return GestureDetector(
                          onTap: () => _onCategoryToggled(index),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFF6F00)
                                  : const Color(0xFFF0F1F3),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              cat.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1E2832),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  _filteredProducts.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: EmptyStateWidget(
                            icon: Icons.inventory_2_outlined,
                            title: 'Aucun produit',
                            subtitle:
                                'Aucun produit disponible dans cette catégorie.',
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 0.6,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              return ReelThumbnailCard(
                                product: _filteredProducts[index],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      opaque: false,
                                      pageBuilder: (context, _, __) =>
                                          VideoPreviewScreen(
                                            products: _filteredProducts,
                                            initialIndex: index,
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
