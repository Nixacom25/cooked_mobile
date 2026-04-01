import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/services/global_video_cache.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_ecommerce/services/cart_service.dart';
import 'package:app_ecommerce/models/cart_item.dart';
import 'package:app_ecommerce/screens/cart_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_ecommerce/widgets/comments_modal.dart';
import 'package:app_ecommerce/services/product_service.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReelsViewerScreen extends StatefulWidget {
  final List<Product> products;
  final int initialIndex;

  const ReelsViewerScreen({
    super.key,
    required this.products,
    required this.initialIndex,
  });

  @override
  State<ReelsViewerScreen> createState() => _ReelsViewerScreenState();
}

class _ReelsViewerScreenState extends State<ReelsViewerScreen> {
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
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          return ReelsPlayerItem(product: widget.products[index]);
        },
      ),
    );
  }
}

class ReelsPlayerItem extends StatefulWidget {
  final Product product;

  const ReelsPlayerItem({super.key, required this.product});

  @override
  State<ReelsPlayerItem> createState() => _ReelsPlayerItemState();
}

class _ReelsPlayerItemState extends State<ReelsPlayerItem>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  int _currentIndex = 0;
  late int _totalItems;

  Timer? _periodicTimer;

  bool _wasLooping = true;
  bool _isMuted = false;
  bool _isVideoInitialized = false;

  bool _isUiVisible = true;
  double _visiblePercentage = 0.0;
  AnimationController? _imageProgressController;
  bool _isDescriptionExpanded = false;

  late Product _product;

  int get _numVideos => _product.videoUrls.length;
  bool get _isCurrentMediaVideo => _currentIndex < _numVideos;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _totalItems = _numVideos + _product.images.length;

    _imageProgressController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              if (_currentIndex < _totalItems - 1) {
                _nextMedia();
              }
            }
          });

    _initializeCurrentMedia();
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;

    final value = _controller!.value;
    if (value.duration.inMilliseconds > 0) {
      // Intentionally left blank to match original structure without setState
    }

    if (value.position >= value.duration && value.duration.inMilliseconds > 0) {
      if (_currentIndex < _totalItems - 1) {
        _controller!.removeListener(_videoListener);
        _nextMedia();
      }
    }
  }

  void _initializeCurrentMedia() {
    _periodicTimer?.cancel();
    _imageProgressController?.stop();
    _imageProgressController?.reset();

    if (_totalItems == 0) return;

    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      _controller!.pause();
      _controller!.seekTo(Duration.zero);
    }

    if (_isCurrentMediaVideo) {
      _initializeVideo(_product.videoUrls[_currentIndex]);
    } else {
      _imageProgressController?.forward();
    }
  }

  Future<void> _initializeVideo(String videoUrl) async {
    try {
      _controller = await GlobalVideoCache.getController(videoUrl);

      if (mounted && _controller != null) {
        _wasLooping = _controller!.value.isLooping;

        await _controller!.setLooping(false);
        await _controller!.seekTo(Duration.zero);

        _controller!.addListener(_videoListener);

        setState(() {
          _isVideoInitialized = true;
        });

        _applyVisibilityState();
      }
    } catch (e) {
      debugPrint("Error initializing reel video: $e");
      if (mounted && _currentIndex < _totalItems - 1) _nextMedia();
    }
  }

  void _applyVisibilityState() {
    if (!mounted) return;
    if (_visiblePercentage > 50) {
      if (_isCurrentMediaVideo && _controller != null) {
        if (_isUiVisible && _isMuted) {
          setState(() {
            _isMuted = false;
          });
        }
        _controller?.setVolume(_isMuted ? 0 : 1);
        if (!_controller!.value.isPlaying) {
          if (_controller!.value.position >= _controller!.value.duration &&
              _controller!.value.duration.inMilliseconds > 0) {
            _controller?.seekTo(Duration.zero);
          }
          _controller?.play();
        }
      } else if (!_isCurrentMediaVideo) {
        _imageProgressController?.forward();
      }
    } else {
      if (_isCurrentMediaVideo && _controller != null) {
        _controller?.pause();
        _controller?.setVolume(0);
      } else if (!_isCurrentMediaVideo) {
        _imageProgressController?.stop();
      }
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
    } else {
      if (_isCurrentMediaVideo) {
        _controller?.seekTo(Duration.zero);
        _controller?.play();
      } else {
        _imageProgressController?.reset();
        _imageProgressController?.forward();
      }
    }
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _imageProgressController?.dispose();
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
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
        "*${_product.title}*\n"
        "Prix: ${_product.price}\n\n"
        "Lien produit: ${_product.thumbnailUrl ?? _product.videoUrl}";

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
    return VisibilityDetector(
      key: Key('reel_${_product.id}'),
      onVisibilityChanged: (visibilityInfo) {
        _visiblePercentage = visibilityInfo.visibleFraction * 100;
        _applyVisibilityState();
      },
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
            child: IgnorePointer(child: _buildMediaContent()),
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
                            bottomLabel: _product.commentCount.toString(),
                            onTap: () => CommentsModal.show(
                              context,
                              productId: _product.id,
                              productTitle: _product.title,
                            ),
                          ),
                          ValueListenableBuilder<List<CartItem>>(
                            valueListenable: CartService().itemsNotifier,
                            builder: (context, items, _) {
                              final isInCart = items.any(
                                (item) => item.product.id == _product.id,
                              );
                              final count = items.length;
                              return _buildRightAction(
                                icon: isInCart ? Icons.close : Icons.add,
                                label: count > 0 ? 'PANIER ($count)' : 'PANIER',
                                color: isInCart ? Colors.red : null,
                                onTap: () {
                                  if (isInCart) {
                                    CartService().removeItemCompletely(
                                      _product,
                                    );
                                  } else {
                                    CartService().addToCart(_product);
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
                            bottomLabel: _product.stock.toString(),
                          ),
                          _buildRightAction(
                            icon: Icons.shortcut,
                            label: _product.shareCount.toString(),
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
                                _product.price,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (_product.originalPrice != null) ...[
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2.0),
                                  child: Text(
                                    _product.originalPrice!,
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
                          if (_product.description.trim().isNotEmpty) ...[
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final span = TextSpan(
                                  text: _product.description,
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

  Widget _buildMediaContent() {
    if (_isCurrentMediaVideo) {
      if (_isVideoInitialized && _controller != null) {
        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }
    } else {
      final imageIndex = _currentIndex - _numVideos;
      if (imageIndex >= 0 && imageIndex < _product.images.length) {
        return Image.network(
          _product.images[imageIndex],
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          },
        );
      }
      return const SizedBox();
    }
  }

  Future<void> _buyNow() async {
    _controller?.pause();

    // Directly add to cart and go to validation
    CartService().addToCart(_product, quantity: 1);

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
