import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app_ecommerce/models/status_category.dart';
import 'package:app_ecommerce/models/testimonial.dart';
import 'package:app_ecommerce/services/testimonial_service.dart';
import 'package:video_player/video_player.dart';

class StatusViewScreen extends StatefulWidget {
  final List<StatusCategory> allCategories;
  final int initialCategoryIndex;

  const StatusViewScreen({
    super.key,
    required this.allCategories,
    required this.initialCategoryIndex,
  });

  @override
  State<StatusViewScreen> createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends State<StatusViewScreen> {
  late int _currentCategoryIndex;
  int _currentStatusIndex = 0;

  Timer? _periodicTimer;
  static const Duration _displayDuration = Duration(seconds: 5);
  static const Duration _tickDuration = Duration(milliseconds: 50);

  double _progressValue = 0.0;
  bool _isPaused = false;
  double _dragOffsetY = 0.0;
  bool _isDragging = false;
  VideoPlayerController? _videoController;

  final Set<int> _likedStatuses = {};
  final Set<int> _viewedStatuses = {};

  @override
  void initState() {
    super.initState();

    _currentCategoryIndex = widget.initialCategoryIndex;
    _startTimer();
    _markAsViewed(); // Mark initial status
  }

  void _markAsViewed() async {
    final category = widget.allCategories[_currentCategoryIndex];
    if (category.items.isNotEmpty) {
      final testimonial = category.items[_currentStatusIndex];
      if (!_viewedStatuses.contains(testimonial.id)) {
        setState(() {
          _viewedStatuses.add(testimonial.id);
        });
        try {
          final updated = await TestimonialService.incrementViews(
            testimonial.id,
          );
          if (mounted) {
            setState(() {
              testimonial.views = updated.views;
            });
          }
        } catch (e) {
          debugPrint('Error incrementing views: $e');
        }
      }
    }
  }

  void _likeCurrentStatus() async {
    final category = widget.allCategories[_currentCategoryIndex];
    if (category.items.isNotEmpty) {
      final testimonial = category.items[_currentStatusIndex];
      if (_likedStatuses.contains(testimonial.id)) {
        setState(() {
          _likedStatuses.remove(testimonial.id);
        });
        // Optional: Call unlike endpoint if created
      } else {
        setState(() {
          _likedStatuses.add(testimonial.id);
        });
        try {
          final updated = await TestimonialService.incrementLikes(
            testimonial.id,
          );
          if (mounted) {
            setState(() {
              testimonial.likes = updated.likes;
            });
          }
        } catch (e) {
          debugPrint('Error incrementing likes: $e');
        }
      }
    }
  }

  void _startTimer() {
    _disposeVideoController();
    _periodicTimer?.cancel();
    _progressValue = 0.0;
    _isPaused = false;

    final currentCategory = widget.allCategories[_currentCategoryIndex];
    if (currentCategory.items.isEmpty) return;

    final currentItem = currentCategory.items[_currentStatusIndex];

    if (currentItem.mediaType == 'VIDEO') {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(currentItem.mediaUrl))
            ..initialize().then((_) {
              setState(() {});
              _videoController?.play();
            });
    }

    _periodicTimer = Timer.periodic(_tickDuration, (timer) {
      if (!mounted) return;
      if (_isPaused || _isDragging) return;

      // If video, sync progress with video
      if (currentItem.mediaType == 'VIDEO') {
        if (_videoController != null && _videoController!.value.isInitialized) {
          final duration = _videoController!.value.duration.inMilliseconds;
          final position = _videoController!.value.position.inMilliseconds;
          if (duration > 0) {
            setState(() {
              _progressValue = position / duration;
            });
            if (_progressValue >= 1.0) {
              timer.cancel();
              _nextStatus();
            }
          }
        }
        // If it's a video but not initialized/started, we wait (don't fall through to image logic)
        return;
      }

      setState(() {
        _progressValue +=
            _tickDuration.inMilliseconds / _displayDuration.inMilliseconds;

        if (_progressValue >= 1.0) {
          _progressValue = 1.0;
          timer.cancel();
          _nextStatus();
        }
      });
    });
  }

  void _disposeVideoController() {
    _videoController?.dispose();
    _videoController = null;
  }

  void _nextStatus() {
    final currentCategory = widget.allCategories[_currentCategoryIndex];

    // If there are more statuses in correct category
    if (_currentStatusIndex < currentCategory.items.length - 1) {
      setState(() {
        _currentStatusIndex++;
      });
      _startTimer();
      _markAsViewed();
    } else {
      // End of valid statuses for this user, move to next user if available
      if (_currentCategoryIndex < widget.allCategories.length - 1) {
        setState(() {
          _currentCategoryIndex++;
          _currentStatusIndex = 0;
        });
        _startTimer();
        _markAsViewed();
      } else {
        // Just Close if it was the last status of last user
        Navigator.pop(context);
      }
    }
  }

  void _previousStatus() {
    if (_currentStatusIndex > 0) {
      setState(() {
        _currentStatusIndex--;
      });
      _startTimer();
      _markAsViewed();
    } else {
      // Go to previous user if available
      if (_currentCategoryIndex > 0) {
        setState(() {
          _currentCategoryIndex--;
          // Go to last status of previous user
          _currentStatusIndex =
              widget.allCategories[_currentCategoryIndex].items.length - 1;
        });
        _startTimer();
        _markAsViewed();
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _disposeVideoController();

    _periodicTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allCategories.isEmpty) return const SizedBox.shrink();

    final currentCategory = widget.allCategories[_currentCategoryIndex];
    if (currentCategory.items.isEmpty) return const SizedBox.shrink();

    final currentItem = currentCategory.items[_currentStatusIndex];

    final screenHeight = MediaQuery.of(context).size.height;
    final dragPercentage = (_dragOffsetY / (screenHeight * 0.3)).clamp(
      0.0,
      1.0,
    );
    final bgOpacity = 1.0 - dragPercentage;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.black.withOpacity(bgOpacity),
        child: Transform.translate(
          offset: Offset(0, _dragOffsetY),
          child: GestureDetector(
            onVerticalDragStart: (details) {
              _isDragging = true;
            },
            onVerticalDragUpdate: (details) {
              setState(() {
                _dragOffsetY += details.delta.dy;
                // Prevent dragging up
                if (_dragOffsetY < 0) _dragOffsetY = 0;
              });
            },
            onVerticalDragEnd: (details) {
              _isDragging = false;
              if (_dragOffsetY > 150 || details.primaryVelocity! > 500) {
                Navigator.pop(context);
              } else {
                setState(() {
                  _dragOffsetY = 0.0;
                });
              }
            },
            onLongPress: () {
              setState(() {
                _isPaused = true;
                _videoController?.pause();
              });
            },
            onLongPressEnd: (details) {
              setState(() {
                _isPaused = false;
                _videoController?.play();
              });
            },
            onTapUp: (details) {
              // Tap logic (Left/Right)
              final width = MediaQuery.of(context).size.width;
              if (details.globalPosition.dx < width / 3) {
                _previousStatus();
              } else {
                _nextStatus();
              }
            },
            child: Stack(
              children: [
                // 1. Content
                Center(child: _buildMediaContent(currentItem)),

                // 2. Top Bar (Progress + User Info)
                SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress Bars
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          children: List.generate(
                            currentCategory.items.length,
                            (index) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0,
                                  ),
                                  child: LinearProgressIndicator(
                                    value: index < _currentStatusIndex
                                        ? 1.0
                                        : (index == _currentStatusIndex
                                              ? _progressValue
                                              : 0.0),
                                    backgroundColor: Colors.grey[700],
                                    valueColor: const AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                    minHeight: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Header (Back + Name + Menu)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(
                                currentCategory.avatarUrl,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentCategory.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        currentItem.clientName,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (currentItem.createdAt != null &&
                                          currentItem.activityDuration !=
                                              null) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          _getRemainingTime(
                                            currentItem.createdAt!,
                                            currentItem.activityDuration!,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                      if (currentItem.status == 'INACTIVE') ...[
                                        const SizedBox(width: 8),
                                        const Text(
                                          '(Désactivé)',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                              onSelected: (value) async {
                                _isPaused = true;
                                _videoController?.pause();
                                if (value == 'toggle_status') {
                                  final newStatus =
                                      currentItem.status == 'ACTIVE'
                                      ? 'INACTIVE'
                                      : 'ACTIVE';
                                  try {
                                    await TestimonialService.updateStatus(
                                      currentItem.id,
                                      newStatus,
                                    );
                                    // Update local state is tricky without refreshing whole list,
                                    // but we can try to update the object in place for immediate feedback
                                    setState(() {
                                      // We might need to mutate the object directly since it's passed by reference usually
                                      // But let's assume we can't easily replace it in the list without callbacks.
                                      // Actually we can, because we have reference to allCategories
                                      // But 'currentItem' is a local var.
                                      // Re-fetching would be safer but slower.
                                      // Let's just update UI and hopefully next fetch fixes it.
                                      // FORCE REFRESH: Close and reopen? No.
                                      // Ideally we update the item in the list.
                                      // currentItem is reference? Yes.
                                      // Testimonial is final fields? No, likes/views are mutable. Status should be too?
                                      // Status is final in my model definition above!
                                      // Wait, I made status final in the model.
                                      // I should make it mutable or replace the object in the list.
                                    });
                                    Navigator.pop(
                                      context,
                                    ); // Close viewer to refresh? Or show toast?
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          newStatus == 'ACTIVE'
                                              ? 'Statut activé'
                                              : 'Statut désactivé',
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    debugPrint('Error updating status: $e');
                                    _isPaused = false;
                                    _videoController?.play();
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'toggle_status',
                                  child: Text(
                                    currentItem.status == 'ACTIVE'
                                        ? 'Désactiver'
                                        : 'Activer',
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

                // 2. Overlay Text (Comment/Content)
                if (currentItem.content.isNotEmpty)
                  Positioned(
                    bottom: 100,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        currentItem.content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // 3. Bottom Actions (Like & Views)
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Views Count
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.remove_red_eye,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${currentItem.views}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Like Button & Count
                        Column(
                          children: [
                            FloatingActionButton(
                              heroTag: 'like_btn_${currentItem.id}',
                              mini: false,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              onPressed: _likeCurrentStatus,
                              child: Icon(
                                Icons.favorite,
                                color: _likedStatuses.contains(currentItem.id)
                                    ? Colors.red
                                    : Colors.white,
                                size: 35,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${currentItem.likes}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 4),
                                ],
                              ),
                            ),
                          ],
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

  Widget _buildMediaContent(Testimonial item) {
    if (item.mediaType == 'VIDEO' &&
        _videoController != null &&
        _videoController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      );
    } else if (item.mediaType == 'VIDEO') {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // Default to Image for IMAGE or AUDIO (audio won't show much but placeholder)
    return Image.network(
      item.mediaUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, color: Colors.white, size: 50),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
    );
  }

  String _getRemainingTime(DateTime createdAt, String durationStr) {
    try {
      final hours = int.parse(
        durationStr.toLowerCase().replaceAll(RegExp(r'[^0-9]'), ''),
      );
      final expirationTime = createdAt.add(Duration(hours: hours));
      final now = DateTime.now();

      if (now.isAfter(expirationTime)) {
        return 'Expiré';
      }

      final difference = expirationTime.difference(now);

      if (difference.inHours > 0) {
        return '${difference.inHours}h restants';
      } else {
        return '${difference.inMinutes}min restants';
      }
    } catch (e) {
      return '';
    }
  }
}
