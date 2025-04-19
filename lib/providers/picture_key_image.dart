import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaliman_reader_app/repositories/object_repository.dart';
import 'package:kaliman_reader_app/services/image_cache_service.dart';

class PictureKeyImage extends ImageProvider<PictureKeyImage> {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments [url] and [scale] must not be null.
  const PictureKeyImage(this.key, {this.scale = 1.0, this.headers});

  final String key;

  final double scale;

  final Map<String, String>? headers;

  @override
  Future<PictureKeyImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<PictureKeyImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(
      PictureKeyImage key, ImageDecoderCallback decode) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.key,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<PictureKeyImage>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
    PictureKeyImage key,
    StreamController<ImageChunkEvent> chunkEvents,
    ImageDecoderCallback decode,
  ) async {
    try {
      assert(key == this);
      var url = (await ObjectRepository.getObject(key.key)).url;

      // Initialize the cache service
      final cacheService = ImageCacheService();

      // Get bytes from cache or download
      final Uint8List bytes =
          await cacheService.cacheImageFromUrl(key.key, url);

      if (bytes.lengthInBytes == 0) {
        throw Exception('PictureKeyImage is an empty file: $url');
      }

      return decode(await ImmutableBuffer.fromUint8List(bytes));
    } catch (e) {
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a microtask to give the cache a chance to add the key.
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    } finally {
      chunkEvents.close();
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is PictureKeyImage && other.key == key && other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(key, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'PictureKeyImage')}("$key", scale: $scale)';
}
