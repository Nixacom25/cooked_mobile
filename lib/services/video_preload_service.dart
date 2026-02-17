import 'package:app_ecommerce/services/global_video_cache.dart';
import 'package:app_ecommerce/data/mock_database.dart';

/// Service to preload first videos during app startup
/// Loads videos in background during splash/welcome screens
class VideoPreloadService {
  static bool _isPreloading = false;
  static bool _hasPreloaded = false;

  /// Preload first 10 videos from all products
  static Future<void> preloadFirstVideos() async {
    if (_isPreloading || _hasPreloaded) {
      print('⚠️ Preload already running or completed');
      return;
    }

    _isPreloading = true;
    print('🚀 Starting video preload...');

    try {
      // Get first 10 products
      final products = MockDatabase.products.take(10).toList();
      int totalPreloaded = 0;

      print('📦 Preloading ${products.length} videos');

      // Preload all in parallel
      await Future.wait(
        products.map((product) async {
          try {
            await GlobalVideoCache.getController(product.videoUrl);
            totalPreloaded++;
          } catch (e) {
            print('❌ Failed to preload ${product.title}: $e');
          }
        }),
      );

      print('✅ Preload complete! Loaded $totalPreloaded videos');
      print('📊 ${GlobalVideoCache.getStats()}');

      _hasPreloaded = true;
    } catch (e) {
      print('❌ Preload error: $e');
    } finally {
      _isPreloading = false;
    }
  }

  /// Check if preload is complete
  static bool get hasPreloaded => _hasPreloaded;

  /// Check if preload is in progress
  static bool get isPreloading => _isPreloading;
}
