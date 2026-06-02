import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/string_extensions.dart';
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
  final TextEditingController _otherController = TextEditingController();

  final List<Map<String, dynamic>> _options = [
    {'title': 'Tree nuts', 'icon': 'nut.svg'},
    {'title': 'Peanuts', 'icon': 'peanut.svg'},
    {'title': 'Shellfish', 'icon': 'shellfish.svg'},
    {'title': 'Fish', 'icon': 'fish.svg'},
    {'title': 'Eggs', 'icon': 'eggs.svg'},
    {'title': 'Soy', 'icon': 'soy.svg'},
    {'title': 'Dairy Milk', 'icon': 'dairy.svg'},
    {'title': 'Wheat/Gluten', 'icon': 'gluten.svg'},
    {'title': 'Sesame', 'icon': 'sesame.svg'},
    {'title': 'No Allergies', 'flutterIcon': Icons.block},
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
    _otherController.dispose();
    super.dispose();
  }

  void _addCustomAllergy() {
    HapticFeedback.selectionClick();
    final val = _otherController.text.trim().toTitleCase();
    if (val.isNotEmpty) {
      setState(() {
        _selectedAllergies.remove('No Allergies');
        if (!_customAllergies.contains(val)) {
          _customAllergies.add(val);
          _selectedAllergies.add(val);
        }
        _otherController.clear();
      });
      if (widget.onChanged != null) widget.onChanged!(_selectedAllergies);
    }
  }

  void _removeCustomAllergy(String val) {
    HapticFeedback.selectionClick();
    setState(() {
      _customAllergies.remove(val);
      _selectedAllergies.remove(val);
      if (_selectedAllergies.isEmpty) {
        _selectedAllergies.add('No Allergies');
      }
    });
    if (widget.onChanged != null) widget.onChanged!(_selectedAllergies);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ADD CUSTOM',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: const Color(0xFF7B8190),
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: _otherController,
            onSubmitted: (_) => _addCustomAllergy(),
            textCapitalization: TextCapitalization.words,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 14.sp,
              color: const Color(0xFF1A1A1A),
            ),
            decoration: InputDecoration(
              hintText: 'Type an allergy...',
              hintStyle: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 14.sp,
                color: Colors.grey[400],
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              suffixIcon: Padding(
                padding: EdgeInsets.all(8.r),
                child: GestureDetector(
                  onTap: _addCustomAllergy,
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC83A2D),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.add_rounded, color: Colors.white, size: 24.sp),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_customAllergies.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _customAllergies.map((c) => Chip(
              label: Text(c, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: const Color(0xFFFBBF24),
              deleteIcon: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: Color(0xFFFBBF24)),
              ),
              onDeleted: () => _removeCustomAllergy(c),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: const BorderSide(color: Colors.transparent),
              ),
            )).toList(),
          ),
        ],
        SizedBox(height: 15.h),
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F5EF),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 20.sp,
                color: const Color(0xFFFBBF24),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  "We'll try not to include these in your recommendations",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SF Pro',
                    color: const Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectionOnboardingStep(
      title: "Any allergies or intolerances?",
      subtitle: "Cooked will avoid these when recommending recipes.",
      useGrid: true,
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
