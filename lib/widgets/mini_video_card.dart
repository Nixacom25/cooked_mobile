import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/services/global_video_cache.dart';
import 'package:app_ecommerce/services/cart_service.dart';
import 'package:app_ecommerce/utils/constants.dart';
import 'package:app_ecommerce/widgets/product_popup.dart';

/// Mini video card with ZERO reloading
/// Uses GlobalVideoCache for permanent controller storage
/// Same controller shared with fullscreen view
class MiniVideoCard extends StatefulWidget {
  final Product product;
  final int index;
  final String category;
  final List<Product> allProducts;
  final VoidCallback? onTap;

  const MiniVideoCard({
    super.key,
    required this.product,
    required this.index,
    required this.category,
    required this.allProducts,
    this.onTap,
  });

  @override
  State<MiniVideoCard> createState() => _MiniVideoCardState();
}

class _MiniVideoCardState extends State<MiniVideoCard> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Check if already cached
    if (GlobalVideoCache.hasController(widget.product.videoUrl)) {
      _loadFromCache();
    }
  }

  /// Load controller from global cache (instant if already cached)
  Future<void> _loadFromCache() async {
    if (_initialized || _isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Get from GLOBAL permanent cache
      final controller = await GlobalVideoCache.getController(
        widget.product.videoUrl,
      );

      if (mounted) {
        setState(() {
          _controller = controller;
          _initialized = true;
          _isLoading = false;
        });
      }
    } on TimeoutException catch (e) {
      print('⏱️ Timeout loading video: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      print('❌ Error loading controller: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  /// Handle visibility changes
  void _handleVisibilityChange(VisibilityInfo info) {
    if (widget.product.videoUrl.isEmpty) return;

    final visiblePercentage = info.visibleFraction * 100;

    if (visiblePercentage > 70) {
      // >50% visible - load and play
      if (!_initialized && !_isLoading && !_hasError) {
        _loadFromCache();
      } else if (_initialized) {
        // Play this video with owner ID and STRICTLY MUTED
        _controller?.setVolume(0.0);
        GlobalVideoCache.play(widget.product.videoUrl, ownerId: toString());
      }
    } else if (visiblePercentage < 10) {
      // <10% visible - pause (but DON'T dispose)
      if (_initialized) {
        // <10% visible - pause (safe now with ref counting)
        GlobalVideoCache.pause(widget.product.videoUrl, ownerId: toString());
      }
    }
  }

  @override
  void dispose() {
    // DON'T dispose controller - it's global and permanent
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('${widget.category}_${widget.index}'),
      onVisibilityChanged: _handleVisibilityChange,
      child: GestureDetector(
        onTap: () {
          // Open ProductPopup with fullscreen video
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductPopup(
                product: widget.product,
                initialIndex: widget.index,
                allProducts: widget.allProducts,
              ),
              fullscreenDialog: true,
            ),
          );
        },
        child: Container(
          width: 180,
          height: 240,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight, // Dark placeholder
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // 1. Background Thumbnail (Always show if available as base layer)
                if (widget.product.thumbnailUrl != null)
                  Positioned.fill(
                    child: Image.network(
                      widget.product.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: AppColors.primaryLight),
                    ),
                  ),

                // 2. Video Player (Layered on top of thumbnail)
                if (_initialized && _controller != null)
                  Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.size.width,
                        height: _controller!.value.size.height,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  )
                // 3. Loading Spinner (Overlay on top of thumbnail while loading)
                else if (!(_hasError || widget.product.videoUrl.isEmpty) &&
                    _isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white54,
                      strokeWidth: 2,
                    ),
                  ),

                // 4. Error state placeholder (if no thumbnail and video failed)
                if (_hasError && widget.product.thumbnailUrl == null)
                  const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.white24,
                    ),
                  ),

                // Promo Tag (Top Left)
                if (widget.product.promoLabel != null &&
                    widget.product.promoLabel!.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.product.promoLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Product info overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.product.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12, // Slightly smaller
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.product.price,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            CartService().addProduct(
                              widget.product,
                            ); // Add to cart
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${widget.product.title} ajouté au panier',
                                ),
                                duration: const Duration(seconds: 1),
                                backgroundColor: AppColors.accent,
                              ),
                            );
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.accent, // Orange
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
