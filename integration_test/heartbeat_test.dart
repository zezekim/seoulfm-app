import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';

import 'helpers.dart';

/// Plays, holds 100 s (background the app from outside meanwhile: the beats must keep
/// coming, marked hidden), pauses, plays again. Read the `radio: beat` lines.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('heartbeats', (t) async {
    await launch(binding, inAppShots: false);
    await wait(t, 12);
    final radio = t.element(find.byType(MiniPlayer)).read<RadioHandler>();
    debugPrint('HB play');
    await t.tap(find.descendant(of: find.byType(MiniPlayer), matching: find.byIcon(AppIcons.play)));
    await wait(t, 100);
    debugPrint('HB pause');
    await radio.pause();
    await wait(t, 5);
    debugPrint('HB play again');
    await radio.play();
    await wait(t, 8);
    debugPrint('HB done');
  });
}
