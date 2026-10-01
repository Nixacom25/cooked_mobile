import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/ios_toast.dart';
import '../../services/gift_service.dart';
import '../../services/revenuecat_service.dart';
import '../../widgets/profile_subpage_scaffold.dart';
import '../../widgets/red_button.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/l10n/l10n.dart';

/// "Give the gift of Cooked": gift cards sold as consumable in-app purchases
/// (Apple on iOS, Google on Android). One purchase = one single-use code,
/// created by the backend once the store confirms the payment.
class GiftScreen extends StatefulWidget {
  const GiftScreen({super.key});

  @override
  State<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> {
  static List<(String, String, String, bool)> _plans(BuildContext context) {
    final l10n = context.l10n;
    return [
      (RevenueCatService.giftOneYearProductId, l10n.giftPlanOneYear, l10n.giftPlanOneYearDesc, true),
      (RevenueCatService.giftThreeMonthsProductId, l10n.giftPlanThreeMonths, l10n.giftPlanThreeMonthsDesc, false),
    ];
  }

  Map<String, StoreProduct> _products = {};
  List<GiftCode> _gifts = [];
  bool _loading = true;
  String? _purchasingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      RevenueCatService.instance.getGiftProducts(),
      GiftService.instance.getMyGifts().catchError((_) => <GiftCode>[]),
    ]);
    if (!mounted) return;
    setState(() {
      _products = {
        for (final p in results[0] as List<StoreProduct>) p.identifier.split(':').first: p,
      };
      _gifts = results[1] as List<GiftCode>;
      _loading = false;
    });
  }

  Future<void> _buy(String productId) async {
    final product = _products[productId];
    if (product == null || _purchasingId != null) return;

    setState(() => _purchasingId = productId);
    final knownIds = _gifts.map((g) => g.id).toSet();
    try {
      final purchased = await RevenueCatService.instance.purchaseGift(product);
      if (!purchased) return;

      // The code is created by the backend from RevenueCat's webhook, which
      // usually lands within a few seconds - poll for it.
      final newGift = await _waitForNewGift(knownIds);
      if (!mounted) return;
      if (newGift != null) {
        _showGiftReady(newGift);
      } else {
        IosToast.show(
          context,
          message: context.l10n.giftPaymentReceived,
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (!mounted) return;
      IosToast.show(context, message: context.l10n.giftPurchaseFailed, type: ToastType.error);
    } finally {
      if (mounted) setState(() => _purchasingId = null);
    }
  }

  Future<GiftCode?> _waitForNewGift(Set<String> knownIds) async {
    for (int i = 0; i < 15; i++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      try {
        final gifts = await GiftService.instance.getMyGifts();
        if (mounted) setState(() => _gifts = gifts);
        final fresh = gifts.where((g) => !knownIds.contains(g.id));
        if (fresh.isNotEmpty) return fresh.first;
      } catch (_) {}
      if (!mounted) return null;
    }
    return null;
  }

  void _share(GiftCode gift) {
    SharePlus.instance.share(ShareParams(
      text: context.l10n.giftShareMessage(gift.planLabel, gift.redeemUrl, gift.code),
    ));
  }

  void _copy(GiftCode gift) {
    Clipboard.setData(ClipboardData(text: gift.code));
    IosToast.show(context, message: context.l10n.giftCodeCopied, type: ToastType.success);
  }

  void _showGiftReady(GiftCode gift) {
    showGlassSheet(
      context,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h + MediaQuery.of(sheetContext).padding.bottom),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎁', style: TextStyle(fontSize: 44.sp)),
            SizedBox(height: 8.h),
            Text(
              context.l10n.giftReady,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              context.l10n.giftSendThisCode(gift.planLabel),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 14.sp,
                color: context.colors.textSecondary,
              ),
            ),
            SizedBox(height: 18.h),
            _CodeBox(code: gift.code, onTap: () => _copy(gift)),
            SizedBox(height: 20.h),
            RedButton(
              label: context.l10n.giftSendToFriend,
              onTap: () {
                Navigator.pop(sheetContext);
                _share(gift);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileSubpageScaffold(
      title: context.l10n.giftTitle,
      child: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : RefreshIndicator.adaptive(
              onRefresh: _load,
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 40.h + MediaQuery.of(context).padding.bottom),
                children: [
                  Text(
                    context.l10n.giftHeadline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w800,
                      fontSize: 24.sp,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    context.l10n.giftSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 14.sp,
                      height: 1.4,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  for (final (id, title, description, bestValue) in _plans(context)) ...[
                    _GiftCard(
                      title: title,
                      price: _products[id]?.priceString,
                      description: description,
                      bestValue: bestValue,
                      isLoading: _purchasingId == id,
                      isDisabled: _products[id] == null || (_purchasingId != null && _purchasingId != id),
                      onBuy: () => _buy(id),
                    ),
                    SizedBox(height: 14.h),
                  ],
                  if (_gifts.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Text(
                      context.l10n.giftYourGifts,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w700,
                        fontSize: 17.sp,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    for (final gift in _gifts)
                      _GiftRow(
                        gift: gift,
                        onCopy: () => _copy(gift),
                        onShare: () => _share(gift),
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _GiftCard extends StatelessWidget {
  final String title;
  final String? price;
  final String description;
  final bool bestValue;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onBuy;

  const _GiftCard({
    required this.title,
    required this.price,
    required this.description,
    required this.bestValue,
    required this.isLoading,
    required this.isDisabled,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🎁', style: TextStyle(fontSize: 38.sp)),
              const Spacer(),
              if (bestValue)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    context.l10n.giftBestValue,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: colors.accent,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
              color: colors.textPrimary,
            ),
          ),
          Text(
            price ?? '—',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w800,
              fontSize: 28.sp,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 13.sp,
              height: 1.4,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          RedButton(
            label: context.l10n.giftBuy,
            loadingLabel: context.l10n.commonProcessingDots,
            isLoading: isLoading,
            isDisabled: isDisabled,
            onTap: onBuy,
          ),
        ],
      ),
    );
  }
}

class _GiftRow extends StatelessWidget {
  final GiftCode gift;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _GiftRow({required this.gift, required this.onCopy, required this.onShare});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusLabel = gift.isAvailable
        ? context.l10n.giftNotUsed
        : gift.isRedeemed
            ? context.l10n.giftRedeemed
            : context.l10n.giftRefunded;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gift.code,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    letterSpacing: 1,
                    color: gift.isAvailable ? colors.textPrimary : colors.textSecondary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${gift.planLabel} · $statusLabel',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 12.sp,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (gift.isAvailable) ...[
            IconButton(
              onPressed: onCopy,
              icon: Icon(Icons.copy_rounded, size: 20.sp, color: colors.textSecondary),
            ),
            IconButton(
              onPressed: onShare,
              icon: Icon(Icons.ios_share_rounded, size: 20.sp, color: colors.accent),
            ),
          ],
        ],
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  final String code;
  final VoidCallback onTap;

  const _CodeBox({required this.code, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: context.colors.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: context.colors.accent.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text(
              code,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w800,
                fontSize: 20.sp,
                letterSpacing: 2,
                color: context.colors.accent,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              context.l10n.giftTapToCopy,
              style: TextStyle(fontFamily: 'Rubik', fontSize: 12.sp, color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
