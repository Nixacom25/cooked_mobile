import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/services/global_video_cache.dart';
import 'dart:async';
import 'package:app_ecommerce/utils/constants.dart';
import 'package:app_ecommerce/services/cart_service.dart';
import 'package:app_ecommerce/models/cart_item.dart';
import 'package:app_ecommerce/screens/cart_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_ecommerce/widgets/comments_modal.dart';
import 'package:app_ecommerce/services/product_service.dart';

class VideoPreviewScreen extends StatefulWidget {
  final List<Product> products;
  final int initialIndex;

  const VideoPreviewScreen({
    super.key,
    required this.products,
    required this.initialIndex,
  });

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          return VideoPreviewItem(product: widget.products[index]);
        },
      ),
    );
  }
}

class VideoPreviewItem extends StatefulWidget {
  final Product product;

  const VideoPreviewItem({super.key, required this.product});

  @override
  State<VideoPreviewItem> createState() => _VideoPreviewItemState();
}

class _VideoPreviewItemState extends State<VideoPreviewItem>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isVideoInitialized = false;
  bool _isMuted = false;
  bool _isUiVisible = true;
  bool _isDescriptionExpanded = false;

  // Media Management
  int _currentIndex = 0;
  late int _totalItems;

  Timer? _periodicTimer;

  int get _numVideos => widget.product.videoUrls.length;
  bool get _isCurrentMediaVideo => _currentIndex < _numVideos;

  bool _wasLooping = true; // Default to true as Feed usually loops

  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _totalItems = _numVideos + _product.images.length;
    _initializeCurrentMedia();
  }

  void _initializeCurrentMedia() {
    _periodicTimer?.cancel();

    if (_totalItems == 0) {
      Navigator.pop(context);
      return;
    }

    // Pause and reset previous video if it exists
    if (_controller != null) {
      _controller!.pause();
      _controller!.seekTo(Duration.zero);
    }

    if (_isCurrentMediaVideo) {
      _initializeVideo(_product.videoUrls[_currentIndex]);
    }
  }

  Future<void> _initializeVideo(String videoUrl) async {
    try {
      _controller = await GlobalVideoCache.getController(videoUrl);

      if (mounted && _controller != null) {
        _wasLooping = _controller!.value.isLooping;

        await _controller!.setLooping(false);
        await _controller!.setVolume(_isMuted ? 0 : 1);
        await _controller!.seekTo(Duration.zero);
        await _controller!.play();

        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error initializing preview video: $e");
      if (mounted) _nextMedia();
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

  @override
  void dispose() {
    _periodicTimer?.cancel();
    if (_controller != null) {
      _controller!.setLooping(_wasLooping);
      _controller!.pause();
    }
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller?.setVolume(_isMuted ? 0 : 1);
    });
  }

  Future<void> _orderViaWhatsApp() async {
    const phoneNumber = '+221785304869';
    final message =
        "Bonjour, je souhaite commander :\n\n"
        "*${widget.product.title}*\n"
        "Prix: ${widget.product.price}\n\n"
        "Lien produit: ${widget.product.thumbnailUrl ?? widget.product.videoUrl}";

    final whatsappUrl = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp')),
        );
      }
    }
  }

  void _shareProduct() async {
    final result = await Share.share(
      "Découvrez ${_product.title} à ${_product.price} sur l'app Bawane ! \n"
      "${_product.thumbnailUrl ?? _product.videoUrl}",
    );

    if (result.status == ShareResultStatus.success) {
      ProductService.incrementShareCount(_product.id);
      if (mounted) {
        setState(() {
          _product = _product.copyWith(shareCount: _product.shareCount + 1);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Background Tap Detector
          Positioned.fill(
            child: GestureDetector(
              onTapUp: (details) {
                final screenWidth = MediaQuery.of(context).size.width;
                final tapX = details.localPosition.dx;
                if (tapX < screenWidth * 0.25) {
                  _previousMedia();
                } else if (tapX > screenWidth * 0.75) {
                  _nextMedia();
                } else {
                  setState(() {
                    _isUiVisible = !_isUiVisible;
                  });
                }
              },
              behavior: HitTestBehavior.opaque,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Center(
                child: _isCurrentMediaVideo
                    ? (_isVideoInitialized && _controller != null
                          ? FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _controller!.value.size.width,
                                height: _controller!.value.size.height,
                                child: VideoPlayer(_controller!),
                              ),
                            )
                          : const CircularProgressIndicator(
                              color: AppColors.accent,
                            ))
                    : Image.network(
                        widget.product.images[_currentIndex - _numVideos],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, color: Colors.white),
                      ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_isUiVisible,
              child: AnimatedOpacity(
                opacity: _isUiVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Stack(
                  children: [
                    // Gradient overlay removed to keep image clear
                    Positioned(
                      top: 30,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_currentIndex + 1} / $_totalItems',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              if (_isCurrentMediaVideo)
                                GestureDetector(
                                  onTap: _toggleMute,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isMuted
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 16,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildRightAction(
                            icon: Icons.chat_bubble_outline,
                            label: '',
                            bottomLabel: widget.product.commentCount.toString(),
                            onTap: () => CommentsModal.show(
                              context,
                              productId: widget.product.id,
                              productTitle: widget.product.title,
                            ),
                          ),
                          ValueListenableBuilder<List<CartItem>>(
                            valueListenable: CartService().itemsNotifier,
                            builder: (context, items, _) {
                              final isInCart = items.any(
                                (item) => item.product.id == widget.product.id,
                              );
                              final count = items.length;
                              return _buildRightAction(
                                icon: isInCart ? Icons.close : Icons.add,
                                label: count > 0 ? 'PANIER ($count)' : 'PANIER',
                                color: isInCart ? Colors.red : null,
                                onTap: () {
                                  if (isInCart) {
                                    CartService().removeItemCompletely(
                                      widget.product,
                                    );
                                  } else {
                                    CartService().addToCart(widget.product);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Ajouté au panier !'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                          _buildRightAction(
                            icon: FontAwesomeIcons.whatsapp,
                            label: "J'ACHÈTE",
                            color: const Color(0xFF25D366),
                            onTap: _orderViaWhatsApp,
                          ),
                          _buildRightAction(
                            icon: Icons.storefront,
                            label: 'BOUTIQUE',
                          ),
                          _buildRightAction(
                            icon: Icons.inventory_2_outlined,
                            label: '',
                            bottomLabel: widget.product.stock.toString(),
                          ),
                          _buildRightAction(
                            icon: Icons.shortcut,
                            label: widget.product.shareCount.toString(),
                            onTap: _shareProduct,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 65,
                      bottom: 15,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // J'ACHÈTE Button (Main)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _buyNow,
                              icon: const Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "J'ACHÈTE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6F00),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Info Column (Price and Description)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.product.price,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (widget.product.originalPrice != null) ...[
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2.0),
                                  child: Text(
                                    widget.product.originalPrice!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (widget.product.description.trim().isNotEmpty) ...[
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final span = TextSpan(
                                  text: widget.product.description,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                                final tp = TextPainter(
                                  text: span,
                                  maxLines: 1,
                                  textDirection: TextDirection.ltr,
                                );
                                tp.layout(maxWidth: constraints.maxWidth);
                                final hasMore = tp.didExceedMaxLines;

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text.rich(
                                        span,
                                        maxLines: _isDescriptionExpanded
                                            ? null
                                            : 1,
                                        overflow: _isDescriptionExpanded
                                            ? TextOverflow.visible
                                            : TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (hasMore)
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isDescriptionExpanded =
                                                !_isDescriptionExpanded;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 5.0,
                                            bottom: 0,
                                          ),
                                          child: Icon(
                                            _isDescriptionExpanded
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _buyNow() async {
    _controller?.pause();

    // Directly add to cart and go to validation
    CartService().addToCart(widget.product, quantity: 1);

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/cart'),
        builder: (context) => const CartScreen(),
      ),
    );

    if (mounted) {
      _controller?.play();
    }
  }

  Widget _buildRightAction({
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onTap,
    String? topLabel,
    String? bottomLabel,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (topLabel != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                topLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color ?? Colors.black.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: icon == FontAwesomeIcons.whatsapp
                  ? FaIcon(icon, color: Colors.white, size: 25)
                  : Icon(icon, color: Colors.white, size: 25),
            ),
          ),
          if (bottomLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                bottomLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
