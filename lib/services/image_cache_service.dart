import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';

/// Service that handles caching of image data in the device's temporary directory
class ImageCacheService {
  /// Private constructor to enforce singleton
  ImageCacheService._();

  /// Singleton instance
  static final ImageCacheService _instance = ImageCacheService._();

  /// Factory constructor that returns the singleton instance
  factory ImageCacheService() => _instance;

  /// Cache directory reference
  Directory? _cacheDir;

  /// Initialize the cache service
  Future<void> init() async {
    // Get the temporary directory for this app
    _cacheDir = await getTemporaryDirectory();
  }

  /// Generate a filename from a url or key by creating a hash
  String _generateCacheFilename(String key) {
    // Create a hash of the key to use as filename
    final bytes = utf8.encode(key);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if an image is cached
  Future<bool> isCached(String key) async {
    if (_cacheDir == null) await init();

    final filename = _generateCacheFilename(key);
    final file = File('${_cacheDir!.path}/$filename');
    return file.exists();
  }

  /// Get cached image data
  Future<Uint8List?> getCachedImageData(String key) async {
    if (_cacheDir == null) await init();

    final filename = _generateCacheFilename(key);
    final file = File('${_cacheDir!.path}/$filename');

    if (await file.exists()) {
      log('Image cached: $key');
      return await file.readAsBytes();
    }

    log('Image not cached: $key');

    return null;
  }

  /// Cache image data
  Future<void> cacheImageData(String key, Uint8List data) async {
    if (_cacheDir == null) await init();

    final filename = _generateCacheFilename(key);
    final file = File('${_cacheDir!.path}/$filename');

    await file.writeAsBytes(data);
  }

  /// Cache image from URL using HttpClient
  Future<Uint8List> cacheImageFromUrl(String key, String url) async {
    if (_cacheDir == null) await init();

    // Check if already cached
    final cachedData = await getCachedImageData(key);
    if (cachedData != null) {
      return cachedData;
    }

    // Download the image
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();

    if (response.statusCode != HttpStatus.ok) {
      throw NetworkImageLoadException(
          statusCode: response.statusCode, uri: Uri.parse(url));
    }

    // Read the bytes
    final bytes = await consolidateHttpClientResponseBytes(response);

    // Cache the bytes
    await cacheImageData(key, bytes);

    return bytes;
  }

  /// Clear the entire image cache
  Future<void> clearCache() async {
    if (_cacheDir == null) await init();

    final dir = _cacheDir!;
    if (await dir.exists()) {
      await for (final entity in dir.list()) {
        if (entity is File) {
          await entity.delete();
        }
      }
    }
  }

  /// Clear a specific image from cache
  Future<void> clearImageCache(String key) async {
    if (_cacheDir == null) await init();

    final filename = _generateCacheFilename(key);
    final file = File('${_cacheDir!.path}/$filename');

    if (await file.exists()) {
      await file.delete();
    }
  }
}
