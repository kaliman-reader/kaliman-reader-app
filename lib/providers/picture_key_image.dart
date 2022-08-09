import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kaliman_reader_app/repositories/object_repository.dart';

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
  ImageStreamCompleter load(PictureKeyImage key, DecoderCallback decode) {
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

  // Do not access this field directly; use [_httpClient] instead.
  // We set `autoUncompress` to false to ensure that we can trust the value of
  // the `Content-Length` HTTP header. We automatically uncompress the content
  // in our call to [consolidateHttpClientResponseBytes].
  static final HttpClient _sharedHttpClient = HttpClient()
    ..autoUncompress = false;

  static HttpClient get _httpClient {
    HttpClient client = _sharedHttpClient;
    return client;
  }

  Future<ui.Codec> _loadAsync(
    PictureKeyImage key,
    StreamController<ImageChunkEvent> chunkEvents,
    DecoderCallback decode,
  ) async {
    try {
      assert(key == this);
      var url = (await ObjectRepository.getObject(key.key)).url;
      final Uri resolved = Uri.base.resolve(url);

      final HttpClientRequest request = await _httpClient.getUrl(resolved);

      headers?.forEach((String name, String value) {
        request.headers.add(name, value);
      });
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        // The network may be only temporarily unavailable, or the file will be
        // added on the server later. Avoid having future calls to resolve
        // fail to check the network again.
        await response.drain<List<int>>(<int>[]);
        throw NetworkImageLoadException(
            statusCode: response.statusCode, uri: resolved);
      }

      final Uint8List bytes = await consolidateHttpClientResponseBytes(
        response,
        onBytesReceived: (int cumulative, int? total) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ));
        },
      );
      if (bytes.lengthInBytes == 0) {
        throw Exception('PictureKeyImage is an empty file: $resolved');
      }

      return decode(bytes);
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
