import re

with open('lib/screens/video_preview_screen.dart', 'r') as f:
    content = f.read()

start_idx = content.find('  Widget _buildActionItem({')
if start_idx == -1:
    print("Could not find _buildActionItem")
    exit(1)

new_methods = """  Widget _buildActionItem({
    String? topText,
    required IconData icon,
    Color iconColor = Colors.white,
    Color circleColor = Colors.white24,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (topText != null) ...[
            Text(
              topText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))],
              ),
            ),
            const SizedBox(height: 4),
          ],
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
            child: Center(child: Icon(icon, color: iconColor, size: 20)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))],
            ),
          ),
        ],
      ),
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
            if (_isCurrentMediaVideo && _controller != null) {
              setState(() {
                if (_controller!.value.isPlaying) {
                  _controller!.pause();
                } else {
                  _controller!.play();
                }
              });
            }
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black, // Background completely black
                child: _buildMediaContent(),
              ),
            ),
            
            if (_isCurrentMediaVideo && _controller != null && !_controller!.value.isPlaying && _isVideoInitialized)
               Center(
                 child: Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: Colors.black.withOpacity(0.5),
                     shape: BoxShape.circle,
                   ),
                   child: const Icon(Icons.play_arrow, color: Colors.white, size: 60),
                 ),
               ),

            Positioned.fill(
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 400,
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
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 20,
                    left: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_currentIndex + 1} / $_totalItems',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionItem(
                          topText: '30',
                          icon: Icons.chat_outlined,
                          label: 'COMMENTAIRES',
                          onTap: () {},
                        ),
                        const SizedBox(height: 16),
                        _buildActionItem(
                          icon: Icons.add,
                          label: 'PANIER',
                          onTap: () => _showQuantityPopup(context),
                        ),
                        const SizedBox(height: 16),
                        _buildActionItem(
                          icon: FontAwesomeIcons.whatsapp,
                          iconColor: Colors.white,
                          circleColor: const Color(0xFF25D366),
                          label: "J'ACHÈTE",
                          onTap: _orderViaWhatsApp,
                        ),
                        const SizedBox(height: 16),
                        _buildActionItem(
                          icon: Icons.storefront,
                          label: "BOUTIQUE",
                          onTap: () {},
                        ),
                        const SizedBox(height: 16),
                        _buildActionItem(
                          icon: FontAwesomeIcons.share,
                          label: "PARTAGER",
                          onTap: _shareProduct,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 80, // Leaves room for the right column icons
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showQuantityPopup(context),
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            "J'ACHÈTE",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6600),
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.product.price,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (widget.product.originalPrice != null)
                              Text(
                                widget.product.originalPrice!,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  decoration: TextDecoration.lineThrough,
                                  shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Description : ${widget.product.description}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          maxLines: _isDescriptionExpanded ? null : 1,
                          overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isDescriptionExpanded = !_isDescriptionExpanded;
                            });
                          },
                          child: Icon(
                            _isDescriptionExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.red,
                            size: 28,
                          ),
                        ),
                      ],
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

  Widget _buildMediaContent() {
    if (_isCurrentMediaVideo) {
      if (_isVideoInitialized && _controller != null) {
        return Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
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
      return Center(
        child: Image.network(
          widget.product.images[imageIndex],
          fit: BoxFit.contain, // Guarantees the image fits completely within the screen with black bars
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          },
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.broken_image,
            color: Colors.white,
          ),
        ),
      );
    }
  }
}
"""

with open('lib/screens/video_preview_screen.dart', 'w') as f:
    f.write(content[:start_idx] + new_methods)

print("Done")
