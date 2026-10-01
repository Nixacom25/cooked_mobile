import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/ios_toast.dart';
import '../../services/gift_service.dart';
import '../../services/revenuecat_service.dart';
import '../../services/user_service.dart';
import '../../widgets/profile_subpage_scaffold.dart';
import '../../widgets/red_button.dart';
import '../../core/l10n/l10n.dart';

class RedeemGiftScreen extends StatefulWidget {
  /// Pre-filled from a gift link (link.cookedapp.com/redeem?code=...).
  final String? initialCode;

  const RedeemGiftScreen({super.key, this.initialCode});

  @override
  State<RedeemGiftScreen> createState() => _RedeemGiftScreenState();
}

class _RedeemGiftScreenState extends State<RedeemGiftScreen> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialCode ?? '');
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    final code = _controller.text.trim();
    if (code.isEmpty || _loading) return;
    FocusScope.of(context).unfocus();

    setState(() => _loading = true);
    try {
      final result = await GiftService.instance.redeem(code);
      // Premium was granted server-side in RevenueCat: refresh entitlements.
      UserService.instance.updateLocalUserPremiumStatus(true);
      await RevenueCatService.instance.refreshCustomerInfo();
      if (!mounted) return;
      IosToast.show(
        context,
        message: context.l10n.giftUnlocked(result.planLabel),
        type: ToastType.success,
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      IosToast.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ProfileSubpageScaffold(
      title: context.l10n.giftRedeemTitle,
      child: ListView(
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 40.h),
        children: [
          Center(child: Text('🎁', style: TextStyle(fontSize: 56.sp))),
          SizedBox(height: 12.h),
          Text(
            context.l10n.giftRedeemHeadline,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            context.l10n.giftRedeemSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 14.sp,
              height: 1.4,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            enableSuggestions: false,
            textAlign: TextAlign.center,
            onSubmitted: (_) => _redeem(),
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
              letterSpacing: 1.5,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'COOK-XXXX-XXXX-XXXX',
              hintStyle: TextStyle(color: colors.textMuted, letterSpacing: 1.5),
              filled: true,
              fillColor: colors.pageBackground,
              contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) => RedButton(
              label: context.l10n.giftRedeem,
              loadingLabel: context.l10n.giftRedeeming,
              isLoading: _loading,
              isDisabled: value.text.trim().isEmpty,
              onTap: _redeem,
            ),
          ),
        ],
      ),
    );
  }
}
