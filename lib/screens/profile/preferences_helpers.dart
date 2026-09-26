/// `PUT /user/me/preferences` replaces the whole preferences bundle on
/// every call (it's not a partial update) - so any screen that edits just
/// one field (Allergies, Kitchen Equipment, Favorite Cuisines...) still has
/// to resend every other field unchanged, or it would wipe them. This pulls
/// the current values out of the cached user map so each small screen only
/// has to override the one field it actually edits.
Map<String, dynamic> currentPreferenceArgs(Map<String, dynamic>? user) {
  final u = user ?? const {};
  return {
    'dietaryPreferences': List<String>.from(u['dietaryPreferences'] ?? []),
    'allergies': List<String>.from(u['allergies'] ?? []),
    'foodDislikes': List<String>.from(u['foodDislikes'] ?? []),
    'flavorDna': Map<String, int>.from(u['flavorDna'] ?? {}),
    'spiceLevel': u['spiceLevel'] ?? 'Medium heat',
    'cookingSkill': u['cookingSkill'] ?? 'Home Cook',
    'cookingTimePreference': u['cookingTimePreference'] ?? '15–30 minutes',
    'cookingFrequency': u['cookingFrequency'] ?? '2–3 times a week',
    'cookingTarget': u['cookingTarget'] ?? '3–4 people',
    'favoriteCuisines': List<String>.from(u['favoriteCuisines'] ?? []),
    'kitchenAppliances': List<String>.from(u['kitchenAppliances'] ?? []),
    'mealPlanningStyle': u['mealPlanningStyle'] ?? 'Weekly meal plan',
    'notificationPreferences': List<String>.from(u['notificationPreferences'] ?? []),
    'onboardingGoals': List<String>.from(u['onboardingGoals'] ?? []),
    'language': u['language'] ?? 'GB English',
    'country': u['country'] ?? 'US United States',
    'measurementSystem': u['measurementSystem'] ?? 'Metric',
  };
}
