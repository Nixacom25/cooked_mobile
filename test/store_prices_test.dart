import 'package:cooked/l10n/app_localizations.dart';
import 'package:cooked/services/store_price_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('texts use the store price, and omit it while unknown', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final fr = lookupAppLocalizations(const Locale('fr'));
    const loaded = StorePrices(
      monthly: '9,99 €',
      yearly: '29,99 €',
      yearlyPerMonth: '2,49 €',
      monthlyProductId: 'monthly_sub',
      yearlyProductId: 'yearly_sub',
    );
    expect(loaded.trialThenYearly(en), '3 days free, then 29,99 €/year');
    expect(loaded.trialThenYearly(fr), '3 jours offerts, puis 29,99 €/an');
    expect(loaded.labelFor('yearly_sub'), '29,99 €/year');
    expect(loaded.labelFor('monthly_sub:base'), '9,99 €/month');

    const unknown = StorePrices();
    expect(unknown.trialThenYearly(en), '3 days free, then billed yearly');
    expect(unknown.labelFor('yearly_sub'), isNull);
  });
}
