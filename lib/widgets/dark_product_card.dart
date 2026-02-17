import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/services/global_video_cache.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DarkProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;

  const DarkProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.width,
    this.height,
    this.margin,
  });

  @override
  State<DarkProductCard> createState() => _DarkProductCardState();
}

class _DarkProductCardState extends State<DarkProductCard> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (GlobalVideoCache.hasController(widget.product.videoUrl)) {
      _loadFromCache();
    }
  }

  Future<void> _loadFromCache() async {
    if (_initialized || _isLoading) return;

    if (mounted)
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

    try {
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
    } catch (e) {
      if (mounted)
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
    }
  }

  void _handleVisibilityChange(VisibilityInfo info) {
    if (widget.product.videoUrl.isEmpty) return;

    final visiblePercentage = info.visibleFraction * 100;
    if (visiblePercentage > 70) {
      if (!_initialized && !_isLoading && !_hasError) {
        _loadFromCache();
      } else if (_initialized) {
        _controller?.setVolume(0.0);
        GlobalVideoCache.play(widget.product.videoUrl, ownerId: toString());
      }
    } else if (visiblePercentage < 10 && _initialized) {
      GlobalVideoCache.pause(widget.product.videoUrl, ownerId: toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('dark_${widget.product.id}'),
      onVisibilityChanged: _handleVisibilityChange,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: widget.width ?? 200,
          height: widget.height ?? 250,
          margin: widget.margin ?? const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Thumbnail Image (Visible when no video playing)
                if (!_initialized)
                  Positioned.fill(
                    child:
                        widget.product.thumbnailUrl != null &&
                            widget.product.thumbnailUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.product.thumbnailUrl!,
                            fit: BoxFit.cover,
                            memCacheWidth: 400, // Optimize memory
                            placeholder: (context, url) =>
                                Container(color: Colors.grey[900]),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[900],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.white24,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[900],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.white24,
                            ),
                          ),
                  ),

                // Video Player
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
                  ),

                // Gradient Overlay
                Positioned.fill(
                  child: Container(
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
                  ),
                ),

                // Red Dot
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red,
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),

                // Text Content
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product.price,
                        style: const TextStyle(
                          color: Color(0xFF4CAF50), // Green price
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
