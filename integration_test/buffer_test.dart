import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';

import 'helpers.dart';

/// How much audio the player holds ahead of what is heard, every 5 s for a minute.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('buffer ahead', (t) async {
    await launch(binding, inAppShots: false);
    await wait(t, 12);
    final radio = t.element(find.byType(MiniPlayer)).read<RadioHandler>();
    await t.tap(find.descendant(of: find.byType(MiniPlayer), matching: find.byIcon(AppIcons.play)));
    final ahead = <double>[];
    for (var i = 0; i < 12; i++) {
      await wait(t, 5);
      final s = radio.playbackState.value;
      final a = radio.bufferAhead.inMilliseconds / 1000;
      ahead.add(a);
      debugPrint('BUF t=${(i + 1) * 5}s ahead=${a.toStringAsFixed(1)}s state=${s.processingState.name} ${radio.debugClock}');
    }
    ahead.sort();
    debugPrint('BUF-SUMMARY min=${ahead.first.toStringAsFixed(1)} median=${ahead[ahead.length ~/ 2].toStringAsFixed(1)}');
  });
}
