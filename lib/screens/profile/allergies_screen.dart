import 'package:flutter/material.dart';

import '../../services/user_service.dart';
import '../../widgets/preference_step_scaffold.dart';
import '../../core/widgets/ios_toast.dart';
import '../onboarding/widgets/allergies_step.dart';
import 'preferences_helpers.dart';

/// Profile > Allergies - promoted out of the general Dietary Preferences
/// hub into its own top-level entry.
class AllergiesScreen extends StatefulWidget {
  const AllergiesScreen({super.key});

  @override
  State<AllergiesScreen> createState() => _AllergiesScreenState();
}

class _AllergiesScreenState extends State<AllergiesScreen> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    final args = currentPreferenceArgs(UserService.instance.currentUserNotifier.value);
    _selected = Set<String>.from(args['allergies'] as List<String>);
  }

  Future<void> _save() async {
    final args = currentPreferenceArgs(UserService.instance.currentUserNotifier.value);
    try {
      await UserService.instance.updatePreferences(
        dietaryPreferences: args['dietaryPreferences'],
        allergies: _selected.toList(),
        foodDislikes: args['foodDislikes'],
        flavorDna: args['flavorDna'],
        spiceLevel: args['spiceLevel'],
        cookingSkill: args['cookingSkill'],
        cookingTimePreference: args['cookingTimePreference'],
        cookingFrequency: args['cookingFrequency'],
        cookingTarget: args['cookingTarget'],
        favoriteCuisines: args['favoriteCuisines'],
        kitchenAppliances: args['kitchenAppliances'],
        mealPlanningStyle: args['mealPlanningStyle'],
        notificationPreferences: args['notificationPreferences'],
        onboardingGoals: args['onboardingGoals'],
        language: args['language'],
        country: args['country'],
        measurementSystem: args['measurementSystem'],
      );
    } catch (e) {
      if (!mounted) return;
      IosToast.show(context, message: 'Failed to update allergies', type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PreferenceStepScaffold(
      title: 'Allergies',
      step: AllergiesStep(
        initialSelected: _selected,
        onChanged: (val) => _selected = val,
      ),
    );
  }

  @override
  void dispose() {
    _save();
    super.dispose();
  }
}
