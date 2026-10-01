// Renders the app icon and Android's adaptive foreground (a big "SFM"), and the launch
// screen's wordmark ("seoul" heavy, "fm" light), in Pretendard, so they are sharp at any size. Run: flutter test tool/render_icons_test.dart
// then: dart run flutter_launcher_icons
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _bg = Color(0xFF0A0A0B);

Future<void> _font() async {
  final bytes = File('assets/fonts/PretendardVariable.ttf').readAsBytesSync();
  await (FontLoader('Pretendard')..addFont(Future.value(ByteData.view(bytes.buffer)))).load();
}

/// The wordmark laid out to [width] logical pixels.
TextPainter _wordmark(double width) {
  TextPainter at(double size) => TextPainter(
    text: TextSpan(
      style: TextStyle(fontFamily: 'Pretendard', fontSize: size, color: Colors.white, letterSpacing: -size * 0.012, height: 1),
      children: const [
        TextSpan(text: 'seoul', style: TextStyle(fontWeight: FontWeight.w700)),
        TextSpan(text: 'fm', style: TextStyle(fontWeight: FontWeight.w300)),
      ],
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final probe = at(100);
  return at(100 * width / probe.width);
}

/// "SFM", heavy and tight, laid out to [width] logical pixels.
TextPainter _monogram(double width) {
  TextPainter at(double size) => TextPainter(
    text: TextSpan(
      text: 'SFM',
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: -size * 0.045,
        height: 1,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final probe = at(100);
  return at(100 * width / probe.width);
}

Future<void> _png(
  String path,
  int size, {
  Color? background,
  required double wordWidth,
  TextPainter Function(double width) mark = _wordmark,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final s = size.toDouble();
  if (background != null) canvas.drawRect(Rect.fromLTWH(0, 0, s, s), Paint()..color = background);
  final tp = mark(wordWidth);
  // Centre on the letters' x-height band rather than the line box, so it sits optically centred.
  tp.paint(canvas, Offset((s - tp.width) / 2, (s - tp.height) / 2 + tp.height * 0.06));
  final image = await recorder.endRecording().toImage(size, size);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(data!.buffer.asUint8List());
}

void main() {
  testWidgets('render icons', (t) async {
    await t.runAsync(() async {
      await _font();
      // The App Store and home-screen icon: a big "SFM" on near-black.
      await _png('assets/icon/app-icon-1024.png', 1024, background: _bg, wordWidth: 1024 * 0.74, mark: _monogram);
      // Android's adaptive layer: launchers crop to a circle in the middle 66%; keep inside it.
      await _png('assets/icon/adaptive-foreground.png', 1024, wordWidth: 1024 * 0.5, mark: _monogram);
      // The launch screen's wordmark (drawn on the launch background).
      await _png('assets/icon/splash.png', 1024, wordWidth: 1024 * 0.62);
    });
  });
}
