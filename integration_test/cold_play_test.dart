import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';

import 'helpers.dart';

/// A cold start, then play from the player bar after DELAY seconds: the sound must start.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const delay = int.fromEnvironment('DELAY', defaultValue: 6);

  testWidgets('cold play after $delay s', (t) async {
    await launch(binding, inAppShots: false);
    await wait(t, delay);
    final radio = t.element(find.byType(MiniPlayer)).read<RadioHandler>();
    debugPrint('COLD before: ${radio.debugClock} want=${radio.wantPlaying.value}');
    await t.tap(find.descendant(of: find.byType(MiniPlayer), matching: find.byIcon(AppIcons.play)));
    await wait(t, 8);
    final a = radio.debugClock;
    await wait(t, 4);
    final b = radio.debugClock;
    final s = radio.playbackState.value;
    debugPrint('COLD after: want=${radio.wantPlaying.value} playing=${s.playing} state=${s.processingState} buffering=${radio.buffering.value}');
    debugPrint('COLD clock: $a -> $b');
  });
}
