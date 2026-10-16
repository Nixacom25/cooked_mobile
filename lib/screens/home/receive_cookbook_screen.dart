import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/l10n/l10n.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/theme/app_theme.dart';
import '../../models/cookbook.dart';
import '../../models/shared_cookbook_preview.dart';
import '../../routes/app_routes.dart';
import '../../services/cookbook_service.dart';
import '../../services/recipe_service.dart';
import '../../utils/paywall_helper.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/red_button.dart';

enum _ReceiveState { loading, receiving, done, failed }

/// Opened from a shared cookbook link: shows the cookbook, then "downloads"
/// it into the user's library with a progress bar up to 100%. The recipient
/// gets their own copy of the cookbook and of every recipe in it.
class ReceiveCookbookScreen extends StatefulWidget {
  final String cookbookId;
  const ReceiveCookbookScreen({super.key, required this.cookbookId});

  @override
  State<ReceiveCookbookScreen> createState() => _ReceiveCookbookScreenState();
}

class _ReceiveCookbookScreenState extends State<ReceiveCookbookScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(vsync: this);
  _ReceiveState _state = _ReceiveState.loading;
  SharedCookbookPreview? _preview;
  Cookbook? _received;
  String? _error;

  /// Share of the bar the animation may fill while the request is running;
  /// the rest is filled once the server confirms.
  static const double _pendingCap = 0.9;

  @override
  void initState() {
    super.initState();
    _receive();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  Future<void> _receive() async {
    setState(() {
      _state = _ReceiveState.loading;
      _error = null;
    });
    _progress.value = 0;
    final l10n = context.l10n;

    try {
      final preview = _preview ??
          await CookbookService.instance.getSharedPreview(widget.cookbookId);
      if (!mounted) return;
      if (preview.isOwner) {
        _fail(l10n.receiveCookbookOwn);
        return;
      }
      setState(() {
        _preview = preview;
        _state = _ReceiveState.receiving;
      });

      // Paced on the recipe count so a big cookbook visibly takes longer.
      final pending = Duration(
        milliseconds: (1200 + preview.recipeCount * 180).clamp(1200, 6000),
      );
      _progress.animateTo(_pendingCap, duration: pending, curve: Curves.easeOut);

      final cookbook =
          await CookbookService.instance.importShared(widget.cookbookId);
      // The copied recipes now belong to the user: refresh "Saved".
      RecipeService.instance.getMyRecipes(forceRefresh: true).ignore();
      if (!mounted) return;

      await _progress.animateTo(1, duration: Motion.long, curve: Motion.enter);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() {
        _received = cookbook;
        _state = _ReceiveState.done;
      });
    } on SharedCookbookNotFound {
      _fail(l10n.receiveCookbookNotFound);
    } catch (e) {
      if (!mounted) return;
      if (PaywallHelper.isSubscriptionError(e)) PaywallHelper.handleError(context, e);
      _fail(l10n.receiveCookbookFailed);
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    _progress.stop();
    setState(() {
      _state = _ReceiveState.failed;
      _error = message;
    });
  }

  void _openCookbook() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.cookbookDetail,
      arguments: {'cookbook': _received},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preview = _preview;

    return Scaffold(
      backgroundColor: context.colors.pageBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerLeft,
                child: GlassIconButton(
                  onTap: () => Navigator.pop(context),
                  size: 42.r,
                  child: Icon(Icons.close_rounded,
                      size: 20.sp, color: context.colors.textPrimary),
                ),
              ),
              const Spacer(),
              _Cover(images: preview?.coverImages ?? const []),
              SizedBox(height: 24.h),
              Text(
                preview?.name ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w800,
                  fontSize: 24.sp,
                  color: context.colors.textPrimary,
                ),
              ),
              if (preview?.ownerName != null) ...[
                SizedBox(height: 6.h),
                Text(
                  l10n.receiveCookbookSharedBy(preview!.ownerName!),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 14.sp,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
              SizedBox(height: 32.h),
              if (_state == _ReceiveState.failed)
                _ErrorMessage(message: _error ?? l10n.receiveCookbookFailed)
              else
                _ProgressSection(
                  progress: _progress,
                  total: preview?.recipeCount ?? 0,
                  isDone: _state == _ReceiveState.done,
                ),
              const Spacer(),
              _buildAction(l10n),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAction(AppLocalizations l10n) {
    switch (_state) {
      case _ReceiveState.done:
        return RedButton(label: l10n.receiveCookbookOpen, onTap: _openCookbook);
      case _ReceiveState.failed:
        // Nothing to retry for a missing cookbook or one that is already yours.
        final canRetry = _error == l10n.receiveCookbookFailed;
        return canRetry
            ? RedButton(label: l10n.receiveCookbookRetry, onTap: _receive)
            : const SizedBox.shrink();
      case _ReceiveState.loading:
      case _ReceiveState.receiving:
        return RedButton(
          label: l10n.receiveCookbookReceiving,
          isLoading: true,
          onTap: null,
        );
    }
  }
}

class _ProgressSection extends StatelessWidget {
  final Animation<double> progress;
  final int total;
  final bool isDone;

  const _ProgressSection({
    required this.progress,
    required this.total,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textStyle = TextStyle(
      fontFamily: 'Rubik',
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: context.colors.textSecondary,
    );

    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final value = progress.value;
        final done = (value * total).floor().clamp(0, total);
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isDone ? l10n.receiveCookbookDone : l10n.receiveCookbookReceiving,
                    style: textStyle.copyWith(color: context.colors.textPrimary),
                  ),
                ),
                Text('${(value * 100).round()}%', style: textStyle),
              ],
            ),
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10.h,
                backgroundColor: context.colors.border,
                valueColor: AlwaysStoppedAnimation(context.colors.accent),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isDone) ...[
                  AnimatedCheck(size: 18.r, color: context.colors.accent),
                  SizedBox(width: 6.w),
                ],
                Text(l10n.receiveCookbookProgress(done, total), style: textStyle),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;
  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Rubik',
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: context.colors.destructive,
      ),
    );
  }
}

/// Up to 4 recipe images in a 2x2 grid (one image fills the cover).
class _Cover extends StatelessWidget {
  final List<String> images;
  const _Cover({required this.images});

  @override
  Widget build(BuildContext context) {
    final size = 180.r;
    final tiles = images.take(4).toList();

    Widget image(String url) => CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          fadeInDuration: Motion.imageFade,
          errorWidget: (_, __, ___) =>
              Image.asset('assets/images/recipes.webp', fit: BoxFit.cover),
        );

    Widget content;
    if (tiles.isEmpty) {
      content = Icon(Icons.menu_book_rounded,
          size: 64.sp, color: context.colors.accent);
    } else if (tiles.length < 4) {
      content = image(tiles.first);
    } else {
      content = GridView.count(
        crossAxisCount: 2,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        children: tiles.map(image).toList(),
      );
    }

    return Center(
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Center(child: SizedBox.expand(child: content)),
      ),
    );
  }
}
