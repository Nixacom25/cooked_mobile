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
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

// ══════════════════════════════════════════════════════════════════════════════
// IMPORT SCREEN  –  matches mockup image 2
// ══════════════════════════════════════════════════════════════════════════════
class ImportScreen extends StatefulWidget {
  final ValueNotifier<bool>? isActiveNotifier;
  final ValueNotifier<bool>? isImportingNotifier;
  const ImportScreen({super.key, this.isActiveNotifier, this.isImportingNotifier});
  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  @override
  void initState() {
    super.initState();
    _loadRecentImports();
    _loadTrending();
    
    // Trigger onboarding modal if in tutorial mode
    widget.isActiveNotifier?.addListener(_onActiveStateChanged);
    
    // Check initially (in case we start on this tab)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isActiveNotifier?.value ?? false) {
        _onActiveStateChanged();
      }
    });
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
    // Check for initialUrl in arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('initialUrl')) {
        final url = args['initialUrl'] as String;
        if (url.isNotEmpty && _linkCtrl.text.isEmpty) {
          _linkCtrl.text = url;
        }
      }
    });

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

    setState(() => _isImporting = true);
    widget.isImportingNotifier?.value = true;

    try {
      final recipe = await RecipeService.instance.importRecipeFromUrl(url);
      if (!mounted) return;

      Navigator.pushNamed(
        context,
        AppRoutes.recipeDetail,
        arguments: {'recipe': recipe, 'isPreview': true},
      );
    } catch (e) {
      if (!mounted) return;
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
    setState(() {
      _isSearching = true;
      _searchResults = [];
    });
    try {
      final res = await RecipeService.instance.searchWeb(
        val.trim(),
      );
      if (mounted) {
        setState(() {
          _searchResults = res;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
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
    _linkCtrl.dispose();
    _searchCtrl.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isImporting) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const ImportLoadingPage(),
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
            // ── Title ────────────────────────────────────────────────────────
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

            // ── "Recipe Link" label ───────────────────────────────────────────
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

            // ── Platform icons row ────────────────────────────────────────────
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

            // ── Paste-link field ──────────────────────────────────────────────
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
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
                            hasText
                                ? Icons.close_rounded
                                : Icons.content_paste_rounded,
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

            // ── Import Recipes button ─────────────────────────────────────────
            GestureDetector(
              onTap: () => _importFromUrl(_linkCtrl.text.trim()),
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCC3333),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Center(
                  child: Text(
                    'Import Recipes',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ── OR divider ────────────────────────────────────────────────────
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

            // ── Search web ────────────────────────────────────────────────────
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
                    )
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
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFCC3333),
                    ),
                  ),
                ),
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
                children: _trendingRecipes
                    .map((name) => _TrendingChip(
                          name: name,
                          onImport: () {
                            _searchCtrl.text = name;
                            _handleWebSearch(name);
                          },
                        ))
                    .toList(),
              ),
              SizedBox(height: 25.h),
            ],

            // ── Recent Imports ────────────────────────────────────────────────
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
                      const Center(child: CircularProgressIndicator())
                    else if (list.isEmpty)
                      Center(
                        child: Text(
                          'No recent imports yet.',
                          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                        ),
                      )
                    else
                      ...list.map((r) {
                        // Determine source based on sourceUrl
                        String source = 'Web';
                        IconData icon = Icons.language_rounded;
                        Color iconColor = const Color(0xFF888888);

                        if (r.sourceUrl?.contains('instagram.com') ?? false) {
                          source = 'Instagram';
                          icon = Icons.camera_alt_rounded;
                          iconColor = const Color(0xFFe6683c);
                        } else if (r.sourceUrl?.contains('tiktok.com') ?? false) {
                          source = 'TikTok';
                          icon = Icons.music_note_rounded;
                          iconColor = Colors.black;
                        } else if (r.sourceUrl?.contains('youtube.com') ?? false) {
                          source = 'YouTube';
                          icon = Icons.play_arrow_rounded;
                          iconColor = Colors.red;
                        } else if (r.sourceUrl?.contains('facebook.com') ?? false) {
                          source = 'Facebook';
                          icon = Icons.facebook_rounded;
                          iconColor = Colors.blue;
                        }

                        // Determine source asset if available
                        String? sourceAsset;
                        if (source == 'Instagram') {
                          sourceAsset = 'assets/images/instagram.png';
                        } else if (source == 'TikTok') {
                          sourceAsset = 'assets/images/tiktok.png';
                        } else if (source == 'YouTube') {
                          sourceAsset = 'assets/images/youtube.png';
                        } else if (source == 'Facebook') {
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

// ── Platform image widget ────────────────────────────────────────────────────────
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
          errorBuilder: (_, __, ___) =>
              Icon(Icons.link_rounded, color: Colors.black, size: 20.sp),
        ),
      ),
    );
  }
}

// ── Trending chip ─────────────────────────────────────────────────────────────
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
            Container(
              child: SvgPicture.asset(
                'assets/icones/trending.svg',
                height: 10.sp,
                width: 10.sp,
                placeholderBuilder: (context) => SizedBox(
                  height: 10.sp,
                  width: 10.sp,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
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

// ── Recent import tile ────────────────────────────────────────────────────────
class _RecentImportTile extends StatelessWidget {
  final String img;
  final String title;
  final String source;
  final String? sourceUrl;
  final IconData srcIcon;
  final Color srcIconColor;
  final String? srcAsset;
  const _RecentImportTile({
    required this.img,
    required this.title,
    required this.source,
    this.sourceUrl,
    required this.srcIcon,
    required this.srcIconColor,
    this.srcAsset,
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
      return Image.asset(
        'assets/images/recipes.png',
        fit: BoxFit.cover,
      );
    }
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: const Color(0xFFF2F1EF),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFCC3333)),
          ),
        ),
        errorWidget: (_, __, ___) => Image.asset(
          'assets/images/recipes.png',
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/recipes.png',
        fit: BoxFit.cover,
      ),
    );
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
          // Rounded square thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: 56.w,
              height: 56.h,
              child: _buildImage(img),
            ),
          ),
          SizedBox(width: 14.w),
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
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 4.h),
                GestureDetector(
                  onTap: _launchUrl,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(3.r),
                        decoration: BoxDecoration(
                          color: srcAsset != null ? Colors.transparent : const Color(0xFF757A84),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: srcAsset != null
                            ? Image.asset(srcAsset!, width: 14.w, height: 14.h, fit: BoxFit.contain)
                            : Icon(srcIcon, size: 10.sp, color: Colors.white),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          source,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 13.sp,
                            color: const Color(0xFF757A84),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Web search results ────────────────────────────────────────────────────────
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
                  color: const Color(0xFFCC3333),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...results.map(
          (res) => _SearchResultTile(
            title: res['title'] ?? '',
            url: res['url'] ?? res['link'] ?? '',
            snippet: res['snippet'] ?? '',
            onView: () => onView(res['url'] ?? res['link'] ?? '', res['title'] ?? 'Recipe Preview'),
          ),
        ),
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
                color: const Color(0xFFCC3333),
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

// ── Recipe Web Preview Modal ──────────────────────────────────────────────────
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
            // Allow initial URL and simple redirects/subdomains
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
            // Header
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
            
            // WebView
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(
                    controller: _controller,
                    gestureRecognizers: {
                      Factory<VerticalDragGestureRecognizer>(
                        () => VerticalDragGestureRecognizer(),
                      ),
                    },
                  ),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: Color(0xFFCC3333)),
                    ),
                ],
              ),
            ),
            
            // Actions
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 35.h),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: widget.onImport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC3333),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Import this recipe',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
