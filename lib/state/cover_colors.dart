import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

/// The colour of a cover, as Spotify and Apple Music tint their players: the most vivid hue
/// in the artwork, settled to a lightness white type reads on. Grey covers get a grey.
///
/// `of(url)` answers from memory and, the first time it sees a cover, reads it (a 32 px copy
/// through the same image cache the covers use) and notifies when it knows.
class CoverColors extends ChangeNotifier {
  static const _max = 120;
  final _known = <String, Color>{}; // insertion-ordered: the oldest goes first
  final _pending = <String>{};

  Color? of(String? url) {
    if (url == null) return null;
    final c = _known.remove(url);
    if (c != null) {
      _known[url] = c; // most recently used last
      return c;
    }
    if (_pending.add(url)) unawaited(_read(url));
    return null;
  }

  Future<void> _read(String url) async {
    try {
      final bytes = await _pixels(url);
      if (bytes == null) return;
      _known[url] = dominant(bytes);
      while (_known.length > _max) {
        _known.remove(_known.keys.first);
      }
      notifyListeners();
    } catch (_) {
      // A cover that can't be read keeps the station colour.
    } finally {
      _pending.remove(url);
    }
  }

  static Future<Uint8List?> _pixels(String url) async {
    final provider = ResizeImage(CachedNetworkImageProvider(url), width: 32, height: 32);
    final done = Completer<ui.Image?>();
    final stream = provider.resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        if (!done.isCompleted) done.complete(info.image.clone());
        stream.removeListener(listener);
      },
      onError: (_, _) {
        if (!done.isCompleted) done.complete(null);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    final image = await done.future.timeout(const Duration(seconds: 15), onTimeout: () => null);
    if (image == null) return null;
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    return data?.buffer.asUint8List();
  }

  /// The most vivid hue in RGBA [bytes], weighted by how much of the cover it covers.
  @visibleForTesting
  static Color dominant(Uint8List bytes) {
    final weight = List<double>.filled(36, 0);
    final sums = List.generate(36, (_) => [0.0, 0.0, 0.0]);
    var r0 = 0.0, g0 = 0.0, b0 = 0.0, n = 0;
    for (var i = 0; i + 3 < bytes.length; i += 4) {
      if (bytes[i + 3] < 128) continue;
      final r = bytes[i], g = bytes[i + 1], b = bytes[i + 2];
      r0 += r;
      g0 += g;
      b0 += b;
      n++;
      final hsl = HSLColor.fromColor(Color.fromARGB(255, r, g, b));
      if (hsl.saturation < 0.25 || hsl.lightness < 0.12 || hsl.lightness > 0.9) continue;
      final bucket = (hsl.hue / 10).floor() % 36;
      final w = hsl.saturation * (1 - (hsl.lightness - 0.5).abs() * 1.2);
      weight[bucket] += w;
      sums[bucket][0] += r * w;
      sums[bucket][1] += g * w;
      sums[bucket][2] += b * w;
    }
    if (n == 0) return const Color(0xFF3A3A3F);
    var best = 0;
    for (var k = 1; k < 36; k++) {
      if (weight[k] > weight[best]) best = k;
    }
    final Color raw;
    // Too little colour (a black-and-white cover): its average, which comes out grey.
    if (weight[best] < n * 0.04) {
      raw = Color.fromARGB(255, (r0 / n).round(), (g0 / n).round(), (b0 / n).round());
    } else {
      final w = weight[best];
      raw = Color.fromARGB(255, (sums[best][0] / w).round(), (sums[best][1] / w).round(), (sums[best][2] / w).round());
    }
    final hsl = HSLColor.fromColor(raw);
    return hsl.withLightness(hsl.lightness.clamp(0.3, 0.5)).withSaturation(hsl.saturation.clamp(0.0, 0.8)).toColor();
  }
}
