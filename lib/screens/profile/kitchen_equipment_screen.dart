import 'package:flutter/material.dart';

import '../../services/user_service.dart';
import '../../widgets/preference_step_scaffold.dart';
import '../../core/widgets/ios_toast.dart';
import '../onboarding/widgets/kitchen_step.dart';
import 'preferences_helpers.dart';

/// Profile > Kitchen Equipment - promoted out of the general Dietary
/// Preferences hub into its own top-level entry.
class KitchenEquipmentScreen extends StatefulWidget {
  const KitchenEquipmentScreen({super.key});

  @override
  State<KitchenEquipmentScreen> createState() => _KitchenEquipmentScreenState();
}

class _KitchenEquipmentScreenState extends State<KitchenEquipmentScreen> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    final args = currentPreferenceArgs(UserService.instance.currentUserNotifier.value);
    _selected = List<String>.from(args['kitchenAppliances'] as List<String>);
  }

  Future<void> _save() async {
    final args = currentPreferenceArgs(UserService.instance.currentUserNotifier.value);
    try {
      await UserService.instance.updatePreferences(
        dietaryPreferences: args['dietaryPreferences'],
        allergies: args['allergies'],
        foodDislikes: args['foodDislikes'],
        flavorDna: args['flavorDna'],
        spiceLevel: args['spiceLevel'],
        cookingSkill: args['cookingSkill'],
        cookingTimePreference: args['cookingTimePreference'],
        cookingFrequency: args['cookingFrequency'],
        cookingTarget: args['cookingTarget'],
        favoriteCuisines: args['favoriteCuisines'],
        kitchenAppliances: _selected,
        mealPlanningStyle: args['mealPlanningStyle'],
        notificationPreferences: args['notificationPreferences'],
        onboardingGoals: args['onboardingGoals'],
        language: args['language'],
        country: args['country'],
        measurementSystem: args['measurementSystem'],
      );
    } catch (e) {
      if (!mounted) return;
      IosToast.show(context, message: 'Failed to update kitchen equipment', type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PreferenceStepScaffold(
      title: 'Kitchen Equipment',
      step: KitchenStep(
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
