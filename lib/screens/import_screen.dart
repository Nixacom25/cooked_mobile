import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../widgets/app_search_field.dart';
import '../services/recipe_service.dart';
import '../models/recipe.dart';
import '../routes/app_routes.dart';
import '../models/view_all_type.dart';
import '../widgets/import_loading_page.dart';
import '../core/widgets/ios_toast.dart';
import '../core/utils/error_helper.dart';
import '../core/utils/tutorial_helper.dart';
import '../core/services/tutorial_service.dart';
import '../core/extensions/string_extensions.dart';
import '../services/ingredient_service.dart';
import '../services/sharing_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import '../utils/paywall_helper.dart';
import '../widgets/skeleton_list.dart';
import '../widgets/red_button.dart';
import '../widgets/skeleton_loader.dart';

class ImportScreen extends StatefulWidget {
  final ValueNotifier<bool>? isActiveNotifier;
  final ValueNotifier<bool>? isImportingNotifier;
  final String? initialUrl;
  const ImportScreen({
    super.key,
    this.isActiveNotifier,
    this.isImportingNotifier,
    this.initialUrl,
  });
  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  @override
  void initState() {
    super.initState();
    _loadRecentImports();
    _loadTrending();

    widget.isActiveNotifier?.addListener(_onActiveStateChanged);
    SharingService.instance.sharedTextNotifier.addListener(_onSharedUrlUpdated);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isActiveNotifier?.value ?? false) {
        _onActiveStateChanged();
      }
      
      if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
        _linkCtrl.text = widget.initialUrl!;
        _importFromUrl(widget.initialUrl!);
      } else {
        _onSharedUrlUpdated();
      }
    });
  }

  void _onSharedUrlUpdated() {
    if (!mounted) return;
    final url = SharingService.instance.sharedTextNotifier.value;
    if (url != null && url.isNotEmpty) {
      if (!_isImporting && _linkCtrl.text != url) {
        _linkCtrl.text = url;
        _importFromUrl(url);
      }
    }
  }

  void _onActiveStateChanged() {
    if (widget.isActiveNotifier?.value ?? false) {
      if (!TutorialService.instance.hasSeenImport) {
        TutorialHelper.showImportOnboardingDialog(context);
        TutorialService.instance.completeImport();
      }
    }
  }

  Future<void> _loadRecentImports() async {
    try {
      await RecipeService.instance.getRecentImports(size: 6);
    } catch (_) {}
  }

  Future<void> _loadTrending() async {
    try {
      final trending = await RecipeService.instance.getTrendingAiDishes();
      if (mounted) {
        setState(() {
          _trendingRecipes = trending;
        });
      }
    } catch (_) {}
  }

  final _linkCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  bool _isImporting = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  Timer? _searchDebounce;
  List<Map<String, dynamic>> _suggestedWebRecipes = [];

  List<String> _trendingRecipes = [];

  Future<void> _showWebPreview(String url, String title) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.zero),
      ),
      builder: (context) {
        return SizedBox(
          height: 1.sh,
          child: _RecipeWebPreviewModal(
            url: url,
            title: title,
            onImport: () {
              Navigator.pop(context);
              _importFromUrl(url);
            },
          ),
        );
      },
    );
  }

  Future<void> _importFromUrl(String url) async {
    if (url.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _isImporting = true);
    widget.isImportingNotifier?.value = true;

    try {
      final recipe = await RecipeService.instance.importRecipeFromUrl(url);
      SharingService.instance.consumeSharedText();
      
      if (!mounted) return;

      Navigator.pushNamed(
        context,
        AppRoutes.recipeDetail,
        arguments: {'recipe': recipe, 'isPreview': true},
      );
      
      IosToast.show(
        context,
        message: 'Recipe imported successfully!',
        type: ToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      if (PaywallHelper.handleError(context, e)) return;
      IosToast.show(
        context,
        message: ErrorHelper.getFriendlyMessage(e),
        type: ToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
        widget.isImportingNotifier?.value = false;
      }
    }
  }

  Future<void> _handleWebSearch(String val) async {
    if (val.trim().isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isSearching = true;
      _searchResults = [];
    });
    try {
      final res = await RecipeService.instance.searchWeb(val.trim());
      if (mounted) {
        setState(() {
          _searchResults = res;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        if (PaywallHelper.handleError(context, e)) return;
        IosToast.show(
          context,
          message: ErrorHelper.getFriendlyMessage(e),
          type: ToastType.error,
        );
      }
    }
  }

  void _onSearchChanged(String val) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    if (val.trim().length < 2) {
      setState(() => _suggestedWebRecipes = []);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final res = await IngredientService.instance.searchIngredients(val.trim());
        if (mounted) {
          setState(() {
            _suggestedWebRecipes = res.take(5).toList();
          });
        }
      } catch (_) {}
    });
  }

  String _capitalize(String text) {
    return text.toTitleCase();
  }

  @override
  void dispose() {
    widget.isActiveNotifier?.removeListener(_onActiveStateChanged);
    SharingService.instance.sharedTextNotifier.removeListener(_onSharedUrlUpdated);
    _linkCtrl.dispose();
    _searchCtrl.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isImporting) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: ImportLoadingPage(),
      );
    }

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(22.w, 0, 22.w, bottomInset + 120.h),
          children: [
            Text(
              'Import',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w800,
                fontSize: 24.sp,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Recipe Link',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                  color: const Color(0xFF888888),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PlatformImg(asset: 'assets/images/instagram.png'),
                SizedBox(width: 15.w),
                _PlatformImg(asset: 'assets/images/facebook.png'),
                SizedBox(width: 15.w),
                _PlatformImg(asset: 'assets/images/tiktok.png'),
                SizedBox(width: 15.w),
                _PlatformImg(asset: 'assets/images/youtube.png'),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50.r),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _linkCtrl,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 14.sp,
                        color: const Color(0xFF1A1A1A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Paste a recipe link...',
                        hintStyle: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 14.sp,
                          color: Colors.grey[400],
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _linkCtrl,
                    builder: (context, value, _) {
                      final bool hasText = value.text.isNotEmpty;
                      return GestureDetector(
                        onTap: () async {
                          if (hasText) {
                            _linkCtrl.clear();
                          } else {
                            final d = await Clipboard.getData('text/plain');
                            if (d?.text != null) _linkCtrl.text = d!.text!;
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 18.w),
                          child: Icon(
                            hasText ? Icons.close_rounded : Icons.content_paste_rounded,
                            size: 20.sp,
                            color: const Color(0xFF7A8499),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            RedButton(
              label: 'Import Recipes',
              loadingLabel: 'Importing',
              isLoading: _isImporting,
              onTap: () => _importFromUrl(_linkCtrl.text.trim()),
              height: 50.h,
              fontSize: 15.sp,
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFFE5E5E5))),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: Color(0xFFE5E5E5))),
              ],
            ),
            const SizedBox(height: 25),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: AppSearchField(
                controller: _searchCtrl,
                hintText: 'Search web',
                suffixIcon: Icons.check_circle_rounded,
                onSuffixTap: () {
                  setState(() => _suggestedWebRecipes = []);
                  _handleWebSearch(_searchCtrl.text);
                },
                onSubmitted: (val) {
                  setState(() => _suggestedWebRecipes = []);
                  _handleWebSearch(val);
                },
                onChanged: _onSearchChanged,
              ),
            ),
            if (_suggestedWebRecipes.isNotEmpty && !_isSearching)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                constraints: BoxConstraints(maxHeight: 250.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _suggestedWebRecipes.length,
                  itemBuilder: (ctx, i) {
                    final res = _suggestedWebRecipes[i];
                    return ListTile(
                      title: Text(
                        _capitalize(res['name'] ?? ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: 'SF Pro', fontSize: 14.sp),
                      ),
                      onTap: () {
                        final title = _capitalize(res['name'] ?? '');
                        setState(() => _suggestedWebRecipes = []);
                        _searchCtrl.text = title;
                        _handleWebSearch(title);
                      },
                    );
                  },
                ),
              ),
            SizedBox(height: 25.h),
            if (_isSearching)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: const SkeletonList(height: 80, itemCount: 3),
              )
            else if (_searchResults.isNotEmpty)
              _WebSearchResults(
                results: _searchResults,
                onView: (url, title) => _showWebPreview(url, title),
                onClear: () => setState(() => _searchResults = []),
              ),
            if (_trendingRecipes.isNotEmpty) ...[
              Text(
                'Trending',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w800,
                  fontSize: 16.sp,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _trendingRecipes.map((name) => _TrendingChip(
                  name: name,
                  onImport: () {
                    _searchCtrl.text = name;
                    _handleWebSearch(name);
                  },
                )).toList(),
              ),
              SizedBox(height: 25.h),
            ],
            ValueListenableBuilder<List<Recipe>?>(
              valueListenable: RecipeService.instance.recentImportsNotifier,
              builder: (context, importsList, _) {
                final List<Recipe> list = importsList ?? [];
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Imports',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w800,
                            fontSize: 18.sp,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        if (list.length > 3)
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.viewAll,
                                arguments: {
                                  'type': ViewAllType.imports,
                                  'title': 'Recent Imports',
                                },
                              );
                            },
                            child: Text(
                              'View All',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                color: const Color(0xFFC83A2D),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    if (importsList == null)
                      const SkeletonList(height: 80, itemCount: 3)
                    else if (list.isEmpty)
                      Center(
                        child: Text(
                          'No recent imports yet.',
                          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                        ),
                      )
                    else
                      ...list.map((r) {
                        String source = 'Web';
                        IconData icon = Icons.language_rounded;
                        Color iconColor = const Color(0xFF888888);
                        String? sourceAsset;

                        if (r.sourceUrl?.contains('instagram.com') ?? false) {
                          source = 'Instagram';
                          iconColor = const Color(0xFFe6683c);
                          sourceAsset = 'assets/images/instagram.png';
                        } else if (r.sourceUrl?.contains('tiktok.com') ?? false) {
                          source = 'TikTok';
                          iconColor = Colors.black;
                          sourceAsset = 'assets/images/tiktok.png';
                        } else if (r.sourceUrl?.contains('youtube.com') ?? false) {
                          source = 'YouTube';
                          iconColor = Colors.red;
                          sourceAsset = 'assets/images/youtube.png';
                        } else if (r.sourceUrl?.contains('facebook.com') ?? false) {
                          source = 'Facebook';
                          iconColor = Colors.blue;
                          sourceAsset = 'assets/images/facebook.png';
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.recipeDetail,
                              arguments: {'recipe': r},
                            );
                          },
                          child: _RecentImportTile(
                            img: r.image ?? '',
                            title: r.name,
                            source: source,
                            sourceUrl: r.sourceUrl,
                            srcIcon: icon,
                            srcIconColor: iconColor,
                            srcAsset: sourceAsset,
                            isSuggested: r.isSuggested,
                            onValidate: () async {
                              try {
                                await RecipeService.instance.validateRecipe(r.id);
                                if (context.mounted) {
                                  IosToast.show(
                                    context,
                                    message: 'Recipe saved permanently!',
                                    type: ToastType.success,
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  IosToast.show(
                                    context,
                                    message: ErrorHelper.getFriendlyMessage(e),
                                    type: ToastType.error,
                                  );
                                }
                              }
                            },
                          ),
                        );
                      }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformImg extends StatelessWidget {
  final String asset;
  const _PlatformImg({required this.asset});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22.w,
      height: 22.h,
      child: ClipRRect(
        child: Image.asset(
          asset,
          width: 22.w,
          height: 22.h,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(Icons.link_rounded, color: Colors.black, size: 20.sp),
        ),
      ),
    );
  }
}

class _TrendingChip extends StatelessWidget {
  final String name;
  final VoidCallback onImport;
  const _TrendingChip({required this.name, required this.onImport});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onImport,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFEAEAEA),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icones/trending.svg',
              height: 10.sp,
              width: 10.sp,
              placeholderBuilder: (context) => const SkeletonLoader(width: 10, height: 10, borderRadius: 5),
            ),
            SizedBox(width: 10.w),
            Text(
              name,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 13.sp,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentImportTile extends StatelessWidget {
  final String img;
  final String title;
  final String source;
  final String? sourceUrl;
  final IconData srcIcon;
  final Color srcIconColor;
  final String? srcAsset;
  final bool isSuggested;
  final VoidCallback onValidate;

  const _RecentImportTile({
    required this.img,
    required this.title,
    required this.source,
    this.sourceUrl,
    required this.srcIcon,
    required this.srcIconColor,
    this.srcAsset,
    this.isSuggested = false,
    required this.onValidate,
  });

  Future<void> _launchUrl() async {
    if (sourceUrl == null || sourceUrl!.isEmpty) return;
    final Uri url = Uri.parse(sourceUrl!);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $sourceUrl');
    }
  }

  Widget _buildImage(String path) {
    if (path.isEmpty) {
      return Image.asset('assets/images/recipes.png', fit: BoxFit.cover);
    }
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: const Color(0xFFF2F1EF),
          child: const Center(
            child: SkeletonLoader(width: 30, height: 30, borderRadius: 15),
          ),
        ),
        errorWidget: (_, __, ___) => Image.asset('assets/images/recipes.png', fit: BoxFit.cover),
      );
    }
    return Image.asset(path, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F8F6),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(width: 56.w, height: 56.h, child: _buildImage(img)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 4.h),
                GestureDetector(
                  onTap: _launchUrl,
                  child: Row(
                    children: [
                      if (srcAsset != null)
                        Image.asset(srcAsset!, width: 14.w, height: 14.h)
                      else
                        Icon(srcIcon, size: 14.sp, color: srcIconColor),
                      SizedBox(width: 6.w),
                      Text(
                        source,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 12.sp,
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isSuggested)
            GestureDetector(
              onTap: onValidate,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                  color: Color(0xFFC83A2D),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WebSearchResults extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final Function(String, String) onView;
  final VoidCallback onClear;

  const _WebSearchResults({
    required this.results,
    required this.onView,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Search Results',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            GestureDetector(
              onTap: onClear,
              child: Text(
                'Clear',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC83A2D),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...results.map((res) => _SearchResultTile(
          title: res['title'] ?? '',
          url: res['url'] ?? res['link'] ?? '',
          snippet: res['snippet'] ?? '',
          onView: () => onView(
            res['url'] ?? res['link'] ?? '',
            res['title'] ?? 'Recipe Preview',
          ),
        )),
        SizedBox(height: 20.h),
        const Divider(color: Color(0xFFE5E5E5)),
        SizedBox(height: 20.h),
      ],
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final String title;
  final String url;
  final String snippet;
  final VoidCallback onView;

  const _SearchResultTile({
    required this.title,
    required this.url,
    required this.snippet,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            snippet,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 12.sp,
              color: const Color(0xFF666666),
            ),
          ),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: onView,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFC83A2D),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'View this recipe',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeWebPreviewModal extends StatefulWidget {
  final String url;
  final String title;
  final VoidCallback onImport;

  const _RecipeWebPreviewModal({
    required this.url,
    required this.title,
    required this.onImport,
  });

  @override
  State<_RecipeWebPreviewModal> createState() => _RecipeWebPreviewModalState();
}

class _RecipeWebPreviewModalState extends State<_RecipeWebPreviewModal> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) {
            final uri = Uri.parse(request.url);
            final targetUri = Uri.parse(widget.url);
            if (uri.host == targetUri.host || _isLoading) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 10.h, 16.w, 10.h),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_left_rounded, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w800,
                        fontSize: 16.sp,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(
                    controller: _controller,
                    gestureRecognizers: {
                      Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()),
                    },
                  ),
                  if (_isLoading)
                    const Center(child: SkeletonLoader(width: 40, height: 40, borderRadius: 20)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 35.h),
              child: RedButton(
                label: 'Import this recipe',
                loadingLabel: 'Importing',
                onTap: widget.onImport,
                height: 52.h,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
