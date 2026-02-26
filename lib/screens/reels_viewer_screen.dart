import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/services/global_video_cache.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_ecommerce/utils/constants.dart';
import 'package:app_ecommerce/services/cart_service.dart';
import 'package:app_ecommerce/screens/validation_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool _isDescriptionExpanded = false;
  bool _isVideoInitialized = false;

  bool _isUiVisible = true;
  double _currentMediaProgress = 0.0;
  double _visiblePercentage = 0.0;
  AnimationController? _imageProgressController;

  int get _numVideos => widget.product.videoUrls.length;
  bool get _isCurrentMediaVideo => _currentIndex < _numVideos;

  @override
  void initState() {
    super.initState();
    _totalItems = _numVideos + widget.product.images.length;

    _imageProgressController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..addListener(() {
            setState(() {
              _currentMediaProgress = _imageProgressController!.value;
            });
          })
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
      setState(() {
        _currentMediaProgress =
            value.position.inMilliseconds / value.duration.inMilliseconds;
      });
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
    _currentMediaProgress = 0.0;
    _imageProgressController?.stop();
    _imageProgressController?.reset();

    if (_totalItems == 0) return;

    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      _controller!.pause();
      _controller!.seekTo(Duration.zero);
    }

    if (_isCurrentMediaVideo) {
      _initializeVideo(widget.product.videoUrls[_currentIndex]);
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
    return VisibilityDetector(
      key: Key('reel_${widget.product.id}'),
      onVisibilityChanged: (visibilityInfo) {
        _visiblePercentage = visibilityInfo.visibleFraction * 100;
        _applyVisibilityState();
      },
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
            Positioned.fill(child: _buildMediaContent()),
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
                                Icons.arrow_back,
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
                                  if (widget.product.description.length > 80)
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
      if (imageIndex >= 0 && imageIndex < widget.product.images.length) {
        return Image.network(
          widget.product.images[imageIndex],
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

  Widget _buildProgressBar(int index) {
    double fillPercentage = 0.0;
    if (index < _currentIndex) {
      fillPercentage = 1.0;
    } else if (index == _currentIndex) {
      fillPercentage = _currentMediaProgress.clamp(0.0, 1.0);
    } else {
      fillPercentage = 0.0;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              height: 2,
              width: constraints.maxWidth * fillPercentage,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );
      },
    );
  }
}
