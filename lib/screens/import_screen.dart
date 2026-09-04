import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../widgets/app_search_field.dart';
import '../widgets/app_top_header.dart';
import '../widgets/red_header_background.dart';
import '../services/recipe_service.dart';
import '../models/recipe.dart';
import '../routes/app_routes.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/haptic_context_menu.dart';
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
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import '../utils/paywall_helper.dart';
import '../widgets/skeleton_list.dart';
import '../widgets/red_button.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/add_to_cookbook_sheet.dart';
import '../widgets/recent_import_tile.dart';

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

class _ImportScreenState extends State<ImportScreen> with TickerProviderStateMixin {
  final Set<String> _validatedRecipeIds = {};
  final GlobalKey _searchFieldKey = GlobalKey();
  
  late AnimationController _importSearchController;
  late Animation<double> _importSearchAnimation;
  OverlayEntry? _importSearchOverlayEntry;
  final _overlaySearchCtrl = TextEditingController();

  double _startTop = 0;
  double _startLeft = 0;
  double _startWidth = 0;

  final _linkCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  bool _isImporting = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  Timer? _searchDebounce;
  List<Map<String, dynamic>> _suggestedWebRecipes = [];

  List<String> _trendingRecipes = [
    'High protein dinner',
    'Quinoa salad with chickpeas',
    'Grilled salmon with asparagus',
    'Stuffed bell peppers with turkey',
    'Lentil soup with spinach',
    'Tofu stir-fry with broccoli',
  ];

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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showWebPreview(widget.initialUrl!, 'Recipe Preview');
        });
      } else {
        _onSharedUrlUpdated();
      }
    });

    _importSearchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _importSearchAnimation = CurvedAnimation(
      parent: _importSearchController,
      curve: Curves.easeOutQuart,
      reverseCurve: Curves.easeInQuad,
    );

    _overlaySearchCtrl.addListener(() {
      if (_importSearchOverlayEntry != null) {
        _importSearchOverlayEntry!.markNeedsBuild();
      }
    });
  }

  void _onSharedUrlUpdated() {
    if (!mounted) return;
    final url = SharingService.instance.sharedTextNotifier.value;
    if (url != null && url.isNotEmpty) {
      if (!_isImporting && _linkCtrl.text != url) {
        _linkCtrl.text = url;
        SharingService.instance.consumeSharedText();
        _showWebPreview(url, 'Recipe Preview');
      }
    }
  }

  void _onActiveStateChanged() {
    if (widget.isActiveNotifier?.value ?? false) {
      if (!TutorialService.instance.hasSeenImport) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            TutorialHelper.showImportOnboardingDialog(context);
          }
        });
      }
    }
  }

  Future<void> _loadRecentImports() async {
    try {
      await RecipeService.instance.getRecentImports(size: 5);
    } catch (_) {}
  }

  Future<void> _loadTrending() async {
    try {
      final trending = await RecipeService.instance.getTrendingAiDishes();
      if (mounted && trending.isNotEmpty) {
        setState(() {
          _trendingRecipes = trending;
        });
      }
    } catch (_) {}
  }



  Future<void> _showWebPreview(String url, String title) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.zero),
      ),
      builder: (context) {
        return _RecipeWebPreviewModal(
          url: url,
          title: title,
          onImport: () {
            Navigator.pop(context);
            _importFromUrl(url);
          },
        );
      },
    );
  }

  Future<void> _importFromUrl(String url) async {
    if (url.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _isImporting = true);
    widget.isImportingNotifier?.value = true;

    final savedRecipes = RecipeService.instance.myRecipesNotifier.value ?? [];
    final recentImports = RecipeService.instance.recentImportsNotifier.value ?? [];
    
    Recipe? existing;
    final searchUrl = url.trim().toLowerCase();

    for (final r in savedRecipes) {
      if (r.sourceUrl?.trim().toLowerCase() == searchUrl) {
        existing = r;
        break;
      }
    }
    if (existing == null) {
      for (final r in recentImports) {
        if (r.sourceUrl?.trim().toLowerCase() == searchUrl) {
          existing = r;
          break;
        }
      }
    }

    if (existing != null) {
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRoutes.recipeDetail,
        arguments: {
          'recipe': existing,
          'isPreview': existing.isSuggested,
          'infoMessage': 'This recipe already exists in your collection',
        },
      );
      setState(() => _isImporting = false);
      widget.isImportingNotifier?.value = false;
      return;
    }

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
    _importSearchOverlayEntry?.markNeedsBuild();
    try {
      final res = await RecipeService.instance.searchWeb(val.trim());
      if (mounted) {
        setState(() {
          _searchResults = res;
          _isSearching = false;
        });
        _importSearchOverlayEntry?.markNeedsBuild();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        _importSearchOverlayEntry?.markNeedsBuild();
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
    if (val.trim().isEmpty) {
      setState(() => _suggestedWebRecipes = []);
      _importSearchOverlayEntry?.markNeedsBuild();
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 150), () async {
      try {
        final res = await IngredientService.instance.searchIngredients(val.trim());
        if (mounted) {
          setState(() {
            _suggestedWebRecipes = res.take(5).toList();
          });
          _importSearchOverlayEntry?.markNeedsBuild();
        }
      } catch (_) {}
    });
  }

  String _capitalize(String text) {
    return text.toTitleCase();
  }

  void _handleValidation(Recipe r) async {
    if (r.isInCookbook) {
      IosToast.show(
        context,
        message: "Already in your recipes",
        type: ToastType.success,
      );
      return;
    }

    _updateLocalStateForValidation(r);

    RecipeService.instance.validateRecipe(r.id).catchError((e) {
      if (mounted) {
        IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
      }
      return r;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddToCookbookSheet(
        recipe: r,
        onSuccess: () => _updateLocalStateForValidation(r),
      ),
    );
  }

  void _updateLocalStateForValidation(Recipe r) {
    if (!mounted) return;
    
    final validatedRecipe = r.copyWith(origin: 'MANUAL', isValidated: true, isSuggested: false);

    setState(() => _validatedRecipeIds.add(r.id));

    final currentSaved = RecipeService.instance.myRecipesNotifier.value ?? [];
    if (!currentSaved.any((item) => item.id == r.id)) {
      RecipeService.instance.myRecipesNotifier.value = [validatedRecipe, ...currentSaved];
    }

    RecipeService.instance.getMyRecipes(forceRefresh: true).catchError((_) => <Recipe>[]);
    RecipeService.instance.getRecentImports(forceRefresh: true).catchError((_) => <Recipe>[]);
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _validatedRecipeIds.remove(r.id));
      }
    });
  }

  Future<void> _handleDeleteRecipe(Recipe r) async {
    final success = await RecipeService.instance.deleteRecipe(r.id);
    if (!mounted) return;
    if (success) {
      await RecipeService.instance.getRecentImports(forceRefresh: true);
      if (!mounted) return;
      setState(() {});
      IosToast.show(context, message: 'Recipe deleted', type: ToastType.success);
    }
  }

  @override
  void dispose() {
    widget.isActiveNotifier?.removeListener(_onActiveStateChanged);
    SharingService.instance.sharedTextNotifier.removeListener(_onSharedUrlUpdated);
    _linkCtrl.dispose();
    _searchCtrl.dispose();
    _overlaySearchCtrl.dispose();
    _importSearchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _toggleSearchModal(bool open) {
    if (open) {
      final RenderBox? renderBox = _searchFieldKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final pos = renderBox.localToGlobal(Offset.zero);
        setState(() {
          _startTop = pos.dy;
          _startLeft = pos.dx;
          _startWidth = renderBox.size.width;
          _isSearchingModal = true;
        });
      } else {
        setState(() => _isSearchingModal = true);
      }
      _importSearchController.forward();
      _showImportSearchOverlay();
    } else {
      _importSearchController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isSearchingModal = false;
            _overlaySearchCtrl.clear();
            _searchResults = [];
          });
          _removeImportSearchOverlay();
        }
      });
    }
  }

  bool _isSearchingModal = false;

  void _showImportSearchOverlay() {
    _removeImportSearchOverlay();
    _importSearchOverlayEntry = OverlayEntry(
      builder: (context) => _buildImportSearchOverlay(),
    );
    Overlay.of(context, rootOverlay: true).insert(_importSearchOverlayEntry!);
  }

  void _removeImportSearchOverlay() {
    _importSearchOverlayEntry?.remove();
    _importSearchOverlayEntry = null;
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Background gradient at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 240.h,
              child: const RedHeaderBackground(),
            ),
            Column(
              children: [
                // Standard App Top Header
                const AppTopHeader(),

                // Main White Container Sheet
                Expanded(
                  child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, bottomInset + 120.h),
                    children: [
                      // Header Title: "Import"
                      Text(
                        'Import',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontWeight: FontWeight.w800,
                          fontSize: 24.sp,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Section Title: "Recipe Link"
                      Center(
                        child: Text(
                          'Recipe Link',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.w800,
                            fontSize: 16.sp,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // Social Platforms Row (Instagram, TikTok, Facebook, YouTube)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          _SocialPlatformCard(
                            label: 'Instagram',
                            asset: 'assets/icones/instagram2.svg',
                          ),
                          _SocialPlatformCard(
                            label: 'TikTok',
                            asset: 'assets/icones/tiktok2.svg',
                          ),
                          _SocialPlatformCard(
                            label: 'Facebook',
                            asset: 'assets/icones/facebook2.svg',
                          ),
                          _SocialPlatformCard(
                            label: 'YouTube',
                            asset: 'assets/icones/youtube.svg',
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      // Input Box for Link
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _linkCtrl,
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 14.sp,
                                  color: const Color(0xFF0F172A),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Paste a recipe link...',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 14.sp,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
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
                                    padding: EdgeInsets.only(right: 16.w),
                                    child: Icon(
                                      hasText ? Icons.close_rounded : Icons.content_paste_rounded,
                                      size: 20.sp,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Import Recipes Red Pill Button
                      RedButton(
                        label: 'Import Recipes',
                        loadingLabel: 'Importing',
                        isLoading: _isImporting,
                        onTap: () => _importFromUrl(_linkCtrl.text.trim()),
                        height: 50.h,
                        fontSize: 15.sp,
                      ),
                      SizedBox(height: 24.h),

                      // Divider "── OR ──"
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14.w),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Search Web Box
                      Opacity(
                        opacity: _isSearchingModal ? 0.0 : 1.0,
                        child: GestureDetector(
                          onTap: () => _toggleSearchModal(true),
                          child: AbsorbPointer(
                            child: Container(
                              height: 50.h,
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search_rounded, color: const Color(0xFF64748B), size: 22.sp),
                                  SizedBox(width: 10.w),
                                  Text(
                                    'Search web',
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      fontSize: 14.sp,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (_suggestedWebRecipes.isNotEmpty && !_isSearching)
                        Container(
                          margin: EdgeInsets.only(top: 8.h),
                          constraints: BoxConstraints(maxHeight: 250.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
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
                                  style: TextStyle(fontFamily: 'Rubik', fontSize: 14.sp),
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

                      SizedBox(height: 24.h),

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

                      // Trending Section
                      if (_trendingRecipes.isNotEmpty) ...[
                        Text(
                          'Trending',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.w800,
                            fontSize: 16.sp,
                            color: const Color(0xFF0F172A),
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
                        SizedBox(height: 28.h),
                      ],

                      // Recent Imports Section
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
                                      fontFamily: 'Rubik',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18.sp,
                                      color: const Color(0xFF0F172A),
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
                                          fontFamily: 'Rubik',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.sp,
                                          color: const Color(0xFFC31E26),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 14.h),
                              if (importsList == null)
                                const SkeletonList(height: 80, itemCount: 3)
                              else if (list.isEmpty)
                                Center(
                                  child: Text(
                                    'No recent imports yet.',
                                    style: TextStyle(fontFamily: 'Rubik', color: const Color(0xFF94A3B8), fontSize: 13.sp),
                                  ),
                                )
                              else
                                ...list.take(5).toList().asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final r = entry.value;
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

                                  final savedList = RecipeService.instance.myRecipesNotifier.value ?? [];
                                  final bool isSaved = _validatedRecipeIds.contains(r.id) ||
                                      r.isInCookbook ||
                                      r.isFavorite ||
                                      savedList.any((rec) => rec.id == r.id || (rec.name.isNotEmpty && rec.name.toLowerCase() == r.name.toLowerCase()));

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.recipeDetail,
                                        arguments: {
                                          'recipe': r,
                                          'isPreview': !isSaved,
                                        },
                                      );
                                    },
                                    onLongPressStart: (details) {
                                      HapticContextMenu.show(
                                        context,
                                        targetPosition: details.globalPosition,
                                        actions: [
                                          HapticMenuAction(
                                            title: 'Edit Recipe',
                                            icon: Icons.edit_outlined,
                                            onTap: () {},
                                          ),
                                          HapticMenuAction(
                                            title: 'Share Recipe',
                                            icon: Icons.ios_share_rounded,
                                            onTap: () {},
                                          ),
                                          HapticMenuAction(
                                            title: 'Delete Recipe',
                                            icon: Icons.delete_outline_rounded,
                                            isDestructive: true,
                                            onTap: () => _handleDeleteRecipe(r),
                                          ),
                                        ],
                                      );
                                    },
                                    child: RecentImportTile(
                                      img: r.image ?? '',
                                      title: r.name,
                                      source: source,
                                      sourceUrl: r.sourceUrl,
                                      srcIcon: icon,
                                      srcIconColor: iconColor,
                                      srcAsset: sourceAsset,
                                      isSuggested: true,
                                      index: i,
                                      onValidate: () => _handleValidation(r),
                                      isValidated: isSaved,
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
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);
  }

  Widget _buildImportSearchOverlay() {
    return AnimatedBuilder(
      animation: _importSearchAnimation,
      builder: (context, child) {
        final val = _importSearchAnimation.value;
        final size = MediaQuery.of(context).size;
        final topPadding = MediaQuery.of(context).padding.top;

        final originalTop = _startTop > 0 ? _startTop : 400.0;
        final originalLeft = _startLeft > 0 ? _startLeft : 20.w;
        final originalWidth = _startWidth > 0 ? _startWidth : size.width - 40.w;

        final sheetHeight = val * size.height;
        final fieldTop = Tween<double>(begin: originalTop, end: topPadding + 10.h).transform(val);
        final fieldLeft = Tween<double>(begin: originalLeft, end: 16.w).transform(val);
        final fieldWidth = Tween<double>(begin: originalWidth, end: size.width - 32.w).transform(val);

        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: sheetHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular((1 - val) * 30.r)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1 * val),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      )
                    ],
                  ),
                ),
              ),

              Positioned.fill(
                top: topPadding + 80.h,
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _importSearchController,
                    curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
                  ),
                  child: IgnorePointer(
                    ignoring: val < 0.8,
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 40.h),
                      children: [
                        if (_overlaySearchCtrl.text.isEmpty && !_isSearching) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Text(
                              'Recommended',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontWeight: FontWeight.w800,
                                fontSize: 16.sp,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    {'name': 'Healthy', 'icon': '🥑'},
                                    {'name': 'Pizza', 'icon': '🍕'},
                                    {'name': 'Fast Food', 'icon': '🍟'},
                                    {'name': 'Sushi', 'icon': '🍣'},
                                    {'name': 'Pasta', 'icon': '🍝'},
                                    {'name': 'Chicken', 'icon': '🍗'},
                                    {'name': 'Ramen', 'icon': '🍜'},
                                    {'name': 'Seafood', 'icon': '🦞'},
                                    {'name': 'Salad', 'icon': '🥗'},
                                  ].map((item) => Padding(
                                    padding: EdgeInsets.only(right: 8.w, bottom: 8.h),
                                    child: _TrendingChip(
                                      name: item['name']!,
                                      icon: item['icon'],
                                      onImport: () {
                                        _overlaySearchCtrl.text = item['name']!;
                                        _handleWebSearch(item['name']!);
                                      },
                                    ),
                                  )).toList(),
                                ),
                              ],
                            ),
                          ),
                          if (_trendingRecipes.isNotEmpty) ...[
                            SizedBox(height: 24.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Text(
                                'Trending',
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16.sp,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Row(
                                children: _trendingRecipes.map((name) => Padding(
                                  padding: EdgeInsets.only(right: 8.w),
                                  child: _TrendingChip(
                                    name: name,
                                    onImport: () {
                                      _overlaySearchCtrl.text = name;
                                      _handleWebSearch(name);
                                    },
                                  ),
                                )).toList(),
                              ),
                            ),
                          ],
                        ] else if (_suggestedWebRecipes.isNotEmpty && !_isSearching && _searchResults.isEmpty) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Suggestions',
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16.sp,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                ..._suggestedWebRecipes.map((res) {
                                  final name = _capitalize(res['name'] ?? '');
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(Icons.north_west_rounded, size: 18.sp, color: Colors.grey),
                                    title: Text(name, style: TextStyle(fontFamily: 'Rubik', fontSize: 14.sp)),
                                    onTap: () {
                                      _overlaySearchCtrl.text = name;
                                      _handleWebSearch(name);
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                        ] else if (_isSearching)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                            child: const SkeletonList(height: 80, itemCount: 4),
                          )
                        else if (_searchResults.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: _WebSearchResults(
                              results: _searchResults,
                              onView: (url, title) => _showWebPreview(url, title),
                              onClear: () => setState(() {
                                _searchResults = [];
                                _overlaySearchCtrl.clear();
                                _importSearchOverlayEntry?.markNeedsBuild();
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                top: fieldTop,
                left: fieldLeft,
                width: fieldWidth,
                child: Row(
                  children: [
                    if (val > 0.9)
                      FadeTransition(
                        opacity: _importSearchAnimation,
                        child: GestureDetector(
                          onTap: () => _toggleSearchModal(false),
                          child: Padding(
                            padding: EdgeInsets.only(right: 12.w),
                            child: Icon(Icons.close, color: Colors.black87, size: 22.sp),
                          ),
                        ),
                      ),
                    Expanded(
                      child: AppSearchField(
                        controller: _overlaySearchCtrl,
                        hintText: 'Search recipes...',
                        backgroundColor: Colors.white,
                        suffixIcon: Icons.check_circle_rounded,
                        borderColor: val > 0.5 ? const Color(0xFFEEEEEE) : Colors.transparent,
                        onSuffixTap: () {
                          setState(() => _suggestedWebRecipes = []);
                          _handleWebSearch(_overlaySearchCtrl.text);
                        },
                        onSubmitted: (v) {
                          setState(() => _suggestedWebRecipes = []);
                          _handleWebSearch(v);
                        },
                        onChanged: (v) {
                          setState(() => _searchResults = []);
                          _onSearchChanged(v);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SocialPlatformCard extends StatelessWidget {
  final String label;
  final String asset;

  const _SocialPlatformCard({
    required this.label,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76.w,
      height: 76.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: asset.endsWith('.svg')
                  ? SvgPicture.asset(
                      asset,
                      width: 18.r,
                      height: 18.r,
                      fit: BoxFit.contain,
                    )
                  : Image.asset(
                      asset,
                      width: 18.r,
                      height: 18.r,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.link_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingChip extends StatelessWidget {
  final String name;
  final String? icon;
  final VoidCallback onImport;
  const _TrendingChip({required this.name, this.icon, required this.onImport});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onImport,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Text(
                icon!,
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(width: 6.w),
            ] else ...[
              Icon(
                Icons.trending_up_rounded,
                size: 16.sp,
                color: const Color(0xFF475569),
              ),
              SizedBox(width: 8.w),
            ],
            Text(
              name.toTitleCase(),
              style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: const Color(0xFF334155),
              ),
            ),
          ],
        ),
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
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: const Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: onClear,
              child: Text(
                'Clear',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC31E26),
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
        const Divider(color: Color(0xFFE2E8F0)),
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            snippet,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: onView,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFC31E26),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'View this recipe',
                style: TextStyle(
                  fontFamily: 'Rubik',
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close_rounded, size: 24.sp, color: const Color(0xFF0F172A)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Container(
                        height: 38.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            Expanded(
                              flex: 8,
                              child: Text(
                                Uri.parse(widget.url).host,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 14.sp,
                                  color: const Color(0xFF4B5563),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.refresh_rounded, size: 18.sp, color: const Color(0xFF4B5563)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 48.w),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
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
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
                ),
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 30.h),
                child: RedButton(
                  label: 'Import to Cooked',
                  loadingLabel: 'Importing',
                  onTap: widget.onImport,
                  height: 52.h,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
