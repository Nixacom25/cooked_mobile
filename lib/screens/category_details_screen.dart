import 'package:flutter/material.dart';
import 'package:app_ecommerce/models/category.dart';
import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/utils/constants.dart';
import 'package:app_ecommerce/widgets/dark_product_card.dart';
import 'package:app_ecommerce/screens/video_preview_screen.dart';
import 'package:app_ecommerce/widgets/filter_modal.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final Category initialCategory;
  final List<Category> allCategories;
  final List<Product>
  products; // In real app, this would be fetched based on category

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
  late Category _selectedCategory;
  late List<Product> _filteredProducts;

  // Filter State
  RangeValues _priceRange = const RangeValues(0, 500000);
  List<String> _selectedCategories = [];
  bool _showPromoOnly = false;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _selectedCategories = [
      widget.initialCategory.name,
    ]; // Default to the category we came from
    _applyFilters();
  }

  void _onCategoryToggled(Category category) {
    setState(() {
      _selectedCategories = [category.name];
      _selectedCategory = category;
      FocusScope.of(context).unfocus();
      _applyFilters();
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        allCategories: widget.allCategories,
        initialPriceRange: _priceRange,
        initialSelectedCategories: _selectedCategories,
        initialShowPromoOnly: _showPromoOnly,
        onApply: (priceRange, selectedCats, showPromo) {
          setState(() {
            _priceRange = priceRange;
            _selectedCategories = selectedCats;
            _showPromoOnly = showPromo;
            _applyFilters();
          });
        },
      ),
    );
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

        // Price Filter
        final price = product.numericPrice;
        if (price < _priceRange.start || price > _priceRange.end) {
          return false;
        }

        // Category Filter
        if (_selectedCategories.isNotEmpty) {
          final categoryMatch = widget.allCategories.any((cat) {
            return _selectedCategories.contains(cat.name) &&
                (product.category == cat.name || product.category == cat.id);
          });
          if (!categoryMatch) return false;
        }

        // Promo Filter
        if (_showPromoOnly &&
            (product.promoLabel == null || product.promoLabel!.isEmpty)) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header: Category Title + Filter
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black, // Dark icon for white bg
                      ),
                    ),
                    Text(
                      _selectedCategory.name.replaceAll('\n', ' '),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Dark text
                      ),
                    ),
                    IconButton(
                      onPressed: _showFilterModal, // Open Filter Modal
                      icon: const Icon(
                        Icons.tune,
                        color: Colors.black, // Dark icon
                      ),
                    ),
                  ],
                ),
              ),

              // Category Switcher
              SizedBox(
                height: 40,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.allCategories.length,
                  itemBuilder: (context, index) {
                    final cat = widget.allCategories[index];
                    final isSelected = _selectedCategories.contains(cat.name);
                    return GestureDetector(
                      onTap: () => _onCategoryToggled(cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat.name.replaceAll('\n', ' '),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Product Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600
                        ? 3
                        : 2,
                    childAspectRatio: 0.7, // Slightly taller for better fit
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    return DarkProductCard(
                      product: _filteredProducts[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (context, _, __) => VideoPreviewScreen(
                              products: _filteredProducts,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      width: double.infinity,
                      height: double.infinity,
                      margin: EdgeInsets.zero,
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
}
