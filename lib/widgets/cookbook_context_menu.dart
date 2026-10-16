import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/cookbook.dart';
import '../services/cookbook_service.dart';
import '../core/widgets/ios_toast.dart';
import '../core/l10n/l10n.dart';
import 'cookbook_form_modal.dart';
import 'haptic_context_menu.dart';

/// Long-press menu of a cookbook (Home's "Your Cookbooks" row and the
/// Cookbooks grid): add recipes, edit, pin, share, delete. [onChanged] runs
/// after an action changed the cookbook so the caller can refresh.
Future<void> showCookbookContextMenu(
  BuildContext context, {
  required Cookbook cookbook,
  required Offset position,
  VoidCallback? onChanged,
  bool showAddRecipes = false,
}) {
  final l10n = context.l10n;

  Future<void> openForm() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CookbookFormModal(cookbook: cookbook),
    );
    if (result is Cookbook || result == 'deleted') {
      CookbookService.instance.getMyCookbooks(forceRefresh: true);
      onChanged?.call();
    }
  }

  void toast(String message, ToastType type) {
    if (context.mounted) IosToast.show(context, message: message, type: type);
  }

  return HapticContextMenu.show(
    context,
    targetPosition: position,
    actions: [
      if (showAddRecipes)
        HapticMenuAction(
          title: l10n.cookbookAddRecipes,
          icon: Icons.add_circle_outline_rounded,
          onTap: openForm,
        ),
      HapticMenuAction(
        title: l10n.cookbookEdit,
        icon: Icons.edit_outlined,
        onTap: openForm,
      ),
      HapticMenuAction(
        title: cookbook.isPinned ? l10n.cookbookUnpin : l10n.cookbookPin,
        icon: cookbook.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
        onTap: () async {
          try {
            final updated = await CookbookService.instance.togglePin(cookbook.id);
            toast(updated.isPinned ? l10n.cookbookPinned : l10n.cookbookUnpinned, ToastType.success);
            onChanged?.call();
          } catch (_) {
            toast(l10n.commonOperationFailed, ToastType.error);
          }
        },
      ),
      HapticMenuAction(
        title: l10n.cookbookShare,
        icon: Icons.ios_share_rounded,
        onTap: () => shareCookbook(context, cookbook),
      ),
      HapticMenuAction(
        title: l10n.cookbookDelete,
        icon: Icons.delete_outline_rounded,
        isDestructive: true,
        onTap: () async {
          try {
            await CookbookService.instance.deleteCookbook(cookbook.id);
            toast(l10n.cookbookDeleted, ToastType.success);
            onChanged?.call();
          } catch (_) {
            toast(l10n.cookbookDeleteFailed, ToastType.error);
          }
        },
      ),
    ],
  );
}

/// Opens the system share sheet with the cookbook's link. Whoever opens the
/// link gets their own copy of the cookbook and of its recipes.
Future<void> shareCookbook(BuildContext context, Cookbook cookbook) async {
  final l10n = context.l10n;
  try {
    final link = await CookbookService.instance.getShareLink(cookbook.id);
    await SharePlus.instance.share(
      ShareParams(text: l10n.cookbookShareMessage(cookbook.name, link)),
    );
  } catch (_) {
    if (context.mounted) {
      IosToast.show(context, message: l10n.cookbookShareFailed, type: ToastType.error);
    }
  }
}
