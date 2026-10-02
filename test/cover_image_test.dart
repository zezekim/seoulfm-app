import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seoulfm/ui/widgets/cover_image.dart';

Future<ui.Image> _resolve(ImageProvider provider) async {
  final stream = provider.resolve(ImageConfiguration.empty);
  final done = Completer<ui.Image>();
  stream.addListener(ImageStreamListener((info, _) => done.complete(info.image)));
  return done.future;
}

Future<Uint8List> _png(int w, int h) async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()), Paint()..color = const Color(0xFF3366FF));
  final image = await recorder.endRecording().toImage(w, h);
  return (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('decode sizes snap up to a few shared buckets', () {
    expect(decodeBucket(42, 3), 128);
    expect(decodeBucket(48, 2.625), 128);
    expect(decodeBucket(44, 3), 192);
    expect(decodeBucket(240, 3), 768);
    expect(decodeBucket(400, 3), isNull); // larger than any bucket: the file as is
    expect(decodeBucket(double.infinity, 3), isNull);
    expect(decodeBucket(0, 3), isNull);
  });

  testWidgets('a wide photo keeps its shape, its short side at the bucket', (tester) async {
    await tester.runAsync(() async {
      final bytes = await _png(400, 200);
      final image = await _resolve(CoverResize(MemoryImage(bytes), 64));
      expect([image.width, image.height], [128, 64]);
      // Never upscaled.
      final small = await _resolve(CoverResize(MemoryImage(await _png(40, 30)), 64));
      expect([small.width, small.height], [40, 30]);
    });
  });
}
