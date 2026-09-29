import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../services/user_service.dart';
import '../../widgets/red_header_background.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ios_toast.dart';
import 'preferences_helpers.dart';

/// App language picker. Values match the ones stored by the onboarding
/// Language & Region step (e.g. `FR Français`), so both screens stay in sync.
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  static const _options = [
    ('US English', '🇺🇸', 'English (US)'),
    ('GB English', '🇬🇧', 'English (UK)'),
    ('FR Français', '🇫🇷', 'Français'),
    ('ES Español', '🇪🇸', 'Español'),
    ('DE Deutsch', '🇩🇪', 'Deutsch'),
    ('SA العربية', '🇸🇦', 'العربية'),
  ];

  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = currentPreferenceArgs(
      UserService.instance.currentUserNotifier.value,
    )['language'];
  }

  Future<void> _select(String language) async {
    if (language == _selected) return;
    final previous = _selected;
    setState(() => _selected = language);

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
        language: language,
        country: args['country'],
        measurementSystem: args['measurementSystem'],
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _selected = previous);
      IosToast.show(context, message: 'Failed to update language', type: ToastType.error);
    }
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
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 42.r,
                            height: 42.r,
                            decoration: BoxDecoration(
                              color: context.colors.pageBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20.sp,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Language',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 20.sp,
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
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                      children: [
                        for (int i = 0; i < _options.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: context.colors.pageBackground,
                            ),
                          _buildOption(context, _options[i]),
                        ],
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

  Widget _buildOption(BuildContext context, (String, String, String) option) {
    final (value, flag, label) = option;
    final isSelected = _selected == value;
    return GestureDetector(
      onTap: () => _select(value),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          children: [
            Text(flag, style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? context.colors.accent : context.colors.border,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}
