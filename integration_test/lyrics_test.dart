import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:seoulfm/platform/screenshots.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';

import 'helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('lyrics and sharing', (t) async {
    await launch(binding);
    await wait(t, 15);
    await t.tap(find.descendant(of: find.byType(MiniPlayer), matching: find.byIcon(Icons.play_arrow_rounded)));
    await wait(t, 8);
    await t.tapAt(t.getTopLeft(find.byType(MiniPlayer)) + const Offset(120, 40));
    await wait(t, 4);

    // Wait for a song with lyrics (up to ~4 minutes), skipping stations if needed.
    var tries = 0;
    while (find.byTooltip('Show lyrics').evaluate().isEmpty && tries < 8) {
      debugPrint('NO-LYRICS yet, next station');
      await t.tap(find.byTooltip('Next station'));
      await wait(t, 10);
      tries++;
    }
    if (find.byTooltip('Show lyrics').evaluate().isEmpty) {
      debugPrint('GAVE-UP no lyrics found');
      return;
    }
    await t.dragFrom(const Offset(200, 600), const Offset(0, -520));
    await wait(t, 4);
    await binding.takeScreenshot('1-lyrics-card');

    await t.tap(find.byTooltip('Show lyrics').first);
    await wait(t, 4);
    await binding.takeScreenshot('2-lyrics-full');

    await t.tap(find.byTooltip('Share').last);
    await wait(t, 4);
    await binding.takeScreenshot('3-share-lyrics');

    await t.tap(find.text('Edit lyrics'));
    await wait(t, 3);
    await binding.takeScreenshot('4-edit-lyrics');
    await t.tap(find.text('Done'));
    await wait(t, 2);

    await t.tap(find.text('Song').last);
    await wait(t, 3);
    await binding.takeScreenshot('5-share-song');
    await t.tap(find.text('Copy link'));
    await wait(t, 1);
    debugPrint('COPIED ${find.text('Copied').evaluate().isNotEmpty}');

    await t.tapAt(const Offset(200, 40)); // the barrier closes the sheet
    await wait(t, 2);
    await t.tap(find.byTooltip('Close').last); // the full-screen lyrics
    await wait(t, 3);

    Screenshots.taken.value++; // what the native hook does on a real screenshot
    await wait(t, 4);
    await binding.takeScreenshot('6-share-after-screenshot');
    debugPrint('SHEET-AFTER-SCREENSHOT ${find.text('Copy link').evaluate().isNotEmpty}');
  });
}
