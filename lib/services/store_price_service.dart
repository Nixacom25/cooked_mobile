import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../l10n/app_localizations.dart';
import 'revenuecat_service.dart';

/// Real subscription prices, read from the App Store / Play Store through
/// RevenueCat (localized: "$29.99", "29,99 €"...). Never hardcode a price:
/// the stores set it per country, and Apple requires showing exactly what
/// StoreKit will charge. While prices aren't loaded, texts omit the price.
class StorePrices {
  /// e.g. "$9.99"
  final String? monthly;
  /// e.g. "$29.99"
  final String? yearly;
  /// Yearly price spread per month, e.g. "$2.49"
  final String? yearlyPerMonth;
  final String? monthlyProductId;
  final String? yearlyProductId;

  const StorePrices({
    this.monthly,
    this.yearly,
    this.yearlyPerMonth,
    this.monthlyProductId,
    this.yearlyProductId,
  });

  /// "3 days free, then $29.99/year" (price omitted until known).
  String trialThenYearly(AppLocalizations l10n) =>
      yearly != null ? l10n.priceTrialThenYearly(yearly!) : l10n.priceTrialThenBilledYearly;

  /// Localized price label of a product, for the backend's reminders.
  String? labelFor(String productId) {
    final base = productId.split(':').first;
    if (base == yearlyProductId && yearly != null) return '$yearly/year';
    if (base == monthlyProductId && monthly != null) return '$monthly/month';
    return null;
  }
}

class StorePriceService {
  StorePriceService._();
  static final StorePriceService instance = StorePriceService._();

  final ValueNotifier<StorePrices> prices = ValueNotifier(const StorePrices());
  Future<void>? _loading;

  /// Loads once (later calls reuse the result); call again with [force]
  /// after a storefront change.
  Future<void> load({bool force = false}) {
    if (_loading != null && !force) return _loading!;
    return _loading = _fetch();
  }

  Future<void> _fetch() async {
    final Offerings? offerings = await RevenueCatService.instance.getOfferings();
    final current = offerings?.current;
    if (current == null) {
      _loading = null; // allow a retry later
      return;
    }
    final monthly = current.monthly?.storeProduct;
    final annual = current.annual?.storeProduct;
    prices.value = StorePrices(
      monthly: monthly?.priceString,
      yearly: annual?.priceString,
      yearlyPerMonth: annual?.pricePerMonthString,
      monthlyProductId: monthly?.identifier.split(':').first,
      yearlyProductId: annual?.identifier.split(':').first,
    );
  }
}
