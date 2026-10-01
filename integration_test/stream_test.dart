import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:provider/provider.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';

import 'helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('stream stability', (t) async {
    await launch(binding);
    for (var i = 0; i < 60; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      await t.pump();
    }
    final radio = t.element(find.byType(MiniPlayer)).read<RadioHandler>();
    var stalls = 0, firstReadyMs = -1;
    var was = false;
    final start = DateTime.now();
    radio.buffering.addListener(() {
      final now = radio.buffering.value;
      if (now && !was && firstReadyMs >= 0) stalls++;
      was = now;
    });
    radio.playbackState.listen((s) {
      if (firstReadyMs < 0 && s.playing && s.processingState.name == 'ready') {
        firstReadyMs = DateTime.now().difference(start).inMilliseconds;
      }
    });
    await t.tap(find.descendant(of: find.byType(MiniPlayer), matching: find.byIcon(Icons.play_arrow_rounded)));
    for (var i = 0; i < 90 * 4; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      await t.pump();
    }
    debugPrint('STREAM firstReady=${firstReadyMs}ms stalls=$stalls kbps=${radio.aacKbps.value}');
  });
}
