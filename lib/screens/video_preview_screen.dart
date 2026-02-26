import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/services/global_video_cache.dart';
import 'package:app_ecommerce/utils/constants.dart';
import 'dart:async';
import 'package:app_ecommerce/services/cart_service.dart';
import 'package:app_ecommerce/screens/validation_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _isDescriptionExpanded = false;
  bool _isUiVisible = true;

  // Media Management
  int _currentIndex = 0;
  late int _totalItems;

  Timer? _periodicTimer;
  Timer? _progressTimer;
  double _progress = 0.0;

  int get _numVideos => widget.product.videoUrls.length;
  bool get _isCurrentMediaVideo => _currentIndex < _numVideos;

  bool _wasLooping = true; // Default to true as Feed usually loops

  @override
  void initState() {
    super.initState();

    _totalItems = _numVideos + widget.product.images.length;
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
      _initializeVideo(widget.product.videoUrls[_currentIndex]);
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

          _controller!.addListener(() {
            if (mounted && _controller!.value.isPlaying) {
              setState(() {
                _progress =
                    _controller!.value.position.inMilliseconds /
                    (_controller!.value.duration.inMilliseconds == 0
                        ? 1
                        : _controller!.value.duration.inMilliseconds);
              });
            }
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

    setState(() {
      _progress = 0.0;
    });

    if (_currentIndex < _totalItems - 1) {
      setState(() {
        _currentIndex++;
      });
      _initializeCurrentMedia();
    }
  }

  void _previousMedia() {
    if (!mounted) return;

    setState(() {
      _progress = 0.0;
    });

    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _initializeCurrentMedia();
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
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

  void _shareProduct() {
    Share.share(
      "Découvrez ${widget.product.title} à ${widget.product.price} sur l'app Bawane ! \n"
      "${widget.product.thumbnailUrl ?? widget.product.videoUrl}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
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
              if (_isUiVisible) {
                _isMuted = false;
                _controller?.setVolume(1);
              }
            });
          }
        },
        child: Stack(
          children: [
            Center(
              child: _isCurrentMediaVideo
                  ? (_isVideoInitialized && _controller != null
                        ? AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          )
                        : const CircularProgressIndicator(
                            color: AppColors.accent,
                          ))
                  : Image.network(
                      widget.product.images[_currentIndex - _numVideos],
                      fit: BoxFit.contain,
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
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_isUiVisible,
                child: AnimatedOpacity(
                  opacity: _isUiVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                                Colors.black.withOpacity(0.9),
                              ],
                              stops: const [0.0, 0.2, 0.6, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 10,
                        right: 10,
                        child: Row(
                          children: List.generate(_totalItems, (index) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2.0,
                                ),
                                child: _buildProgressBar(index),
                              ),
                            );
                          }),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 30,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            if (_isCurrentMediaVideo)
                              IconButton(
                                icon: Icon(
                                  _isMuted ? Icons.volume_off : Icons.volume_up,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: _toggleMute,
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 180,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _orderViaWhatsApp,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF25D366),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.whatsapp,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'CONTACT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: _shareProduct,
                              child: const Icon(
                                Icons.share_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'PARTAGER',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 30,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.product.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isDescriptionExpanded
                                        ? widget.product.description
                                        : (widget.product.description.length >
                                                  80
                                              ? '${widget.product.description.substring(0, 80)}...'
                                              : widget.product.description),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (widget.product.originalPrice != null &&
                                      widget.product.description.length > 80)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isDescriptionExpanded =
                                              !_isDescriptionExpanded;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          _isDescriptionExpanded
                                              ? "MOINS"
                                              : "... PLUS",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  widget.product.price,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                if (widget.product.originalPrice != null) ...[
                                  const SizedBox(width: 12),
                                  Text(
                                    widget.product.originalPrice!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      _controller?.pause();
                                      // Show Quantity Selector
                                      final result = await showDialog<int>(
                                        context: context,
                                        builder: (context) {
                                          int localQty = 1;
                                          return StatefulBuilder(
                                            builder: (context, setDialogState) {
                                              return AlertDialog(
                                                title: const Text('Quantité'),
                                                content: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.remove,
                                                      ),
                                                      onPressed: localQty > 1
                                                          ? () => setDialogState(
                                                              () => localQty--,
                                                            )
                                                          : null,
                                                    ),
                                                    Text(
                                                      '$localQty',
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.add,
                                                      ),
                                                      onPressed: () =>
                                                          setDialogState(
                                                            () => localQty++,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text(
                                                      'ANNULER',
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          localQty,
                                                        ),
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              AppColors.accent,
                                                        ),
                                                    child: const Text(
                                                      'CONFIRMER',
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      );

                                      if (result != null) {
                                        CartService().clearCart();
                                        CartService().addToCart(
                                          widget.product,
                                          quantity: result,
                                        );
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            settings: const RouteSettings(
                                              name: '/validation',
                                            ),
                                            builder: (context) =>
                                                const ValidationScreen(),
                                          ),
                                        );
                                      }

                                      if (mounted) {
                                        _controller?.play();
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.shopping_cart,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      "J'ACHÈTE",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      CartService().addToCart(widget.product);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Ajouté au panier !'),
                                          duration: Duration(milliseconds: 500),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.shopping_cart_outlined,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      "AU PANIER",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Colors.white54,
                                        width: 1,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: Colors.black.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }

  Widget _buildProgressBar(int index) {
    if (index < _currentIndex) {
      return Container(
        height: 2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    } else if (index == _currentIndex) {
      return Container(
        height: 2,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2),
        ),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: _progress.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: 2,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }
  }
}
