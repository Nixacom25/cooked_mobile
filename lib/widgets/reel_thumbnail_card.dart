import 'package:flutter/material.dart';
import 'package:app_ecommerce/models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:app_ecommerce/services/global_video_cache.dart';

class ReelThumbnailCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const ReelThumbnailCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  State<ReelThumbnailCard> createState() => _ReelThumbnailCardState();
}

class _ReelThumbnailCardState extends State<ReelThumbnailCard> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.product.thumbnailUrl == null &&
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
      debugPrint('Error loading reel preview: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasThumbnail =
        widget.product.thumbnailUrl != null &&
        widget.product.thumbnailUrl!.isNotEmpty;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[900],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image OR Video Preview
            hasThumbnail
                ? CachedNetworkImage(
                    imageUrl: widget.product.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image, color: Colors.white24),
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
                      : const Icon(
                          Icons.image_not_supported,
                          color: Colors.white24,
                        )),

            // Subtle dark gradient at the bottom for readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 40,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
            ),

            // Play icon and view count at bottom left
            Positioned(
              bottom: 6,
              left: 6,
              child: Row(
                children: [
                  const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 2),
                  const Text(
                    "49.9k",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
