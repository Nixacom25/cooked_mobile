import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:app_ecommerce/models/product.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:video_player/video_player.dart';
import 'package:app_ecommerce/services/global_video_cache.dart';
import 'package:app_ecommerce/utils/url_sanitizer.dart';

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
  bool _isVisible = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize video preview if thumbnail is missing OR if it's explicitly a video product
    if ((widget.product.thumbnailUrl == null ||
            widget.product.thumbnailUrl!.isEmpty) &&
        widget.product.videoUrl.isNotEmpty) {
      _initVideoPreview();
    }
  }

  Future<void> _initVideoPreview() async {
    try {
      final controller = await GlobalVideoCache.getController(
        widget.product.videoUrl,
      );
      if (mounted) {
        setState(() {
          _videoController = controller;
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading video preview: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasVideo = widget.product.videoUrl.isNotEmpty;
    final hasThumbnail =
        (widget.product.thumbnailUrl != null &&
            widget.product.thumbnailUrl!.isNotEmpty) ||
        UrlSanitizer.isLocal(widget.product.thumbnailUrl);

    return VisibilityDetector(
      key: Key('dark_product_${widget.product.id}'),
      onVisibilityChanged: (info) {
        if (mounted) {
          final isCurrentlyVisible = info.visibleFraction > 0.1;
          if (_isVisible != isCurrentlyVisible) {
            setState(() {
              _isVisible = isCurrentlyVisible;
            });
          }
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: widget.width ?? 160,
          height: widget.height ?? 260,
          margin: widget.margin ?? const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                /// IMAGE OR VIDEO PREVIEW
                Positioned.fill(
                  child: hasThumbnail
                      ? UrlSanitizer.buildImage(
                          widget.product.thumbnailUrl,
                          fit: BoxFit.cover,
                        )
                      : (_isVideoInitialized && _videoController != null
                            ? FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _videoController!.value.size.width,
                                  height: _videoController!.value.size.height,
                                  child: VideoPlayer(_videoController!),
                                ),
                              )
                            : Container(
                                color: Colors.grey[900],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white24,
                                ),
                              )),
                ),

                /// CENTER ICON (Play or Eye)
                if (hasVideo || (!hasVideo && _isVisible))
                  Center(
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            hasVideo
                                ? Icons.play_arrow_rounded
                                : Icons.remove_red_eye,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),

                /// GRADIENT BAS
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                          Colors.black87,
                        ],
                        stops: [0.55, 0.8, 1],
                      ),
                    ),
                  ),
                ),

                /// TEXTE
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.black.withOpacity(0.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.product.price,
                          style: const TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
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
