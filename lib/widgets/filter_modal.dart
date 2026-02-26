import 'package:flutter/material.dart';
import 'package:app_ecommerce/utils/constants.dart';
import 'package:app_ecommerce/models/category.dart';

class FilterModal extends StatefulWidget {
  final List<Category> allCategories;
  final RangeValues initialPriceRange;
  final List<String> initialSelectedCategories; // Names of selected categories
  final bool initialShowPromoOnly;
  final Function(RangeValues, List<String>, bool) onApply;

  const FilterModal({
    super.key,
    required this.allCategories,
    required this.initialPriceRange,
    required this.initialSelectedCategories,
    required this.initialShowPromoOnly,
    required this.onApply,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late RangeValues _priceRange;
  late List<String> _selectedCategories;
  late bool _showPromoOnly;
  String _categorySearchQuery = '';

  @override
  void initState() {
    super.initState();
    _priceRange = widget.initialPriceRange;
    _selectedCategories = List.from(widget.initialSelectedCategories);
    _showPromoOnly = widget.initialShowPromoOnly;
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = widget.allCategories
        .where(
          (c) =>
              c.name.toLowerCase().contains(_categorySearchQuery.toLowerCase()),
        )
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtres',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Dark text
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _priceRange = const RangeValues(0, 500000);
                      _selectedCategories.clear();
                      _showPromoOnly = false;
                      _categorySearchQuery = '';
                    });
                  },
                  child: const Text(
                    'Réinitialiser',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price Range
                    const Text(
                      'Fourchette de prix (FCFA)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 500000,
                      divisions: 100,
                      activeColor: AppColors.accent,
                      inactiveColor: Colors.grey.shade300,
                      labels: RangeLabels(
                        '${_priceRange.start.round()}',
                        '${_priceRange.end.round()}',
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _priceRange = values;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_priceRange.start.round()} FCFA',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        Text(
                          '${_priceRange.end.round()} FCFA',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Categories
                    const Text(
                      'Catégorie', // Singular since only one can be selected
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher une catégorie...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.accent),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _categorySearchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: filteredCategories.map((category) {
                        final isSelected = _selectedCategories.contains(
                          category.name,
                        );
                        return FilterChip(
                          label: Text(category.name),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.accent,
                          backgroundColor: Colors.grey.shade100,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.accent
                                : Colors.grey.shade300,
                          ),
                          checkmarkColor: Colors.white,
                          showCheckmark: true,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategories = [category.name];
                              } else {
                                _selectedCategories.clear();
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Promo Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Promotions uniquement',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Switch(
                          value: _showPromoOnly,
                          activeColor: AppColors.accent,
                          onChanged: (bool value) {
                            setState(() {
                              _showPromoOnly = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onApply(
                    _priceRange,
                    _selectedCategories,
                    _showPromoOnly,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent, // Orange
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Appliquer les filtres',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
