import 'package:kaliman_reader_app/services/image_cache_service.dart';

/// Utility class for managing application caches
class CacheManager {
  /// Private constructor to enforce singleton
  CacheManager._();

  /// Singleton instance
  static final CacheManager _instance = CacheManager._();

  /// Factory constructor that returns the singleton instance
  factory CacheManager() => _instance;

  /// The image cache service instance
  final ImageCacheService _imageCacheService = ImageCacheService();

  /// Initialize all caches
  Future<void> initCaches() async {
    await _imageCacheService.init();
  }

  /// Clear all caches
  Future<void> clearAllCaches() async {
    await _imageCacheService.clearCache();
  }

  /// Clear image cache for a specific key
  Future<void> clearImageCache(String key) async {
    await _imageCacheService.clearImageCache(key);
  }

  /// Access to the image cache service
  ImageCacheService get imageCache => _imageCacheService;
}
