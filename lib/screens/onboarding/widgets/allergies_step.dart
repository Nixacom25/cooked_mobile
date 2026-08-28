import 'package:google_fonts/google_fonts.dart';
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
    {'title': 'Tree nuts', 'icon': 'nuts1.svg'},
    {'title': 'Peanuts', 'icon': 'peanuts.svg'},
    {'title': 'Shellfish', 'icon': 'shellfishs.svg'},
    {'title': 'Fish', 'icon': 'fishs.svg'},
    {'title': 'Eggs', 'icon': 'eggs2.svg'},
    {'title': 'Soy', 'icon': 'soys.svg'},
    {'title': 'Dairy Milk', 'icon': 'milks.svg'},
    {'title': 'Wheat/Gluten', 'icon': 'glutens.svg'},
    {'title': 'Sesame', 'icon': 'sesames.svg'},
    {'title': 'No Allergies', 'icon': 'bloques.svg'},
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
      'Common allergies',
      style: GoogleFonts.rubik(fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF111827)));
  }

  Widget _buildBottomCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF4E5),
        borderRadius: BorderRadius.circular(14.r)),
      child: Text(
        "Additional dietary preferences can be updated later in Settings.",
        style: GoogleFonts.poppins(fontSize: 14.sp,
          color: const Color(0xFF111827),
          height: 1.35)));
  }

  @override
  Widget build(BuildContext context) {
    return SelectionOnboardingStep(
      title: "Do you have any\ndietary restrictions or\nallergies?",
      subtitle: "We’ll automatically filter recipes for you",
      useGrid: true,
      preserveSvgColor: false,
      gridItemDirection: Axis.vertical,
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
            icon: o['flutterIcon'] as IconData);
        }
        return SelectionOption(
          id: o['title'] as String,
          label: o['title'] as String,
          svgAsset: 'assets/icones/${o['icon']}');
      }).toList());
  }
}
