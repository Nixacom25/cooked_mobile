import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app_ecommerce/models/status_category.dart';
import 'package:app_ecommerce/models/testimonial.dart';
import 'package:app_ecommerce/services/testimonial_service.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_ecommerce/utils/url_sanitizer.dart';

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
  AudioPlayer? _audioPlayer;
  VideoPlayerController? _nextVideoController;
  AudioPlayer? _nextAudioPlayer;

  final Set<String> _likedStatuses = {};
  final Set<String> _viewedStatuses = {};
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();

    _currentCategoryIndex = widget.initialCategoryIndex;
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    // Load saved likes and views
    final savedLikes = _prefs?.getStringList('liked_statuses') ?? [];
    final savedViews = _prefs?.getStringList('viewed_statuses') ?? [];

    setState(() {
      _likedStatuses.addAll(savedLikes);
      _viewedStatuses.addAll(savedViews);
    });

    _startTimer();
    _markAsViewed(); // Mark initial status
  }

  void _markAsViewed() async {
    if (_prefs == null) return;

    final category = widget.allCategories[_currentCategoryIndex];
    if (category.items.isNotEmpty) {
      final testimonial = category.items[_currentStatusIndex];
      if (!_viewedStatuses.contains(testimonial.id)) {
        setState(() {
          _viewedStatuses.add(testimonial.id);
        });

        // Save to local storage
        await _prefs!.setStringList(
          'viewed_statuses',
          _viewedStatuses.map((id) => id.toString()).toList(),
        );

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
    if (_prefs == null) return;

    final category = widget.allCategories[_currentCategoryIndex];
    if (category.items.isNotEmpty) {
      final testimonial = category.items[_currentStatusIndex];
      if (_likedStatuses.contains(testimonial.id)) {
        setState(() {
          _likedStatuses.remove(testimonial.id);
        });

        await _prefs!.setStringList(
          'liked_statuses',
          _likedStatuses.map((id) => id.toString()).toList(),
        );
        // Optional: Call unlike endpoint if created
      } else {
        setState(() {
          _likedStatuses.add(testimonial.id);
        });

        await _prefs!.setStringList(
          'liked_statuses',
          _likedStatuses.map((id) => id.toString()).toList(),
        );

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
    _disposeMediaControllers();
    _periodicTimer?.cancel();
    _progressValue = 0.0;
    _isPaused = false;

    final currentCategory = widget.allCategories[_currentCategoryIndex];
    if (currentCategory.items.isEmpty) return;

    final currentItem = currentCategory.items[_currentStatusIndex];

    if (currentItem.mediaType == 'VIDEO') {
      final sanitizedUrl = UrlSanitizer.getCleanPath(currentItem.mediaUrl);
      if (_nextVideoController != null &&
          _nextVideoController!.dataSource == sanitizedUrl) {
        _videoController = _nextVideoController;
        _nextVideoController = null;
        if (_videoController!.value.isInitialized) {
          _videoController?.play();
        } else {
          _videoController?.initialize().then((_) {
            if (mounted) setState(() {});
            _videoController?.play();
          });
        }
      } else {
        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(sanitizedUrl))
              ..initialize().then((_) {
                if (mounted) setState(() {});
                _videoController?.play();
              });
      }
    } else if (currentItem.mediaType == 'AUDIO' ||
        currentItem.mediaUrl.contains('.m4a') ||
        currentItem.mediaUrl.contains('.mp3')) {
      final sanitizedUrl = UrlSanitizer.getCleanPath(currentItem.mediaUrl);
      if (_nextAudioPlayer != null) {
        _audioPlayer = _nextAudioPlayer;
        _nextAudioPlayer = null;
      } else {
        _audioPlayer = AudioPlayer();
      }
      _audioPlayer?.play(UrlSource(sanitizedUrl));
    }

    _preloadNext();

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
        return;
      }

      // If audio, sync progress with audio
      if (currentItem.mediaType == 'AUDIO' ||
          currentItem.mediaUrl.contains('.m4a') ||
          currentItem.mediaUrl.contains('.mp3')) {
        _audioPlayer?.onPositionChanged.listen((position) {
          _audioPlayer?.getDuration().then((duration) {
            if (duration != null && duration.inMilliseconds > 0) {
              if (mounted) {
                setState(() {
                  _progressValue =
                      position.inMilliseconds / duration.inMilliseconds;
                });
                if (_progressValue >= 1.0) {
                  timer.cancel();
                  _nextStatus();
                }
              }
            }
          });
        });
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

  void _disposeMediaControllers() {
    _videoController?.dispose();
    _videoController = null;
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _nextVideoController?.dispose();
    _nextVideoController = null;
    _nextAudioPlayer?.dispose();
    _nextAudioPlayer = null;
  }

  void _preloadNext() {
    final currentCategory = widget.allCategories[_currentCategoryIndex];
    Testimonial? nextItem;

    if (_currentStatusIndex < currentCategory.items.length - 1) {
      nextItem = currentCategory.items[_currentStatusIndex + 1];
    } else if (_currentCategoryIndex < widget.allCategories.length - 1) {
      final nextCategory = widget.allCategories[_currentCategoryIndex + 1];
      if (nextCategory.items.isNotEmpty) {
        nextItem = nextCategory.items[0];
      }
    }

    if (nextItem == null) return;

    if (nextItem.mediaType == 'VIDEO') {
      final sanitizedUrl = UrlSanitizer.getCleanPath(nextItem.mediaUrl);
      _nextVideoController =
          VideoPlayerController.networkUrl(Uri.parse(sanitizedUrl))
            ..initialize().then((_) {
              // Pre-initialized and ready
            });
    } else if (nextItem.mediaType == 'AUDIO') {
      final sanitizedUrl = UrlSanitizer.getCleanPath(nextItem.mediaUrl);
      _nextAudioPlayer = AudioPlayer();
      _nextAudioPlayer?.setSource(UrlSource(sanitizedUrl));
    } else if (nextItem.mediaType == 'IMAGE') {
      // Preload image into cache
      final sanitizedUrl = UrlSanitizer.getCleanPath(nextItem.mediaUrl);
      precacheImage(CachedNetworkImageProvider(sanitizedUrl), context);
    }
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
    _disposeMediaControllers();

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
                                        currentItem.clientName ?? 'Anonyme',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
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
    } else if (item.mediaType == 'AUDIO' ||
        item.mediaUrl.contains('.m4a') ||
        item.mediaUrl.contains('.mp3')) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1E2832),
              const Color(0xFF1E2832).withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6F00).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFF6F00).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.mic, size: 80, color: Color(0xFFFF6F00)),
            ),
            const SizedBox(height: 30),
            const Text(
              'Témoignage Audio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Écoute en cours...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Default to Image for IMAGE
    return UrlSanitizer.buildImage(
      item.mediaUrl,
      fit: BoxFit.contain,
      errorWidget: const Icon(
        Icons.broken_image,
        color: Colors.white,
        size: 50,
      ),
    );
  }
}
