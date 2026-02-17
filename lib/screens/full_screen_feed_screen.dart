import 'package:flutter/material.dart';
import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/widgets/video_feed_item.dart';
import 'package:app_ecommerce/data/mock_database.dart';

class FullScreenFeedScreen extends StatefulWidget {
  final String? initialProductId;

  const FullScreenFeedScreen({super.key, this.initialProductId});

  @override
  State<FullScreenFeedScreen> createState() => _FullScreenFeedScreenState();
}

class _FullScreenFeedScreenState extends State<FullScreenFeedScreen> {
  late PageController _pageController;
  late List<Product> _products;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // 1. Fetch all products
    final allProducts = List<Product>.from(MockDatabase.products);

    // 2. Separate initial product if exists
    Product? initialProduct;
    if (widget.initialProductId != null) {
      try {
        initialProduct = allProducts.firstWhere(
          (p) => p.id == widget.initialProductId,
        );
        allProducts.removeWhere((p) => p.id == widget.initialProductId);
      } catch (e) {
        // Product not found or error
      }
    }

    // 3. Shuffle the rest
    allProducts.shuffle();

    // 4. Re-insert initial product at the beginning
    if (initialProduct != null) {
      _products = [initialProduct, ...allProducts];
    } else {
      _products = allProducts;
    }

    // 5. Start at 0 since target is now first
    _currentIndex = 0;
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical, // TikTok/Reels style
        itemCount: _products.length,
        // Pre-load adjacent pages for instant playback
        allowImplicitScrolling: true,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          // Consider adjacent videos as "focused" to pre-load them
          final isCurrent = index == _currentIndex;

          return VideoFeedItem(product: _products[index], isFocused: isCurrent);
        },
      ),
    );
  }
}
