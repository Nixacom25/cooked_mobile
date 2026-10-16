import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/l10n/l10n.dart';
import '../core/widgets/ios_toast.dart';
import '../models/shared_cookbook_preview.dart';
import '../routes/app_routes.dart';
import '../services/cookbook_service.dart';
import '../services/recipe_service.dart';
import 'paywall_helper.dart';

/// Opened from a shared cookbook link once Home is on screen: the cookbook
/// shows up first in "Your cookbooks" with a loader and a filling bar (see
/// [CookbookService.receiveShared]), then a toast confirms it was added.
/// The sender opening their own link just lands on that cookbook.
Future<void> receiveSharedCookbook(
  GlobalKey<NavigatorState> navigatorKey,
  String cookbookId,
) async {
  void toast(String Function(AppLocalizations l10n) message, ToastType type) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    IosToast.show(context, message: message(context.l10n), type: type);
  }

  try {
    final preview = await CookbookService.instance.getSharedPreview(cookbookId);

    if (preview.isOwner) {
      final mine = (await CookbookService.instance.getMyCookbooks())
          .where((cb) => cb.id == preview.id)
          .firstOrNull;
      if (mine != null) {
        navigatorKey.currentState?.pushNamed(
          AppRoutes.cookbookDetail,
          arguments: {'cookbook': mine},
        );
      } else {
        toast((l10n) => l10n.receiveCookbookOwn, ToastType.warning);
      }
      return;
    }

    await CookbookService.instance.receiveShared(preview);
    // The copied recipes now belong to the user: refresh "Saved".
    RecipeService.instance.getMyRecipes(forceRefresh: true).ignore();
    HapticFeedback.mediumImpact();
    toast((l10n) => l10n.receiveCookbookDone, ToastType.success);
  } on SharedCookbookNotFound {
    toast((l10n) => l10n.receiveCookbookNotFound, ToastType.error);
  } catch (e) {
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted && PaywallHelper.isSubscriptionError(e)) {
      PaywallHelper.handleError(context, e);
      return;
    }
    toast((l10n) => l10n.receiveCookbookFailed, ToastType.error);
  }
}
