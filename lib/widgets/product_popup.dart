import 'package:flutter/material.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/services/global_video_cache.dart';
import 'package:app_ecommerce/services/cart_service.dart';
import 'package:app_ecommerce/widgets/quantity_selector.dart';
import 'package:app_ecommerce/widgets/service_option_selector.dart';
import 'package:app_ecommerce/widgets/comments_modal.dart';
import 'package:share_plus/share_plus.dart';

class ProductPopup extends StatefulWidget {
  final Product product;
  final int initialIndex;
  final List<Product> allProducts;

  const ProductPopup({
    super.key,
    required this.product,
    required this.initialIndex,
    required this.allProducts,
  });

  @override
  State<ProductPopup> createState() => _ProductPopupState();
}

class _ProductPopupState extends State<ProductPopup> {
  late PageController _pageController;
  late int _currentIndex;

  // Product state
  int _quantity = 1;
  bool _includeInstallation = false;
  bool _showOrderOptions = false; // Show quantity/service selectors
  bool _isDescriptionExpanded = false; // Expand description
  bool _isMuted = true; // Default muted like TikTok
  bool _showControls = false; // Show pause/play overlay
  bool _isLiked = false; // Like state
  bool _showHeart = false; // Show heart animation
  Timer? _tapTimer; // Timer for single/double tap distinction

  // Video controllers cache
  final Map<int, VideoPlayerController?> _controllers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    // Preload current and adjacent videos
    _preloadVideos();

    // Play current video
    GlobalVideoCache.play(
      widget.allProducts[_currentIndex].videoUrl,
      ownerId: toString(),
    );
  }

  void _preloadVideos() {
    final indices = [_currentIndex - 1, _currentIndex, _currentIndex + 1];

    for (final index in indices) {
      if (index >= 0 && index < widget.allProducts.length) {
        _loadVideo(index);
      }
    }
  }

  Future<void> _loadVideo(int index) async {
    if (_controllers.containsKey(index)) return;

    final product = widget.allProducts[index];
    try {
      final controller = await GlobalVideoCache.getController(product.videoUrl);
      if (mounted) {
        setState(() {
          _controllers[index] = controller;
        });
      }
    } catch (e) {
      print('Error loading video for index $index: $e');
      if (mounted) {
        setState(() {
          _controllers[index] = null;
        });
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      // Pause previous video
      final prevProduct = widget.allProducts[_currentIndex];
      GlobalVideoCache.pause(prevProduct.videoUrl, ownerId: toString());

      // Update index
      _currentIndex = index;

      // Play new video
      final newProduct = widget.allProducts[index];
      // Note: We use toString() as ownerId
      GlobalVideoCache.play(newProduct.videoUrl, ownerId: toString());

      // Preload adjacent videos
      _preloadVideos();

      // Reset state
      _quantity = 1;
      _includeInstallation = false;
      _showOrderOptions = false;
      _isDescriptionExpanded = false;
    });
  }

  void _toggleMute() {
    final controller = _controllers[_currentIndex];
    if (controller != null) {
      setState(() {
        _isMuted = !_isMuted;
        controller.setVolume(_isMuted ? 0.0 : 1.0);
      });
    }
  }

  void _togglePlayPause() {
    final controller = _controllers[_currentIndex];
    if (controller != null) {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
      setState(() {});
    }
  }

  void _handleTap() {
    if (_tapTimer != null && _tapTimer!.isActive) {
      // Double tap detected
      _tapTimer!.cancel();
      _handleDoubleTap();
    } else {
      // Start timer for single tap
      _tapTimer = Timer(const Duration(milliseconds: 300), () {
        // Single tap action confirmed
        _togglePlayPause();
        setState(() {
          _showControls = true;
        });
        // Hide controls after 1 second
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _showControls = false;
            });
          }
        });
      });
    }
  }

  void _handleDoubleTap() {
    setState(() {
      _isLiked = !_isLiked;
      _showHeart = true;
    });

    // Hide heart animation after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showHeart = false;
        });
      }
    });
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsModal(
        productId: _currentProduct.id,
        productTitle: _currentProduct.title,
      ),
    );
  }

  void _handleShare() {
    Share.share(
      'Découvrez ${_currentProduct.title} à ${_currentProduct.price} !\n\nLivraison ${_currentProduct.deliveryFee == 0 ? "GRATUITE" : "disponible"}',
      subject: _currentProduct.title,
    );
  }

  Product get _currentProduct => widget.allProducts[_currentIndex];

  void _handleAddToCart() {
    // Add to cart
    CartService().addProduct(
      _currentProduct,
      quantity: _quantity,
      includeInstallation: _includeInstallation,
    );

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_currentProduct.title} ajouté au panier (x$_quantity)',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Reset and hide options
    setState(() {
      _quantity = 1;
      _includeInstallation = false;
      _showOrderOptions = false;
    });
  }

  @override
  void dispose() {
    // Pause current video
    // Pause with reference counting
    GlobalVideoCache.pause(_currentProduct.videoUrl, ownerId: toString());
    _pageController.dispose();
    // Don't dispose controllers - they're managed by GlobalVideoCache
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video PageView
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: widget.allProducts.length,
            itemBuilder: (context, index) {
              final controller = _controllers[index];

              return GestureDetector(
                onTap: _handleTap,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Video Background
                    if (controller != null && controller.value.isInitialized)
                      FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: controller.value.size.width,
                          height: controller.value.size.height,
                          child: VideoPlayer(controller),
                        ),
                      )
                    else
                      Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),

                    // Play/Pause icon overlay (center)
                    if (_showControls &&
                        controller != null &&
                        index == _currentIndex)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),

                    // Heart animation for double-tap like
                    if (_showHeart && index == _currentIndex)
                      Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.5, end: 1.5),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: 1.5 - value,
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 100,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          // Gradient overlay for readability
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.3, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Top Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Close button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Mute/Unmute button (TikTok style)
                    IconButton(
                      onPressed: _toggleMute,
                      icon: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                        size: 28,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    const Spacer(),
                    // Badges
                    if (_currentProduct.promoLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _currentProduct.promoLabel!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (_currentProduct.deliveryFee == 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'LIVRAISON GRATUITE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Product Info Overlay (Bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.95),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product info with fixed width (left-aligned)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width:
                              MediaQuery.of(context).size.width *
                              0.7, // 70% width
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title and Category Row
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _currentProduct.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Category badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.category,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _currentProduct.category,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Price Row
                              Row(
                                children: [
                                  Text(
                                    _currentProduct.price,
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_currentProduct.originalPrice !=
                                      null) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      _currentProduct.originalPrice!,
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Description (expandable with scroll)
                              if (_currentProduct.description.isNotEmpty) ...[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isDescriptionExpanded =
                                          !_isDescriptionExpanded;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: _isDescriptionExpanded
                                                  ? Container(
                                                      constraints:
                                                          const BoxConstraints(
                                                            maxHeight: 150,
                                                          ),
                                                      child:
                                                          SingleChildScrollView(
                                                            child: Text(
                                                              _currentProduct
                                                                  .description,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[300],
                                                                fontSize: 14,
                                                                height: 1.5,
                                                              ),
                                                            ),
                                                          ),
                                                    )
                                                  : Text(
                                                      _currentProduct
                                                          .description,
                                                      style: TextStyle(
                                                        color: Colors.grey[300],
                                                        fontSize: 14,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              _isDescriptionExpanded
                                                  ? Icons.remove_circle_outline
                                                  : Icons.add_circle_outline,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Order Options (Quantity + Service) - Hidden by default
                      if (_showOrderOptions) ...[
                        const SizedBox(height: 16),

                        // Quantity Selector
                        QuantitySelector(
                          quantity: _quantity,
                          onChanged: (newQuantity) {
                            setState(() {
                              _quantity = newQuantity;
                            });
                          },
                        ),

                        // Service Options (if available)
                        if (_currentProduct.hasInstallationOption) ...[
                          const SizedBox(height: 12),
                          ServiceOptionSelector(
                            includeInstallation: _includeInstallation,
                            onChanged: (value) {
                              setState(() {
                                _includeInstallation = value;
                              });
                            },
                          ),
                        ],

                        const SizedBox(height: 12),

                        // Price Breakdown - Same format as VideoFeedItem
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildPriceRow(
                                'Prix unitaire',
                                '${_currentProduct.numericPrice.toStringAsFixed(0)} FCFA',
                              ),
                              _buildPriceRow('Quantité', 'x$_quantity'),
                              _buildPriceRow(
                                'Sous-total',
                                '${(_currentProduct.numericPrice * _quantity).toStringAsFixed(0)} FCFA',
                              ),
                              if (_includeInstallation &&
                                  _currentProduct.hasInstallationOption)
                                _buildPriceRow(
                                  'Installation',
                                  '${_currentProduct.installationFee.toStringAsFixed(0)} FCFA',
                                ),
                              _buildPriceRow(
                                'Livraison',
                                _currentProduct.deliveryFee > 0
                                    ? '${_currentProduct.deliveryFee.toStringAsFixed(0)} FCFA'
                                    : 'GRATUITE',
                              ),
                              const Divider(color: Colors.white24, height: 24),
                              _buildPriceRow(
                                'Total',
                                '${((_currentProduct.numericPrice * _quantity) + (_includeInstallation && _currentProduct.hasInstallationOption ? _currentProduct.installationFee : 0) + _currentProduct.deliveryFee).toStringAsFixed(0)} FCFA',
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        children: [
                          // Commander Button (toggle options)
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showOrderOptions = !_showOrderOptions;
                                  });
                                },
                                icon: Icon(
                                  _showOrderOptions
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  size: 24,
                                ),
                                label: Text(
                                  _showOrderOptions ? 'Masquer' : 'Commander',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  elevation: 4,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Add to Cart Button (icon only)
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _handleAddToCart,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: const CircleBorder(),
                                padding: EdgeInsets.zero,
                                elevation: 4,
                              ),
                              child: const Icon(Icons.add, size: 28),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Social Buttons (Right side - TikTok style) - Moved to end to be on top
          Positioned(
            right: 12,
            bottom: 120,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSocialButtonIcon(
                  icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : null,
                  onTap: _handleDoubleTap,
                ),
                const SizedBox(height: 20),
                _buildSocialButtonIcon(
                  icon: Icons.comment_outlined,
                  onTap: _showComments,
                ),
                const SizedBox(height: 20),
                _buildSocialButtonIcon(
                  icon: Icons.share_outlined,
                  onTap: _handleShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButtonIcon({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color ?? Colors.white, size: 24),
      ),
    );
  }

  Widget _buildPriceRow(String label, String price, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.grey[300],
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              color: Colors.white,
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
