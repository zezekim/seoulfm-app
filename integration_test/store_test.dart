import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seoulfm/ui/root_shell.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';

import 'helpers.dart';

/// Lines up the store screenshots. Each screen prints `SHOT <name>` and holds for a few seconds
/// while tool/store_screenshots.sh captures the whole simulator (with its status bar).
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const tag = String.fromEnvironment('LOCALE', defaultValue: 'en');

  // Held long enough for the capture: the log line can reach the script seconds late (the iPad
  // simulator especially).
  Future<void> shot(WidgetTester t, String name) async {
    debugPrint('SHOT $tag-$name');
    await wait(t, 9);
  }

  testWidgets('store', (t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('seoulfm-locale', tag);
    await prefs.setStringList('seoulfm-favourites', ['dance', 'ballad', 'hiphop', 'ost']);
    await launch(binding, inAppShots: false);
    await wait(t, 14);
    await t.tap(find.descendant(of: find.byType(MiniPlayer), matching: find.byIcon(AppIcons.play)));
    await wait(t, 10);
    await shot(t, '1-home');

    await t.tap(find.byType(MiniPlayer));
    await wait(t, 4);
    await shot(t, '2-player');

    // Lyrics, full screen, when the song on air has them.
    final lyrics = find.byIcon(AppIcons.lyrics);
    if (lyrics.evaluate().isNotEmpty) {
      await t.tap(lyrics.first);
      await wait(t, 5);
      await shot(t, '3-lyrics');
      await t.tap(find.byIcon(AppIcons.collapse).last);
      await wait(t, 2);
    }
    await t.dragFrom(const Offset(200, 300), const Offset(0, 1500));
    await wait(t, 3);

    await t.drag(find.byType(CustomScrollView).first, const Offset(0, -760));
    await wait(t, 3);
    await shot(t, '4-genres');

    await t.tap(find.descendant(of: find.byType(GlassTabBar), matching: find.byIcon(AppIcons.charts)));
    await wait(t, 5);
    await shot(t, '5-charts');

    await t.tap(find.descendant(of: find.byType(GlassTabBar), matching: find.byIcon(AppIcons.request)));
    await wait(t, 4);
    await shot(t, '6-request');
    await prefs.remove('seoulfm-locale');
  });
}
