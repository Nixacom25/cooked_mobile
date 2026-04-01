import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app_ecommerce/models/category.dart';
import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/models/testimonial.dart'; // Added
import 'package:app_ecommerce/utils/constants.dart';
import 'package:app_ecommerce/widgets/category_item.dart';
import 'package:app_ecommerce/widgets/audio_player_card.dart';
import 'package:app_ecommerce/widgets/social_proof_section.dart';
import 'package:app_ecommerce/services/category_service.dart'; // Added
import 'package:app_ecommerce/services/product_service.dart'; // Added
import 'package:app_ecommerce/services/testimonial_service.dart'; // Added

import 'package:app_ecommerce/models/advertisement.dart'; // Added
import 'package:app_ecommerce/services/advertisement_service.dart'; // Added
import 'package:app_ecommerce/services/data_cache_service.dart'; // Added
import 'package:app_ecommerce/widgets/category_section.dart';
import 'package:app_ecommerce/screens/category_details_screen.dart';
import 'package:app_ecommerce/screens/video_preview_screen.dart';
import 'package:app_ecommerce/widgets/empty_state_widget.dart';
import 'package:app_ecommerce/widgets/login_banner.dart';
import 'package:app_ecommerce/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final String? searchQuery;
  const HomeScreen({super.key, this.searchQuery});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  List<Category> _categories = [];
  List<Product> _allProducts = [];
  List<Testimonial> _testimonials = [];
  List<Advertisement> _advertisements = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = "";

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.searchQuery ?? "";

    // Check cache first for instant load
    final cache = DataCacheService();
    if (cache.hasData) {
      _categories = [
        Category(id: 'all', name: 'Tout', imageUrl: ''),
        ...cache.categories!,
      ];
      _allProducts = cache.products!;
      _testimonials = cache.testimonials!;
      _advertisements = cache.advertisements!;
      _isLoading = false;
    }

    // Then fetch fresh data
    _fetchData();

    // Refresh data every 5 seconds for "real-time" feel
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _fetchData();
      }
    });
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      setState(() {
        _searchQuery = widget.searchQuery ?? "";
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      // Only show loading indicator if we don't have data yet
      if (_categories.isEmpty && _allProducts.isEmpty) {
        setState(() {
          _isLoading = true;
        });
      }

      final user = AuthService().currentUser.value;
      final clientId = user != null
          ? '${user['firstName']} ${user['lastName']}'
          : 'client123';

      final categories = await CategoryService.getCategories();
      final products = await ProductService.getProducts(clientId: clientId);
      final testimonials = await TestimonialService.getTestimonials();
      final advertisements =
          await AdvertisementService.getAdvertisements(); // Added

      if (mounted) {
        setState(() {
          // Prepend "Tout" category
          _categories = [
            Category(id: 'all', name: 'Tout', imageUrl: ''),
            ...categories,
          ];
          _allProducts = products;
          _testimonials = testimonials;
          _advertisements = advertisements;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToCategoryDetails(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailsScreen(
          initialCategory: category,
          allCategories: _categories.skip(1).toList(), // Exclude "Tout"
          products: _allProducts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _categories.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null && _categories.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_errorMessage'),
              ElevatedButton(onPressed: _fetchData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: AuthService().isLoggedIn,
                        builder: (context, isLoggedIn, _) {
                          if (isLoggedIn) return const SizedBox.shrink();
                          return ValueListenableBuilder<bool>(
                            valueListenable: AuthService().isBannerVisible,
                            builder: (context, isVisible, _) {
                              if (!isVisible) return const SizedBox.shrink();
                              return const LoginBanner();
                            },
                          );
                        },
                      ),

                      // Categories List
                      if (_categories.isNotEmpty)
                        SizedBox(
                          height: 110,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.defaultPadding,
                              vertical: 10,
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              return CategoryItem(
                                category: _categories[index],
                                isSelected: index == _selectedCategoryIndex,
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryIndex = index;
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 10),

                      // Audio Player Carousel (Advertisements)
                      () {
                        final activeAds = _advertisements
                            .where(
                              (ad) =>
                                  ad.status == 'ACTIVE' &&
                                  ad.audioUrl.isNotEmpty,
                            )
                            .toList();

                        if (activeAds.isEmpty) return const SizedBox.shrink();

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.defaultPadding,
                                vertical: 10,
                              ),
                              child: SizedBox(
                                height: 60,
                                child: PageView.builder(
                                  scrollDirection: Axis.horizontal,
                                  controller: PageController(
                                    viewportFraction: 1.0,
                                  ),
                                  itemCount: activeAds.length,
                                  itemBuilder: (context, index) {
                                    final ad = activeAds[index];
                                    return AudioPlayerCard(
                                      audioUrl: ad.audioUrl,
                                      title: ad.title,
                                      onPlay: () {
                                        AdvertisementService.incrementListeners(
                                          ad.id,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ), // Gap after Audio Player
                          ],
                        );
                      }(),

                      // Social Proof (Status/Stories)
                      SocialProofSection(
                        testimonials: _testimonials,
                        categories: _categories,
                      ),

                      // Dynamic Category Sections
                      ..._buildCategorySections(),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategorySections() {
    List<Widget> sections = [];

    // Filter categories based on selection (if not "Tout")
    final List<Category> activeCategories = (_selectedCategoryIndex == 0)
        ? _categories
              .skip(1)
              .toList() // All except "Tout"
        : [_categories[_selectedCategoryIndex]];

    for (var category in activeCategories) {
      // Filter products for this category AND search query
      final categoryProducts = _allProducts.where((p) {
        final matchesCategory =
            p.category == category.name || p.category == category.id;
        final matchesSearch =
            _searchQuery.isEmpty ||
            p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.keywords.any(
              (k) => k.toLowerCase().contains(_searchQuery.toLowerCase()),
            );
        return matchesCategory && matchesSearch;
      }).toList();

      if (categoryProducts.isNotEmpty) {
        sections.add(
          CategorySection(
            title: category.name,
            imageUrl: category.imageUrl,
            products: categoryProducts.take(5).toList(),
            onTapSeeMore: () {
              _navigateToCategoryDetails(category);
            },
            onProductTap: (product) {
              final index = categoryProducts.indexOf(product);
              Navigator.push(
                context,
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (context, _, __) => VideoPreviewScreen(
                    products: categoryProducts,
                    initialIndex: index,
                  ),
                ),
              );
            },
          ),
        );
        sections.add(const SizedBox(height: 24));
      }
    }
    if (sections.isEmpty) {
      sections.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: EmptyStateWidget(
            icon: Icons.search_off_rounded,
            title: 'Aucun produit trouvé',
            subtitle: 'Essayez de modifier votre recherche ou votre catégorie.',
          ),
        ),
      );
    }

    return sections;
  }
}
