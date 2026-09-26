import 'package:flutter/material.dart';

import '../../services/user_service.dart';
import '../../widgets/preference_step_scaffold.dart';
import '../../core/widgets/ios_toast.dart';
import '../onboarding/widgets/language_region_step.dart';
import 'preferences_helpers.dart';

class LanguageRegionScreen extends StatefulWidget {
  const LanguageRegionScreen({super.key});

  @override
  State<LanguageRegionScreen> createState() => _LanguageRegionScreenState();
}

class _LanguageRegionScreenState extends State<LanguageRegionScreen> {
  late String _language;
  late String _country;
  late String _measurementSystem;

  @override
  void initState() {
    super.initState();
    final args = currentPreferenceArgs(UserService.instance.currentUserNotifier.value);
    _language = args['language'];
    _country = args['country'];
    _measurementSystem = args['measurementSystem'];
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
        kitchenAppliances: args['kitchenAppliances'],
        mealPlanningStyle: args['mealPlanningStyle'],
        notificationPreferences: args['notificationPreferences'],
        onboardingGoals: args['onboardingGoals'],
        language: _language,
        country: _country,
        measurementSystem: _measurementSystem,
      );
    } catch (e) {
      if (!mounted) return;
      IosToast.show(context, message: 'Failed to update language & region', type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PreferenceStepScaffold(
      title: 'Language & Region',
      step: LanguageRegionStep(
        initialLanguage: _language,
        initialCountry: _country,
        initialMeasurementSystem: _measurementSystem,
        onChanged: ({
          required String language,
          required String country,
          required String measurementSystem,
        }) {
          _language = language;
          _country = country;
          _measurementSystem = measurementSystem;
        },
      ),
    );
  }

  @override
  void dispose() {
    _save();
    super.dispose();
  }
}
