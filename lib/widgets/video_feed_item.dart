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

class VideoFeedItem extends StatefulWidget {
  final Product product;
  final bool isFocused;

  const VideoFeedItem({
    super.key,
    required this.product,
    required this.isFocused,
  });

  @override
  State<VideoFeedItem> createState() => _VideoFeedItemState();
}

class _VideoFeedItemState extends State<VideoFeedItem> {
  // Product state
  int _quantity = 1;
  bool _includeInstallation = false;
  bool _showOrderOptions = false; // Show quantity/service selectors
  bool _isDescriptionExpanded = false; // Expand description

  // Media navigation
  int _currentIndex = 0;
  late int _totalItems;

  int get _numVideos => widget.product.videoUrls.length;
  bool get _isCurrentMediaVideo => _currentIndex < _numVideos;
  // Video controller
  VideoPlayerController? _controller;
  bool _isMuted = true; // Default muted like TikTok
  bool _showControls = false; // Show pause/play overlay
  bool _isLiked = false; // Like state
  bool _showHeart = false; // Show heart animation
  Timer? _tapTimer; // Timer for single/double tap distinction

  @override
  void initState() {
    super.initState();
    _totalItems = _numVideos + widget.product.images.length;
    _initializeCurrentMedia();
  }

  @override
  void didUpdateWidget(VideoFeedItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isFocused && !oldWidget.isFocused) {
      if (_isCurrentMediaVideo) {
        _controller?.setVolume(_isMuted ? 0.0 : 1.0);
        GlobalVideoCache.play(
          widget.product.videoUrls[_currentIndex],
          ownerId: toString(),
        );
      }
    } else if (!widget.isFocused && oldWidget.isFocused) {
      if (_isCurrentMediaVideo) {
        GlobalVideoCache.pause(
          widget.product.videoUrls[_currentIndex],
          ownerId: toString(),
        );
        _controller?.seekTo(Duration.zero);
      }
    }
  }

  void _initializeCurrentMedia() {
    // Pause and reset previous video
    if (_controller != null) {
      _controller!.pause();
      _controller!.seekTo(Duration.zero);
    }

    if (_isCurrentMediaVideo) {
      _loadVideo(widget.product.videoUrls[_currentIndex]);
    } else {
      setState(() {
        _controller = null;
      });
    }
  }

  Future<void> _loadVideo(String videoUrl) async {
    try {
      final controller = await GlobalVideoCache.getController(videoUrl);
      if (mounted) {
        setState(() {
          _controller = controller;
        });

        // Play video if focused AFTER loading
        if (widget.isFocused) {
          _controller!.setVolume(_isMuted ? 0.0 : 1.0);
          GlobalVideoCache.play(videoUrl, ownerId: toString());
        }
      }
    } catch (e) {
      print('Error loading video: $e');
    }
  }

  void _toggleMute() {
    if (_controller != null) {
      setState(() {
        _isMuted = !_isMuted;
        _controller!.setVolume(_isMuted ? 0.0 : 1.0);
      });
    }
  }

  void _togglePlayPause() {
    if (_controller != null) {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
      setState(() {});
    }
  }

  void _handleTap(TapUpDetails details) {
    if (_tapTimer != null && _tapTimer!.isActive) {
      // Double tap detected
      _tapTimer!.cancel();
      _handleDoubleTap();
    } else {
      // Start timer for single tap
      _tapTimer = Timer(const Duration(milliseconds: 300), () {
        // Single tap action: check for horizontal navigation
        final screenWidth = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < screenWidth / 3) {
          _previousMedia();
        } else if (details.globalPosition.dx > screenWidth * 2 / 3) {
          _nextMedia();
        } else {
          // Center tap: toggle play/pause
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
        }
      });
    }
  }

  void _nextMedia() {
    if (!mounted) return;
    if (_currentIndex < _totalItems - 1) {
      setState(() {
        _currentIndex++;
      });
      _initializeCurrentMedia();
    }
  }

  void _previousMedia() {
    if (!mounted) return;
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _initializeCurrentMedia();
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

  Product get _currentProduct => widget.product;

  void _handleAddToCart() {
    CartService().addProduct(
      _currentProduct,
      quantity: _quantity,
      includeInstallation: _includeInstallation,
    );

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
    // Pause with reference counting (safe now)
    if (_isCurrentMediaVideo) {
      GlobalVideoCache.pause(
        widget.product.videoUrls[_currentIndex],
        ownerId: toString(),
      );
    }
    // Don't dispose controllers - they're managed by GlobalVideoCache
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Display with tap controls
          GestureDetector(
            onTapUp: _handleTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video Background
                if (_isCurrentMediaVideo)
                  (_controller != null && _controller!.value.isInitialized
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller!.value.size.width,
                            height: _controller!.value.size.height,
                            child: VideoPlayer(_controller!),
                          ),
                        )
                      : Container(
                          color: Colors.grey[900],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ))
                else
                  Image.network(
                    widget.product.images[_currentIndex - _numVideos],
                    fit: BoxFit.cover,
                  ),

                // Play/Pause icon overlay (center)
                if (_showControls && _controller != null)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _controller!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),

                // Heart animation for double-tap like
                if (_showHeart)
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

          // Top Header - EXACTLY like ProductPopup (but without close button to avoid overflow)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
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

          // Product Info Overlay (Bottom) - EXACTLY like ProductPopup
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
                        const SizedBox(height: 16),

                        // Service Option Selector
                        if (_currentProduct.hasInstallationOption)
                          ServiceOptionSelector(
                            includeInstallation: _includeInstallation,
                            onChanged: (value) {
                              setState(() {
                                _includeInstallation = value;
                              });
                            },
                          ),

                        const SizedBox(height: 16),

                        // Price Breakdown
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
                        const SizedBox(height: 16),
                      ],

                      // Action Buttons Row
                      Row(
                        children: [
                          // Commander Button
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
            bottom: 100,
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

          // Progress Bars (like preview)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            right: 10,
            child: Row(
              children: List.generate(_totalItems, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: index <= _currentIndex
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                );
              }),
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
