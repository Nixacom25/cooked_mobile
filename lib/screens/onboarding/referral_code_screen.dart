import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/ios_toast.dart';
import '../../services/gift_service.dart';
import '../../services/revenuecat_service.dart';
import '../../services/user_service.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/red_button.dart';
import '../../widgets/red_header_background.dart';
import 'widgets/social_proof_step.dart';
import '../../core/l10n/l10n.dart';

/// "Do you have a referral code?" flow, opened from the subscription step of
/// onboarding: social proof, then an optional code field. A valid code (a
/// gift bought with "Gift Cooked to a friend") unlocks Premium, so the
/// user can skip paying. Pops `true` when a code was redeemed.
///
/// It lives in onboarding (not Settings) because the account exists at this
/// point but has no subscription yet - exactly when a gift is useful.
class ReferralCodeScreen extends StatefulWidget {
  final List<String> favoriteCuisines;

  const ReferralCodeScreen({super.key, this.favoriteCuisines = const []});

  @override
  State<ReferralCodeScreen> createState() => _ReferralCodeScreenState();
}

class _ReferralCodeScreenState extends State<ReferralCodeScreen> {
  final PageController _pages = PageController();
  final TextEditingController _code = TextEditingController();
  int _page = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _pages.dispose();
    _code.dispose();
    super.dispose();
  }

  void _back() {
    if (_page > 0) {
      _pages.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context, false);
    }
  }

  Future<void> _submit() async {
    final code = _code.text.trim();
    if (code.isEmpty || _submitting) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      final result = await GiftService.instance.redeem(code);
      if (result.isAmbassador) {
        // Referral code: credited to the ambassador, nothing unlocked — back to the trial step.
        if (!mounted) return;
        IosToast.show(
          context,
          message: context.l10n.referralApplied(result.ambassadorName),
          type: ToastType.success,
        );
        Navigator.pop(context, false);
        return;
      }
      UserService.instance.updateLocalUserPremiumStatus(true);
      await RevenueCatService.instance.refreshCustomerInfo();
      if (!mounted) return;
      IosToast.show(
        context,
        message: context.l10n.giftUnlocked(result.planLabel),
        type: ToastType.success,
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      IosToast.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(child: RedHeaderBackground()),
            SafeArea(
              bottom: false,
              child: Container(
                margin: EdgeInsets.only(top: 20.h),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                ),
                child: Column(
                  children: [
                    // Header: back + progress (same as onboarding)
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
                      child: Row(
                        children: [
                          GlassIconButton(
                            onTap: _back,
                            size: 40.r,
                            child: Icon(Icons.arrow_back_rounded, size: 20.sp, color: context.colors.textPrimary),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: Stack(
                                children: [
                                  Container(height: 6.h, color: context.colors.pageBackground),
                                  AnimatedFractionallySizedBox(
                                    duration: const Duration(milliseconds: 400),
                                    widthFactor: _page == 0 ? 0.5 : 1.0,
                                    child: Container(
                                      height: 6.h,
                                      decoration: BoxDecoration(
                                        color: context.colors.accent,
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pages,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (i) => setState(() => _page = i),
                        children: [
                          SocialProofStep(
                            favoriteCuisines: widget.favoriteCuisines,
                            onContinue: () => _pages.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                          ),
                          _buildCodePage(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodePage() {
    final colors = context.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.referralEnterCode,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w800,
              fontSize: 28.sp,
              height: 1.15,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            context.l10n.referralCanSkip,
            style: TextStyle(fontFamily: 'Rubik', fontSize: 15.sp, color: colors.textSecondary),
          ),
          const Spacer(),
          // Code field with inline Submit
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 6.h, 6.w, 6.h),
            decoration: BoxDecoration(
              color: colors.pageBackground,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _code,
                    textCapitalization: TextCapitalization.characters,
                    autocorrect: false,
                    enableSuggestions: false,
                    onSubmitted: (_) => _submit(),
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      letterSpacing: 1,
                      color: colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: context.l10n.referralCodeHint,
                      hintStyle: TextStyle(fontFamily: 'Rubik', color: colors.textMuted, letterSpacing: 0),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _code,
                  builder: (context, value, _) {
                    final enabled = value.text.trim().isNotEmpty && !_submitting;
                    return GestureDetector(
                      onTap: enabled ? _submit : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: enabled ? colors.accent : colors.border,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: _submitting
                            ? SizedBox(
                                width: 18.r,
                                height: 18.r,
                                child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                context.l10n.commonSubmit,
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.sp,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(
              bottom: (bottomInset > 0 ? bottomInset : MediaQuery.of(context).padding.bottom) + 16.h,
            ),
            child: RedButton(
              label: context.l10n.commonSkip,
              onTap: () => Navigator.pop(context, false),
              height: 54.h,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}
