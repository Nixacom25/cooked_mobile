import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/user_service.dart';
import '../../core/widgets/ios_toast.dart';
import '../onboarding/widgets/dietary_preferences_step.dart';
import '../onboarding/widgets/allergies_step.dart';
import '../onboarding/widgets/dislikes_step.dart';
import '../onboarding/widgets/flavor_spice_step.dart';
import '../onboarding/widgets/cooking_skill_step.dart';
import '../onboarding/widgets/time_preference_step.dart';
import '../onboarding/widgets/cooking_target_step.dart';
import '../onboarding/widgets/cuisines_step.dart';
import '../onboarding/widgets/kitchen_step.dart';
import '../onboarding/widgets/meal_planning_step.dart';
import '../onboarding/widgets/notifications_step.dart';
import '../onboarding/widgets/goals_step.dart';
import '../onboarding/widgets/language_region_step.dart';

class UserPreferencesScreen extends StatefulWidget {
  const UserPreferencesScreen({super.key});

  @override
  State<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

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
    setState(() => _isSaving = true);
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
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      IosToast.show(
        context,
        message: 'Failed to update preferences',
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _openEditor(String title, Widget editor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title, style: TextStyle(fontSize: 18.sp)),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0D1B3E),
            elevation: 0,
          ),
          body: editor,
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC83A2D),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                child: Text('Confirm', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Dietary Preferences',
          style: TextStyle(
            color: const Color(0xFF0D1B3E),
            fontWeight: FontWeight.w700,
            fontFamily: 'SF Pro',
            fontSize: 20.sp,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0D1B3E),
        elevation: 0,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _savePreferences,
              child: Text(
                _isSaving ? 'Saving...' : 'Save',
                style: TextStyle(
                  color: const Color(0xFFC83A2D),
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFC83A2D)),
            )
          : ListView(
              padding: EdgeInsets.all(16.r),
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
                _buildSectionHeader('Diet & Allergies'),
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
                  'Allergies',
                  _selectedAllergy.join(', '),
                  () => _openEditor(
                    'Allergies',
                    AllergiesStep(
                      initialSelected: _selectedAllergy,
                      onChanged: (val) =>
                          setState(() => _selectedAllergy = val),
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
                  'Flavor & Spice',
                  '$_spiceLevel, ${_flavorDna.length} preferences',
                  () => _openEditor(
                    'Flavor & Spice',
                    FlavorSpiceStep(
                      initialDna: _flavorDna,
                      initialSpice: _spiceLevel,
                      onChanged: ({required dna, required spice}) {
                        setState(() {
                          _flavorDna = dna;
                          _spiceLevel = spice;
                        });
                      },
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
                _buildSectionHeader('Kitchen & Habits'),
                _buildTile(
                  'Favorite Cuisines',
                  _favoriteCuisines.join(', '),
                  () => _openEditor(
                    'Favorite Cuisines',
                    CuisinesStep(
                      initialSelected: _favoriteCuisines,
                      onChanged: (val) =>
                          setState(() => _favoriteCuisines = val),
                    ),
                  ),
                ),
                _buildTile(
                  'Kitchen Appliances',
                  _kitchenAppliances.join(', '),
                  () => _openEditor(
                    'Kitchen Appliances',
                    KitchenStep(
                      initialSelected: _kitchenAppliances,
                      onChanged: (val) =>
                          setState(() => _kitchenAppliances = val),
                    ),
                  ),
                ),
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
                  'Notification Preferences',
                  _notificationPreferences.join(', '),
                  () => _openEditor(
                    'Notification Preferences',
                    NotificationsStep(
                      initialSelected: _notificationPreferences,
                      onChanged: (val) =>
                          setState(() => _notificationPreferences = val),
                    ),
                  ),
                ),
                _buildTile(
                  'Onboarding Goals',
                  _onboardingGoals.join(', '),
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF7B8190),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTile(String title, String value, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
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
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0D1B3E),
                        fontFamily: 'SF Pro',
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      value.isEmpty ? 'Not set' : value,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF7B8190),
                        fontFamily: 'SF Pro',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: const Color(0xFF7B8190), size: 24.sp),
            ],
          ),
        ),
      ),
    );
  }
}
