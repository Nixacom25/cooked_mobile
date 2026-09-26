import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../services/user_service.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/red_header_background.dart';
import '../../widgets/preference_step_scaffold.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/theme/app_theme.dart';
import '../onboarding/widgets/cuisines_step.dart';
import '../onboarding/widgets/flavor_spice_step.dart';
import 'preferences_helpers.dart';

/// Profile > Cuisine + Flavor DNA - promoted out of the general Dietary
/// Preferences hub into its own top-level entry, combining Favorite
/// Cuisines and the Flavor & Spice (flavor DNA + spice level) step.
class CuisineFlavorScreen extends StatefulWidget {
  const CuisineFlavorScreen({super.key});

  @override
  State<CuisineFlavorScreen> createState() => _CuisineFlavorScreenState();
}

class _CuisineFlavorScreenState extends State<CuisineFlavorScreen> {
  late List<String> _favoriteCuisines;
  late Map<String, int> _flavorDna;
  late String _spiceLevel;

  @override
  void initState() {
    super.initState();
    final args = currentPreferenceArgs(UserService.instance.currentUserNotifier.value);
    _favoriteCuisines = List<String>.from(args['favoriteCuisines'] as List<String>);
    _flavorDna = Map<String, int>.from(args['flavorDna'] as Map<String, int>);
    _spiceLevel = args['spiceLevel'] as String;
  }

  Future<void> _save() async {
    final args = currentPreferenceArgs(UserService.instance.currentUserNotifier.value);
    try {
      await UserService.instance.updatePreferences(
        dietaryPreferences: args['dietaryPreferences'],
        allergies: args['allergies'],
        foodDislikes: args['foodDislikes'],
        flavorDna: _flavorDna,
        spiceLevel: _spiceLevel,
        cookingSkill: args['cookingSkill'],
        cookingTimePreference: args['cookingTimePreference'],
        cookingFrequency: args['cookingFrequency'],
        cookingTarget: args['cookingTarget'],
        favoriteCuisines: _favoriteCuisines,
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
      IosToast.show(context, message: 'Failed to update cuisine & flavor preferences', type: ToastType.error);
    }
  }

  Future<void> _openCuisines() async {
    await pushPreferenceStep(
      context,
      title: 'Favorite Cuisines',
      step: CuisinesStep(
        initialSelected: _favoriteCuisines,
        onChanged: (val) => setState(() => _favoriteCuisines = val),
      ),
    );
    _save();
  }

  Future<void> _openFlavorSpice() async {
    await pushPreferenceStep(
      context,
      title: 'Flavor & Spice',
      step: FlavorSpiceStep(
        initialDna: _flavorDna,
        initialSpice: _spiceLevel,
        onChanged: ({required dna, required spice}) {
          setState(() {
            _flavorDna = dna;
            _spiceLevel = spice;
          });
        },
      ),
    );
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: RedHeaderBackground()),
          SafeArea(
            bottom: false,
            child: Container(
              margin: EdgeInsets.only(top: 25.h),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              ),
              child: Column(
                children: [
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
                            'Cuisine + Flavor DNA',
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
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                      children: [
                        _buildTile(
                          'Favorite Cuisines',
                          _favoriteCuisines.isEmpty ? 'Not set' : _favoriteCuisines.join(', '),
                          _openCuisines,
                        ),
                        SizedBox(height: 10.h),
                        _buildTile(
                          'Flavor & Spice',
                          '$_spiceLevel, ${_flavorDna.length} preferences',
                          _openFlavorSpice,
                        ),
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

  Widget _buildTile(String title, String value, VoidCallback onTap) {
    return GestureDetector(
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
                    value,
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
    );
  }
}
