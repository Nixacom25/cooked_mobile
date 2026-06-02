import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

class GroceryShopStep extends StatefulWidget {
  final String? initialFrequency;
  final List<String> initialStores;
  final String? initialBudget;
  final Function(String? frequency, List<String> stores, String? budget) onChanged;

  const GroceryShopStep({
    super.key,
    this.initialFrequency,
    required this.initialStores,
    this.initialBudget,
    required this.onChanged,
  });

  @override
  State<GroceryShopStep> createState() => _GroceryShopStepState();
}

class _GroceryShopStepState extends State<GroceryShopStep> {
  String? _frequency;
  late Set<String> _stores;
  String? _budget;

  final List<String> _frequencies = [
    'Almost every day',
    'A few times a week',
    'Once a week',
    'Every two weeks',
    'Once a month',
    'It varies',
  ];

  final List<Map<String, String>> _storeOptions = [
    {'name': 'Walmart', 'icon': 'walmart.png'},
    {'name': 'Target', 'icon': 'target.png'},
    {'name': 'Costco', 'icon': 'costco.png'},
    {'name': 'Trader Joe\'s', 'icon': 'traderjoes.png'},
    {'name': 'Whole Foods', 'icon': 'wholefoods.png'},
    {'name': 'Kroger', 'icon': 'kroger.png'},
    {'name': 'Aldi', 'icon': 'aldi.png'},
    {'name': 'Local Markets', 'icon': 'localmarkets.png'},
    {'name': 'Instacart', 'icon': 'instacart.png'},
    {'name': 'Others', 'icon': ''},
  ];

  final List<String> _budgets = [
    'Under \$200',
    '\$200–400',
    '\$400–600',
    '\$600–800',
    '\$800-1000',
    '\$1000+',
  ];

  @override
  void initState() {
    super.initState();
    _frequency = widget.initialFrequency;
    _stores = widget.initialStores.toSet();
    _budget = widget.initialBudget;
  }

  void _notifyChange() {
    widget.onChanged(_frequency, _stores.toList(), _budget);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How do you grocery shop?',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'We\'ll help optimize recipes around your routine and budget.',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 32.h),

          // Section 1: Frequency
          _buildSectionTitle('How often do you grocery shop?'),
          SizedBox(height: 16.h),
          _buildGrid(
            items: _frequencies,
            isSelected: (item) => _frequency == item,
            onTap: (item) {
              setState(() => _frequency = item);
              _notifyChange();
            },
          ),
          SizedBox(height: 32.h),

          // Section 2: Stores
          _buildSectionTitle('Where do you usually shop?'),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: _storeOptions.map((store) {
              final isSelected = _stores.contains(store['name']);
              final itemWidth = (MediaQuery.of(context).size.width - 40.w - 12.w) / 2;
              
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (isSelected) {
                      _stores.remove(store['name']);
                    } else {
                      _stores.add(store['name']!);
                    }
                  });
                  _notifyChange();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: itemWidth,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFC83A2D) : const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: const Color(0xFFC83A2D).withOpacity(0.05),
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                        )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (store['icon']!.isNotEmpty) ...[
                        Image.asset(
                          'assets/icones/${store['icon']}',
                          height: 20.h,
                          width: 20.w,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      Flexible(
                        child: Text(
                          store['name']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A1A),
                            fontFamily: 'SF Pro',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 32.h),

          // Section 3: Budget
          _buildSectionTitle('What\'s your average monthly grocery budget?'),
          SizedBox(height: 16.h),
          _buildGrid(
            items: _budgets,
            isSelected: (item) => _budget == item,
            onTap: (item) {
              setState(() => _budget = item);
              _notifyChange();
            },
          ),

          SizedBox(height: 32.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED), // Light beige
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFFFEDD5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'We\'ll help optimize recipes around your budget.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                // Using a fallback for the Cooked logo if it doesn't exist
                Image.asset(
                  'assets/images/logo.png',
                  height: 32.h,
                  width: 32.h,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.restaurant_menu,
                    color: const Color(0xFFC83A2D),
                    size: 32.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF4B5563),
        fontFamily: 'SF Pro',
      ),
    );
  }

  Widget _buildGrid({
    required List<String> items,
    required bool Function(String) isSelected,
    required void Function(String) onTap,
  }) {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: items.map((item) {
        final selected = isSelected(item);
        final itemWidth = (MediaQuery.of(context).size.width - 40.w - 12.w) / 2;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap(item);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: itemWidth,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: selected ? const Color(0xFFC83A2D) : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
              boxShadow: [
                if (selected)
                  BoxShadow(
                    color: const Color(0xFFC83A2D).withOpacity(0.05),
                    blurRadius: 8.r,
                    offset: Offset(0, 4.h),
                  )
              ],
            ),
            child: Text(
              item,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                fontFamily: 'SF Pro',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
