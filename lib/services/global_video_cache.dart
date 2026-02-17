import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Global permanent video cache
/// Controllers are loaded ONCE and kept forever until app closes
/// Eliminates all reloading and black screens
class GlobalVideoCache {
  static final Map<String, VideoPlayerController> _cache = {};
  static final Map<String, bool> _isLoading = {};
  static final _cacheManager = DefaultCacheManager();

  // Multi-play & Reference Counting state
  static const int _maxConcurrentVideos = 4;
  static final List<String> _playingUrls = []; // FIFO of playing URLs
  static final Map<String, Set<String>> _activeOwners =
      {}; // URL -> Set of Owner IDs

  /// Get or create controller (PERMANENT - never disposed except app close)
  static Future<VideoPlayerController> getController(String videoUrl) async {
    // Return if already cached
    if (_cache.containsKey(videoUrl)) {
      // print('♻️ Cache HIT: ${_getShortUrl(videoUrl)}'); // Verbose
      return _cache[videoUrl]!;
    }

    // Wait if already loading
    if (_isLoading[videoUrl] == true) {
      print('⏳ Waiting for loading: ${_getShortUrl(videoUrl)}');
      while (_isLoading[videoUrl] == true) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _cache[videoUrl]!;
    }

    // Load NEW video
    _isLoading[videoUrl] = true;

    try {
      print('📥 Cache MISS - Loading: ${_getShortUrl(videoUrl)}');

      // Cache video file
      final cachedFile = await _cacheManager
          .getSingleFile(videoUrl)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Video cache timeout');
            },
          );

      // Create controller
      final controller = VideoPlayerController.file(cachedFile);

      // Initialize controller
      await controller.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          controller.dispose();
          throw TimeoutException('Video init timeout');
        },
      );

      controller.setLooping(true);
      controller.setVolume(0.0); // Muted for mini-videos

      // SAVE PERMANENTLY
      _cache[videoUrl] = controller;
      _isLoading[videoUrl] = false;

      print('✅ Cached permanently: ${_getShortUrl(videoUrl)}');
      print('📊 Total cached: ${_cache.length} videos');

      return controller;
    } catch (e) {
      _isLoading[videoUrl] = false;
      print('❌ Error caching ${_getShortUrl(videoUrl)}: $e');
      rethrow;
    }
  }

  /// Play video with Reference Counting
  /// [ownerId] uniquely identifies the widget requesting playback (e.g. toString())
  static void play(String videoUrl, {required String ownerId}) {
    if (!_cache.containsKey(videoUrl)) return;

    // 1. Register owner
    _activeOwners.putIfAbsent(videoUrl, () => {});
    _activeOwners[videoUrl]!.add(ownerId);

    // 2. Manage Concurrency (Max 4)
    if (!_playingUrls.contains(videoUrl)) {
      // New video starting
      if (_playingUrls.length >= _maxConcurrentVideos) {
        // Evict oldest
        final oldestUrl = _playingUrls.removeAt(0);
        _pauseInternal(oldestUrl);
        print(
          '⏸️ Evicted oldest (Limit $_maxConcurrentVideos): ${_getShortUrl(oldestUrl)}',
        );
      }
      _playingUrls.add(videoUrl);
    }

    // 3. Play actual controller
    final controller = _cache[videoUrl]!;
    if (!controller.value.isPlaying) {
      controller.play();
      print(
        '▶️ Playing (Refs: ${_activeOwners[videoUrl]!.length}): ${_getShortUrl(videoUrl)} for $ownerId',
      );
    }
  }

  /// Pause video with Reference Counting
  /// Only pauses if NO other owners are watching
  static void pause(String videoUrl, {required String ownerId}) {
    if (!_cache.containsKey(videoUrl)) return;

    // 1. Remove owner
    if (_activeOwners.containsKey(videoUrl)) {
      _activeOwners[videoUrl]!.remove(ownerId);

      // 2. Pause ONLY if no owners left
      if (_activeOwners[videoUrl]!.isEmpty) {
        _playingUrls.remove(videoUrl);
        _pauseInternal(videoUrl);
      } else {
        print(
          '⚠️ Kept playing (Refs: ${_activeOwners[videoUrl]!.length}): ${_getShortUrl(videoUrl)} (Paused by $ownerId)',
        );
      }
    }
  }

  /// Internal pause helper (bypasses ref counting)
  static void _pauseInternal(String videoUrl) {
    if (_cache.containsKey(videoUrl)) {
      _cache[videoUrl]!.pause();
      // Clear owners when internally paused/evicted
      _activeOwners[videoUrl]?.clear();
      print('⏸️ Paused: ${_getShortUrl(videoUrl)}');
    }
  }

  /// Pause ALL videos (e.g. app paused)
  static void pauseAll() {
    for (final url in List<String>.from(_playingUrls)) {
      _pauseInternal(url);
    }
    _playingUrls.clear();
    _activeOwners.clear();
    print('⏸️ Paused ALL videos');
  }

  /// Pause all except specific URL (Legacy support / Force focus)
  /// BE CAREFUL: This clears references for other videos!
  /// Used mainly when entering Full Screen Mode to silence background noise
  static void pauseAllExcept(String? keepUrl) {
    for (final url in List<String>.from(_playingUrls)) {
      if (url != keepUrl) {
        _pauseInternal(url);
      }
    }
    _playingUrls.removeWhere((url) => url != keepUrl);
    // Clean owners map for non-kept videos
    _activeOwners.removeWhere((url, owners) => url != keepUrl);
  }

  /// Check if controller exists
  static bool hasController(String videoUrl) {
    return _cache.containsKey(videoUrl);
  }

  /// Dispose ALL controllers (only on app close)
  static void disposeAll() {
    print('🧹 Disposing ALL ${_cache.length} videos');
    for (final controller in _cache.values) {
      controller.dispose();
    }
    _cache.clear();
    _isLoading.clear();
    _playingUrls.clear();
    _activeOwners.clear();
  }

  /// Get stats for debugging
  static Map<String, dynamic> getStats() {
    return {
      'totalCached': _cache.length,
      'playing': _playingUrls.length,
      'owners': _activeOwners.map(
        (k, v) => MapEntry(_getShortUrl(k), v.length),
      ),
    };
  }

  /// Helper to shorten URL for logs
  static String _getShortUrl(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    return segments.isNotEmpty ? segments.last : url;
  }
}
