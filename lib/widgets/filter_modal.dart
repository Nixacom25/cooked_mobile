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

  @override
  void initState() {
    super.initState();
    _priceRange = widget.initialPriceRange;
    _selectedCategories = List.from(widget.initialSelectedCategories);
    _showPromoOnly = widget.initialShowPromoOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary, // Dark background
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _priceRange = const RangeValues(0, 500000);
                    _selectedCategories.clear();
                    _showPromoOnly = false;
                  });
                },
                child: const Text(
                  'Réinitialiser',
                  style: TextStyle(color: AppColors.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Price Range
          const Text(
            'Fourchette de prix (FCFA)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 500000, // Max price assumption
            divisions: 100,
            activeColor: AppColors.accent,
            inactiveColor: AppColors.primaryLight,
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
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                '${_priceRange.end.round()} FCFA',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Categories
          const Text(
            'Catégories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.allCategories.map((category) {
              final isSelected = _selectedCategories.contains(category.name);
              return FilterChip(
                label: Text(category.name),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                ),
                selected: isSelected,
                selectedColor: AppColors.accent,
                backgroundColor: AppColors.primaryLight,
                checkmarkColor: Colors.white,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(category.name);
                    } else {
                      _selectedCategories.remove(category.name);
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
                  color: Colors.white,
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
    );
  }
}
