import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seoulfm/state/cover_colors.dart';

Uint8List _pixels(List<(int, int, int, int)> colours) {
  final out = <int>[];
  for (final (r, g, b, count) in colours) {
    for (var i = 0; i < count; i++) {
      out.addAll([r, g, b, 255]);
    }
  }
  return Uint8List.fromList(out);
}

void main() {
  test('picks the vivid hue over a larger dark background', () {
    final c = CoverColors.dominant(_pixels([(10, 10, 12, 700), (220, 30, 60, 324)]));
    final hsl = HSLColor.fromColor(c);
    expect(hsl.hue, anyOf(lessThan(20), greaterThan(330)));
    expect(hsl.saturation, greaterThan(0.4));
  });

  test('keeps the lightness where white type reads', () {
    final c = CoverColors.dominant(_pixels([(250, 230, 120, 1024)]));
    expect(HSLColor.fromColor(c).lightness, inInclusiveRange(0.3, 0.5));
  });

  test('a black-and-white cover comes out grey', () {
    final c = CoverColors.dominant(_pixels([(240, 240, 240, 512), (20, 20, 20, 512)]));
    expect(HSLColor.fromColor(c).saturation, lessThan(0.1));
  });
}
