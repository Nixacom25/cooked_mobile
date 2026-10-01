import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import 'locale_service.dart';

export '../../l10n/app_localizations.dart';
export 'locale_service.dart';

/// `context.l10n.someKey` - the translated UI strings for the current locale.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Strings for code without a BuildContext (services, error mapping), in the
/// current UI language.
AppLocalizations get appL10n => lookupAppLocalizations(LocaleService.instance.locale.value);

/// Text shared along with a recipe link ("Check out Ana's Pad Thai on Cooked").
String recipeShareText(
  AppLocalizations l10n, {
  required String name,
  required String link,
  String? creator,
}) =>
    creator != null ? l10n.shareRecipeByCreator(creator, name, link) : l10n.shareRecipe(name, link);
