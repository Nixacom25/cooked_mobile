import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../services/user_service.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/skeleton_list.dart';
import '../../widgets/red_header_background.dart';
import '../../widgets/preference_step_scaffold.dart';
import '../../core/widgets/ios_toast.dart';
import '../onboarding/widgets/dietary_preferences_step.dart';
import '../onboarding/widgets/dislikes_step.dart';
import '../onboarding/widgets/cooking_skill_step.dart';
import '../onboarding/widgets/time_preference_step.dart';
import '../onboarding/widgets/cooking_target_step.dart';
import '../onboarding/widgets/meal_planning_step.dart';
import '../onboarding/widgets/goals_step.dart';
import '../onboarding/widgets/language_region_step.dart';
import '../../core/theme/app_theme.dart';

// Allergies, Favorite Cuisines, Flavor & Spice and Kitchen Appliances used
// to live in this screen too, but are now their own top-level Profile
// entries (see AllergiesScreen, CuisineFlavorScreen, KitchenEquipmentScreen)
// - this hub only keeps the steps that don't have a dedicated home
// elsewhere. The fields themselves are still loaded/saved here unchanged,
// since PUT /user/me/preferences replaces the whole bundle on every call.

class UserPreferencesScreen extends StatefulWidget {
  const UserPreferencesScreen({super.key});

  @override
  State<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  bool _isLoading = true;

  // State for all preferences
  Set<String> _selectedDiet = {};
  Set<String> _selectedAllergy = {};
  Set<String> _selectedDislikes = {};
  Map<String, int> _flavorDna = {};
  String _spiceLevel = 'Medium heat';
  String _cookingSkill = 'Home Cook';
  String _cookingTime = '15–30 minutes';
  String _cookingFrequency = '2–3 times a week';
  String _cookingTarget = '3–4 people';
  List<String> _favoriteCuisines = [];
  List<String> _kitchenAppliances = [];
  String _mealPlanningStyle = 'Weekly meal plan';
  List<String> _notificationPreferences = [];
  List<String> _onboardingGoals = [];
  String _language = 'GB English';
  String _country = 'US United States';
  String _measurementSystem = 'Metric';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final user = await UserService.instance.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _selectedDiet = Set.from(user['dietaryPreferences'] ?? []);
        _selectedAllergy = Set.from(user['allergies'] ?? []);
        _selectedDislikes = Set.from(user['foodDislikes'] ?? []);
        _flavorDna = Map<String, int>.from(user['flavorDna'] ?? {});
        _spiceLevel = user['spiceLevel'] ?? 'Medium heat';
        _cookingSkill = user['cookingSkill'] ?? 'Home Cook';
        _cookingTime = user['cookingTimePreference'] ?? '15–30 minutes';
        _cookingFrequency = user['cookingFrequency'] ?? '2–3 times a week';
        _cookingTarget = user['cookingTarget'] ?? '3–4 people';
        _favoriteCuisines = List<String>.from(user['favoriteCuisines'] ?? []);
        _kitchenAppliances = List<String>.from(user['kitchenAppliances'] ?? []);
        _mealPlanningStyle = user['mealPlanningStyle'] ?? 'Weekly meal plan';
        _notificationPreferences = List<String>.from(
          user['notificationPreferences'] ?? [],
        );
        _onboardingGoals = List<String>.from(user['onboardingGoals'] ?? []);
        _language = user['language'] ?? 'GB English';
        _country = user['country'] ?? 'US United States';
        _measurementSystem = user['measurementSystem'] ?? 'Metric';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      IosToast.show(
        context,
        message: 'Failed to load preferences',
        type: ToastType.error,
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    try {
      await UserService.instance.updatePreferences(
        dietaryPreferences: _selectedDiet.toList(),
        allergies: _selectedAllergy.toList(),
        foodDislikes: _selectedDislikes.toList(),
        flavorDna: _flavorDna,
        spiceLevel: _spiceLevel,
        cookingSkill: _cookingSkill,
        cookingTimePreference: _cookingTime,
        cookingFrequency: _cookingFrequency,
        cookingTarget: _cookingTarget,
        favoriteCuisines: _favoriteCuisines,
        kitchenAppliances: _kitchenAppliances,
        mealPlanningStyle: _mealPlanningStyle,
        notificationPreferences: _notificationPreferences,
        onboardingGoals: _onboardingGoals.toList(),
        language: _language,
        country: _country,
        measurementSystem: _measurementSystem,
      );
      if (!mounted) return;
      IosToast.show(
        context,
        message: 'Preferences updated successfully!',
        type: ToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      IosToast.show(
        context,
        message: 'Failed to update preferences',
        type: ToastType.error,
      );
    }
  }

  static const Map<String, String> _goalLabels = {
    'save_money': 'Save money',
    'eat_healthier': 'Eat healthier',
    'gain_muscle': 'Gain muscle',
    'lose_weight': 'Lose weight',
    'waste_less': 'Waste less food',
    'learn_cook': 'Learn to cook',
    'discover_recipes': 'Discover recipes',
    'meal_prep': 'Meal prep easier',
  };

  String _formatGoals(List<String> goals) {
    return goals.map((id) => _goalLabels[id] ?? id).join(', ');
  }

  Future<void> _openEditor(String title, Widget editor) async {
    await pushPreferenceStep(context, title: title, step: editor);
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Red background fond_page.png ──
          const Positioned.fill(
            child: RedHeaderBackground(),
          ),
          SafeArea(
            bottom: false,
            child: Container(
              margin: EdgeInsets.only(top: 25.h),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32.r),
                ),
              ),
              child: Column(
                children: [
                  // ── Header ──
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                    child: Row(
                      children: [
                        GlassIconButton(
                          onTap: () => Navigator.pop(context),
                          size: 42.r,
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 20.sp,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Dietary Preferences',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 18.sp,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 42.r),
                      ],
                    ),
                  ),

                  // ── Content List ──
                  Expanded(
                    child: _isLoading
                        ? Padding(
                            padding: EdgeInsets.all(20.r),
                            child: const SkeletonList(height: 70, itemCount: 8),
                          )
                        : ListView(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                            children: [
                              _buildSectionHeader('Language & Region'),
                              _buildTile(
                                'Language & Region',
                                '$_language, $_country',
                                () => _openEditor(
                                  'Language & Region',
                                  LanguageRegionStep(
                                    initialLanguage: _language,
                                    initialCountry: _country,
                                    initialMeasurementSystem: _measurementSystem,
                                    onChanged: ({
                                      required String language,
                                      required String country,
                                      required String measurementSystem,
                                    }) {
                                      setState(() {
                                        _language = language;
                                        _country = country;
                                        _measurementSystem = measurementSystem;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.h),
                              _buildSectionHeader('Diet'),
                              _buildTile(
                                'Dietary Profile',
                                _selectedDiet.join(', '),
                                () => _openEditor(
                                  'Dietary Profile',
                                  DietaryPreferencesStep(
                                    initialSelected: _selectedDiet,
                                    onChanged: (val) => setState(() => _selectedDiet = val),
                                  ),
                                ),
                              ),
                              _buildTile(
                                'Food Dislikes',
                                _selectedDislikes.join(', '),
                                () => _openEditor(
                                  'Food Dislikes',
                                  DislikesStep(
                                    initialSelected: _selectedDislikes,
                                    isFromProfile: true,
                                    onChanged: (val) =>
                                        setState(() => _selectedDislikes = val),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.h),
                              _buildSectionHeader('Cooking & Skills'),
                              _buildTile(
                                'Cooking Skill',
                                _cookingSkill,
                                () => _openEditor(
                                  'Cooking Skill',
                                  CookingSkillStep(
                                    initialSelected: _cookingSkill,
                                    onChanged: (val) => setState(() => _cookingSkill = val),
                                  ),
                                ),
                              ),
                              _buildTile(
                                'Time Preference',
                                _cookingTime,
                                () => _openEditor(
                                  'Time Preference',
                                  TimePreferenceStep(
                                    initialSelected: _cookingTime,
                                    onChanged: (val) => setState(() => _cookingTime = val),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.h),
                              _buildSectionHeader('Meal Planning & Habits'),
                              _buildTile(
                                'Meal Planning Style',
                                _mealPlanningStyle,
                                () => _openEditor(
                                  'Meal Planning Style',
                                  MealPlanningStep(
                                    initialSelected: _mealPlanningStyle,
                                    onChanged: (val) =>
                                        setState(() => _mealPlanningStyle = val),
                                  ),
                                ),
                              ),
                              _buildTile(
                                'Cooking Target',
                                _cookingTarget,
                                () => _openEditor(
                                  'Cooking Target',
                                  CookingTargetStep(
                                    initialTarget: _cookingTarget,
                                    onChanged: (val) => setState(() => _cookingTarget = val),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.h),
                              _buildSectionHeader('Other'),
                              _buildTile(
                                'Onboarding Goals',
                                _formatGoals(_onboardingGoals),
                                () => _openEditor(
                                  'Onboarding Goals',
                                  GoalsStep(
                                    initialSelected: _onboardingGoals,
                                    onChanged: (val) =>
                                        setState(() => _onboardingGoals = val),
                                  ),
                                ),
                              ),
                              SizedBox(height: 40.h),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Rubik',
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: context.colors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTile(String title, String value, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: context.colors.pageBackground,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      value.isEmpty ? 'Not set' : value,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 13.sp,
                        color: context.colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.colors.textSecondary, size: 22.sp),
            ],
          ),
        ),
      ),
    );
  }
}
