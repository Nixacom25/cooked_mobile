import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../widgets/app_search_field.dart';
import '../services/recipe_service.dart';
import '../models/recipe.dart';
import 'home/view_all_screen.dart';
import '../routes/app_routes.dart';
import '../widgets/import_loading_page.dart';
import '../core/widgets/ios_toast.dart';
import '../core/utils/error_helper.dart';
import '../core/utils/tutorial_helper.dart';
import '../core/services/tutorial_service.dart';

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
      if (TutorialService.instance.isTutorialActive && TutorialService.instance.currentStep == 2) {
        TutorialHelper.showImportOnboardingDialog(context);
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
      final imports = await RecipeService.instance.getRecentImports(size: 6);
      if (mounted) {
        setState(() {
          _recentImportsList = imports;
          _isLoadingRecent = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingRecent = false);
    }
  }

  final _linkCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  bool _isImporting = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  List<Recipe> _recentImportsList = [];
  bool _isLoadingRecent = true;

  static const _trending = [
    'High protein dinner',
    'Quinoa salad with chickpeas',
    'Grilled salmon with asparagus',
    'Stuffed bell peppers with turkey',
    'Lentil soup with spinach',
    'Tofu stir-fry with broccoli',
  ];

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

  // static const _recentImports = ... REMOVED in favor of _recentImportsList

  @override
  void dispose() {
    widget.isActiveNotifier?.removeListener(_onActiveStateChanged);
    _linkCtrl.dispose();
    _searchCtrl.dispose();
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(18.w, 30.h, 18.w, 120.h),
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
                        fillColor: Colors
                            .transparent, // Background handled by outer Container
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
                  GestureDetector(
                    onTap: () async {
                      final d = await Clipboard.getData('text/plain');
                      if (d?.text != null) _linkCtrl.text = d!.text!;
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 18.w),
                      child: Icon(
                        Icons.content_paste_rounded,
                        size: 20.sp,
                        color: const Color(0xFF7A8499),
                      ),
                    ),
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
                onSuffixTap: () => _handleWebSearch(_searchCtrl.text),
                onSubmitted: (val) => _handleWebSearch(val),
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
                onImport: (url) => _importFromUrl(url),
                onClear: () => setState(() => _searchResults = []),
              ),

            if (_searchResults.isEmpty && !_isSearching) ...[
              // ── Trending ──────────────────────────────────────────────────────
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
                children: _trending
                    .map((t) => _TrendingChip(label: t))
                    .toList(),
              ),

              SizedBox(height: 25.h),

              // ── Recent Imports ────────────────────────────────────────────────
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

              if (_isLoadingRecent)
                const Center(child: CircularProgressIndicator())
              else if (_recentImportsList.isEmpty)
                Center(
                  child: Text(
                    'No recent imports yet.',
                    style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                  ),
                )
              else
                ..._recentImportsList.map((r) {
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
                      srcIcon: icon,
                      srcIconColor: iconColor,
                    ),
                  );
                }),
            ],
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
    return Container(
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
  final String label;
  const _TrendingChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            label,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 13.sp,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent import tile ────────────────────────────────────────────────────────
class _RecentImportTile extends StatelessWidget {
  final String img;
  final String title;
  final String source;
  final IconData srcIcon;
  final Color srcIconColor;
  const _RecentImportTile({
    required this.img,
    required this.title,
    required this.source,
    required this.srcIcon,
    required this.srcIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          // Rounded square thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: 60.w,
              height: 60.h,
              child: Image.network(
                img,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFEEEEEE),
                  child: Icon(
                    Icons.fastfood_rounded,
                    size: 24.sp,
                    color: const Color(0xFFCCCCCC),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFF757A84),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(srcIcon, size: 12.sp, color: Colors.white),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      source,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 14.sp,
                        color: const Color(0xFF757A84),
                      ),
                    ),
                  ],
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
  final Function(String) onImport;
  final VoidCallback onClear;

  const _WebSearchResults({
    required this.results,
    required this.onImport,
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
            url: res['url'] ?? '',
            snippet: res['snippet'] ?? '',
            onImport: () => onImport(res['url'] ?? ''),
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
  final VoidCallback onImport;

  const _SearchResultTile({
    required this.title,
    required this.url,
    required this.snippet,
    required this.onImport,
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
            onTap: onImport,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFCC3333),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Magic Import',
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
