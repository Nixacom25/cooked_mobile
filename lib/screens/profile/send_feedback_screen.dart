import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ios_toast.dart';
import '../../services/support_service.dart';
import '../../services/user_service.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/red_header_background.dart';
import '../../core/l10n/l10n.dart';

class SendFeedbackScreen extends StatefulWidget {
  const SendFeedbackScreen({super.key});

  @override
  State<SendFeedbackScreen> createState() => _SendFeedbackScreenState();
}

class _SendFeedbackScreenState extends State<SendFeedbackScreen> {
  static const _categories = [
    'Account',
    'Payment',
    'Scan',
    'Import',
    'Recipe',
    'Shopping',
    'Other',
  ];

  /// Categories are sent to support in English; only the chip is translated.
  static String _categoryLabel(BuildContext context, String category) {
    final l10n = context.l10n;
    return switch (category) {
      'Account' => l10n.feedbackCatAccount,
      'Payment' => l10n.feedbackCatPayment,
      'Scan' => l10n.feedbackCatScan,
      'Import' => l10n.feedbackCatImport,
      'Recipe' => l10n.feedbackCatRecipe,
      'Shopping' => l10n.feedbackCatShopping,
      _ => l10n.feedbackCatOther,
    };
  }

  final _messageCtrl = TextEditingController();
  String _category = _categories.first;
  bool _sending = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final message = _messageCtrl.text.trim();
    if (message.isEmpty) {
      IosToast.show(context, message: context.l10n.feedbackWriteFirst, type: ToastType.warning);
      return;
    }

    final user = UserService.instance.currentUserNotifier.value;
    final name = [user?['firstname'], user?['lastname']]
            .where((n) => n != null && n.toString().trim().isNotEmpty)
            .join(' ')
        .trim();
    final email = user?['email'] as String?;
    final userId = user?['id'] as String?;

    if (email == null || email.isEmpty) {
      IosToast.show(context, message: context.l10n.feedbackNoEmail, type: ToastType.error);
      return;
    }

    setState(() => _sending = true);
    try {
      await SupportService.instance.submitFeedback(
        name: name.isEmpty ? 'Cooked user' : name,
        email: email,
        subject: _category,
        message: message,
        userId: userId,
        category: _category,
      );
      if (!mounted) return;
      IosToast.show(context, message: context.l10n.feedbackSent, type: ToastType.success);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      IosToast.show(context, message: context.l10n.feedbackFailed, type: ToastType.error);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                    child: Row(
                      children: [
                        GlassIconButton(
                          onTap: () => Navigator.pop(context),
                          size: 42.r,
                          child: Icon(Icons.arrow_back_rounded, size: 20.sp, color: context.colors.textPrimary),
                        ),
                        Expanded(
                          child: Text(
                            context.l10n.settingsContactSupport,
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
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.feedbackHeadline,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 15.sp,
                              color: context.colors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 24.h),

                          Text(
                            context.l10n.feedbackCategory,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: context.colors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: _categories.map((category) {
                              final selected = category == _category;
                              return GestureDetector(
                                onTap: () => setState(() => _category = category),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                                  decoration: BoxDecoration(
                                    color: selected ? context.colors.accent : context.colors.pageBackground,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    _categoryLabel(context, category),
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.sp,
                                      color: selected ? Colors.white : context.colors.textSecondary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 22.h),

                          Text(
                            context.l10n.feedbackMessage,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: context.colors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Container(
                            decoration: BoxDecoration(
                              color: context.colors.pageBackground,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: TextField(
                              controller: _messageCtrl,
                              maxLines: 6,
                              style: TextStyle(fontFamily: 'Rubik', fontSize: 14.sp, color: context.colors.textPrimary),
                              decoration: InputDecoration(
                                hintText: context.l10n.feedbackHint,
                                hintStyle: TextStyle(fontFamily: 'Rubik', fontSize: 14.sp, color: context.colors.textMuted),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16.w),
                              ),
                            ),
                          ),
                          SizedBox(height: 28.h),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _sending ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.colors.accent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                              ),
                              child: _sending
                                  ? SizedBox(
                                      width: 20.r,
                                      height: 20.r,
                                      child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                    )
                                  : Text(
                                      context.l10n.settingsContactSupport,
                                      style: TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.w700, fontSize: 15.sp),
                                    ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
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
}
