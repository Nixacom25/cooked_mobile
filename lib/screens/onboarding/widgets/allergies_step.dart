import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'selection_onboarding_step.dart';

class AllergiesStep extends StatefulWidget {
  final VoidCallback? onContinue;
  final Set<String> initialSelected;
  final Function(Set<String> selected)? onChanged;

  const AllergiesStep({
    super.key,
    this.onContinue,
    this.initialSelected = const {},
    this.onChanged,
  });

  @override
  State<AllergiesStep> createState() => _AllergiesStepState();
}

class _AllergiesStepState extends State<AllergiesStep> {
  late Set<String> _selectedAllergies;
  final List<String> _customAllergies = [];

  final List<Map<String, dynamic>> _options = [
    {'title': 'Tree nuts', 'icon': 'nut.svg'},
    {'title': 'Peanuts', 'icon': 'peanut2.svg'},
    {'title': 'Shellfish', 'icon': 'shellfish2.svg'},
    {'title': 'Fish', 'icon': 'fish2.svg'},
    {'title': 'Eggs', 'icon': 'protein.svg'},
    {'title': 'Soy', 'icon': 'soy2.svg'},
    {'title': 'Dairy Milk', 'icon': 'milk.svg'},
    {'title': 'Wheat/Gluten', 'icon': 'free.svg'},
    {'title': 'Sesame', 'icon': 'sesame2.svg'},
    {'title': 'No Allergies', 'icon': 'bloque2.svg'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedAllergies = Set.from(widget.initialSelected);
    if (_selectedAllergies.isEmpty) {
      _selectedAllergies.add('No Allergies');
    }
    
    final standardTitles = _options.map((e) => e['title'] as String).toSet();
    for (var a in _selectedAllergies) {
      if (!standardTitles.contains(a) && a != 'No Allergies') {
        _customAllergies.add(a);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }



  void _handleSelectionChanged(List<String> selections) {
    HapticFeedback.selectionClick();
    setState(() {
      final newSelection = selections.toSet();
      
      if (newSelection.contains('No Allergies') && !_selectedAllergies.contains('No Allergies')) {
        _selectedAllergies.clear();
        _customAllergies.clear();
        _selectedAllergies.add('No Allergies');
      } else {
        _selectedAllergies = newSelection;
        for (var custom in _customAllergies) {
          _selectedAllergies.add(custom);
        }
        if (_selectedAllergies.contains('No Allergies') && _selectedAllergies.length > 1) {
          _selectedAllergies.remove('No Allergies');
        }
        if (_selectedAllergies.isEmpty) {
          _selectedAllergies.add('No Allergies');
        }
      }
    });
    if (widget.onChanged != null) widget.onChanged!(_selectedAllergies);
  }

  Widget _buildTopCard() {
    return Text(
      'COMMON ALLERGIES',
      style: TextStyle(
        fontFamily: 'SF Pro',
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: const Color(0xFF7B8190),
      ),
    );
  }

  Widget _buildBottomCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF2C94C),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        "Additional dietary preferences can be\nupdated later in Settings.",
        style: TextStyle(
          fontSize: 14.sp,
          fontFamily: 'SF Pro',
          color: const Color(0xFF111827),
          height: 1.4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectionOnboardingStep(
      title: "Do you have any dietary restrictions or allergies?",
      subtitle: "We'll automatically filter recipes for you.",
      useGrid: true,
      preserveSvgColor: true,
      gridItemDirection: Axis.horizontal,
      maxSelections: 20,
      initialSelected: _selectedAllergies.toList(),
      onContinue: widget.onContinue,
      onSelectionChanged: _handleSelectionChanged,
      topCardWidget: _buildTopCard(),
      bottomCardWidget: _buildBottomCard(),
      options: _options.map((o) {
        if (o.containsKey('flutterIcon')) {
          return SelectionOption(
            id: o['title'] as String,
            label: o['title'] as String,
            icon: o['flutterIcon'] as IconData,
          );
        }
        return SelectionOption(
          id: o['title'] as String,
          label: o['title'] as String,
          svgAsset: 'assets/icones/${o['icon']}',
        );
      }).toList(),
    );
  }
}
