import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app_ecommerce/models/category.dart';
import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/models/testimonial.dart'; // Added
import 'package:app_ecommerce/utils/constants.dart';
import 'package:app_ecommerce/widgets/category_item.dart';
import 'package:app_ecommerce/widgets/search_bar_widget.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

      final categories = await CategoryService.getCategories();
      final products = await ProductService.getProducts();
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
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
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchData,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // Header: Search Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.defaultPadding,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: SearchBarWidget(
                                  onSearch: (query) {
                                    setState(() {
                                      _searchQuery = query;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Categories List
                        if (_categories.isNotEmpty)
                          SizedBox(
                            height: 110,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.defaultPadding,
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

                        const SizedBox(height: 24),

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
                              SizedBox(
                                height: 80, // Height of the audio card
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
                              const SizedBox(height: 24),
                            ],
                          );
                        }(),

                        // Social Proof
                        SocialProofSection(
                          testimonials: _testimonials,
                          categories: _categories,
                        ),

                        const SizedBox(height: 24),

                        // Dynamic Category Sections
                        ..._buildCategorySections(),

                        const SizedBox(height: 16),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
              Navigator.push(
                context,
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (context, _, __) =>
                      VideoPreviewScreen(product: product),
                ),
              );
            },
          ),
        );
        sections.add(const SizedBox(height: 24));
      }
    }
    return sections;
  }
}
