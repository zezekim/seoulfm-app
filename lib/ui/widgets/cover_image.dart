import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// The file behind a cover URL: cached on disk, fetched once. Tests swap it for in-memory
/// images (test/goldens), so covers draw without the network; nothing else sets it.
ImageProvider Function(String url) coverProvider = CachedNetworkImageProvider.new;

/// Decode sizes, in pixels. A cover is decoded at the first one that covers it, so a few sizes
/// serve every list and the same file decoded for a 42 and a 48 pt row is one cache entry.
const decodeBuckets = [64, 96, 128, 192, 256, 384, 512, 768, 1024];

/// The decode size for a box of [logical] points at [pixelRatio]; null (the file as is) above
/// the largest bucket or for an unbounded box.
int? decodeBucket(double logical, double pixelRatio) {
  final need = logical * pixelRatio;
  if (!need.isFinite || need <= 0) return null;
  for (final b in decodeBuckets) {
    if (need <= b) return b;
  }
  return null;
}

/// Decodes [image] so its shorter side is [px] (never upscaled): enough for [BoxFit.cover] to fill
/// a [px] square at any aspect. [ResizeImage] with both sides would squash a non-square photo.
@immutable
class CoverResize extends ImageProvider<CoverResizeKey> {
  const CoverResize(this.image, this.px);
  final ImageProvider image;
  final int px;

  @override
  Future<CoverResizeKey> obtainKey(ImageConfiguration configuration) {
    // As ResizeImage does: stay synchronous when the inner key is, so a cached cover paints on
    // the first frame instead of flashing the placeholder.
    Completer<CoverResizeKey>? completer;
    SynchronousFuture<CoverResizeKey>? result;
    image.obtainKey(configuration).then((Object key) {
      if (completer == null) {
        result = SynchronousFuture(CoverResizeKey._(key, px));
      } else {
        completer.complete(CoverResizeKey._(key, px));
      }
    });
    if (result != null) return result!;
    completer = Completer();
    return completer.future;
  }

  @override
  ImageStreamCompleter loadImage(CoverResizeKey key, ImageDecoderCallback decode) {
    Future<ui.Codec> decodeCover(ui.ImmutableBuffer buffer, {ui.TargetImageSizeCallback? getTargetSize}) {
      return decode(
        buffer,
        getTargetSize: (w, h) {
          final short = math.min(w, h);
          if (short <= px) return const ui.TargetImageSize();
          final s = px / short;
          return ui.TargetImageSize(width: (w * s).round(), height: (h * s).round());
        },
      );
    }

    return image.loadImage(key._inner, decodeCover);
  }

  @override
  bool operator ==(Object other) => other is CoverResize && other.image == image && other.px == px;

  @override
  int get hashCode => Object.hash(image, px);
}

@immutable
class CoverResizeKey {
  const CoverResizeKey._(this._inner, this.px);
  final Object _inner;
  final int px;

  @override
  bool operator ==(Object other) => other is CoverResizeKey && other._inner == _inner && other.px == px;

  @override
  int get hashCode => Object.hash(_inner, px);
}
