import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';

import 'helpers.dart';

/// How long the first tap on play takes to be heard: from the tap until the player's clock
/// moves. `--dart-define=WAIT=20` waits longer after launch before tapping (a preload gone stale).
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('startup', (t) async {
    await launch(binding, inAppShots: false);
    const waitS = int.fromEnvironment('WAIT', defaultValue: 6);
    await wait(t, waitS);
    final radio = t.element(find.byType(MiniPlayer)).read<RadioHandler>();
    int pos() => int.parse(RegExp(r'pos=(\d+)').firstMatch(radio.debugClock)!.group(1)!);
    final start = DateTime.now();
    await t.tap(find.descendant(of: find.byType(MiniPlayer), matching: find.byIcon(AppIcons.play)));
    // Heard once the clock ticks forward in small steps (loading a source jumps it).
    var prev = pos(), ticks = 0;
    var readyMs = -1, heardMs = -1;
    while (DateTime.now().difference(start) < const Duration(seconds: 20) && heardMs < 0) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await t.pump();
      final s = radio.playbackState.value;
      final ms = DateTime.now().difference(start).inMilliseconds;
      if (readyMs < 0 && s.playing && s.processingState.name == 'ready') readyMs = ms;
      final p = pos(), step = p - prev;
      prev = p;
      ticks = step > 0 && step < 500 ? ticks + 1 : 0;
      if (ticks >= 2) heardMs = ms;
    }
    debugPrint('STARTUP wait=${waitS}s ready=${readyMs}ms heard=${heardMs}ms');
    expect(heardMs, greaterThan(0));
  });
}
