import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'selection_onboarding_step.dart';

class DietaryPreferencesStep extends StatefulWidget {
  final VoidCallback? onContinue;
  final Set<String> initialSelected;
  final Function(Set<String> selected)? onChanged;

  const DietaryPreferencesStep({
    super.key,
    this.onContinue,
    this.initialSelected = const {},
    this.onChanged,
  });

  @override
  State<DietaryPreferencesStep> createState() => _DietaryPreferencesStepState();
}

class _DietaryPreferencesStepState extends State<DietaryPreferencesStep> {
  late Set<String> _selectedDiet;

  final List<Map<String, String>> _options = [
    {'title': 'No Restrictions', 'desc': 'I eat everything', 'icon': 'all.svg'},
    {'title': 'Vegetarian', 'desc': 'No meat or fish', 'icon': 'vegetarian.svg'},
    {'title': 'Vegan', 'desc': 'No animal products', 'icon': 'vegan.svg'},
    {'title': 'Pescatarian', 'desc': 'Fish OK, no other meat', 'icon': 'fish.svg'},
    {'title': 'Gluten-Free', 'desc': 'No wheat or gluten', 'icon': 'gluten.svg'},
    {'title': 'Dairy Free', 'desc': 'No milk or dairy', 'icon': 'dairy.svg'},
    {'title': 'Halal', 'desc': 'Islamic dietary laws', 'icon': 'halal.svg'},
    {'title': 'Kosher', 'desc': 'Jewish Dietary Laws', 'icon': 'kosher.svg'},
    {'title': 'Keto/Low-Carb', 'desc': 'High fat, low carb', 'icon': 'keto.svg'},
    {'title': 'High Protein', 'desc': 'High protein foods', 'icon': 'eggs.svg'}, // Changed to High Protein to match mockup step17.png
  ];

  @override
  void initState() {
    super.initState();
    _selectedDiet = Set.from(widget.initialSelected);
    if (_selectedDiet.isEmpty) {
      _selectedDiet.add('No Restrictions');
    }
  }

  void _handleSelectionChanged(List<String> newSelection) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedDiet = newSelection.toSet();
      if (_selectedDiet.isEmpty) {
        _selectedDiet.add('No Restrictions');
      }
    });

    if (widget.onChanged != null) {
      widget.onChanged!(_selectedDiet);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SelectionOnboardingStep(
      title: "What's your dietary profile?",
      subtitle: "Select all that apply.",
      useGrid: true,
      maxSelections: 10,
      initialSelected: _selectedDiet.toList(),
      exclusiveOptionId: 'No Restrictions',
      onContinue: widget.onContinue,
      onSelectionChanged: _handleSelectionChanged,
      options: _options.map((o) => SelectionOption(
        id: o['title']!,
        label: o['title']!,
        subLabel: o['desc']!,
        svgAsset: 'assets/icones/${o['icon']}',
      )).toList(),
    );
  }
}
