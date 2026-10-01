import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../services/user_service.dart';
import '../../widgets/red_header_background.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ios_toast.dart';
import 'preferences_helpers.dart';
import '../../core/l10n/l10n.dart';
import '../../services/support_service.dart';
import '../../widgets/red_button.dart';
import '../../core/motion/motion_widgets.dart';

/// App language picker. Values match the ones stored by the onboarding
/// Language & Region step (e.g. `FR Français`), so both screens stay in sync.
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  // Supported for now; other languages can be suggested (see below).
  static const _defaultLanguage = 'US English';
  static const _options = [
    ('US English', '🇺🇸', 'English (US)'),
    ('FR Français', '🇫🇷', 'Français'),
    ('ES Español', '🇪🇸', 'Español'),
  ];

  late String _selected;

  @override
  void initState() {
    super.initState();
    // The profile value, or the language the app is currently shown in.
    final saved = currentPreferenceArgs(
      UserService.instance.currentUserNotifier.value,
    )['language'] as String?;
    // Anything not offered anymore (e.g. "GB English") shows as the default.
    _selected = _options.any((o) => o.$1 == saved) ? saved! : _defaultLanguage;
  }

  Future<void> _suggestLanguage() async {
    final controller = TextEditingController();
    final suggestion = await showGlassSheet<String>(
      context,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 20.h + MediaQuery.of(sheetContext).padding.bottom),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.langSuggestTitle,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w700,
                  fontSize: 19.sp,
                  color: context.colors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                context.l10n.langSuggestMessage,
                style: TextStyle(fontFamily: 'Rubik', fontSize: 14.sp, height: 1.4, color: context.colors.textSecondary),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 50,
                textCapitalization: TextCapitalization.words,
                onSubmitted: (v) => Navigator.pop(sheetContext, v),
                style: TextStyle(fontFamily: 'Rubik', fontSize: 16.sp, color: context.colors.textPrimary),
                decoration: InputDecoration(
                  hintText: context.l10n.langSuggestHint,
                  hintStyle: TextStyle(color: context.colors.textMuted),
                  counterText: '',
                  filled: true,
                  fillColor: context.colors.pageBackground,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) => RedButton(
                  label: context.l10n.langSendSuggestion,
                  isDisabled: value.text.trim().isEmpty,
                  onTap: () => Navigator.pop(sheetContext, value.text),
                  height: 52.h,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    final language = suggestion?.trim() ?? '';
    if (language.isEmpty || !mounted) return;

    final user = UserService.instance.currentUserNotifier.value;
    final name = [user?['firstname'], user?['lastname']]
        .where((n) => n != null && n.toString().trim().isNotEmpty)
        .join(' ')
        .trim();
    try {
      // Lands in the support inbox / admin tickets, tagged for easy filtering.
      await SupportService.instance.submitFeedback(
        name: name.isEmpty ? 'Cooked user' : name,
        email: (user?['email'] as String?) ?? 'unknown@cookedapp.com',
        subject: 'Language suggestion: $language',
        message: 'Language suggestion from the app: $language',
        userId: user?['id'] as String?,
        category: 'Language suggestion',
      );
      if (!mounted) return;
      IosToast.show(context, message: context.l10n.langSuggestionThanks, type: ToastType.success);
    } catch (_) {
      if (!mounted) return;
      IosToast.show(context, message: context.l10n.langSuggestionFailed, type: ToastType.error);
    }
  }

  Future<void> _select(String language) async {
    if (language == _selected) return;
    final previous = _selected;
    setState(() => _selected = language);
    // Switch the app's language right away; the profile save follows.
    LocaleService.instance.setFromLanguageValue(language);

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
      LocaleService.instance.setFromLanguageValue(previous);
      IosToast.show(context, message: context.l10n.langUpdateFailed, type: ToastType.error);
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
                            context.l10n.settingsLanguage,
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
                        Divider(height: 1, thickness: 1, color: context.colors.pageBackground),
                        // Ask for a language we don't offer yet.
                        GestureDetector(
                          onTap: _suggestLanguage,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Row(
                              children: [
                                Icon(Icons.add_comment_outlined, size: 20.sp, color: context.colors.accent),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Text(
                                    context.l10n.langSuggestRow,
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.sp,
                                      color: context.colors.accent,
                                    ),
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: context.colors.textSecondary, size: 20.sp),
                              ],
                            ),
                          ),
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
