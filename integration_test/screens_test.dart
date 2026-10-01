import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:provider/provider.dart';
import 'package:seoulfm/ui/root_shell.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';

import 'helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shot(String name) async {
    await binding.takeScreenshot(name);
  }

  testWidgets('walk the app', (t) async {
    await launch(binding);
    await wait(t, 15);
    await shot('1-home');

    final radio = t.element(find.byType(MiniPlayer)).read<RadioHandler>();
    await t.tap(find.descendant(of: find.byType(MiniPlayer), matching: find.byIcon(Icons.play_arrow_rounded)));
    await wait(t, 12);
    final s = radio.playbackState.value;
    debugPrint('PLAYBACK playing=${s.playing} state=${s.processingState} want=${radio.wantPlaying.value}');
    await shot('2-home-playing');

    await t.drag(find.byType(CustomScrollView).first, const Offset(0, -700));
    await wait(t, 3);
    await shot('3-home-genres');

    await t.tapAt(t.getTopLeft(find.byType(MiniPlayer)) + const Offset(120, 40));
    await Future<void>.delayed(const Duration(milliseconds: 160));
    await t.pump();
    await shot('4a-opening');
    await wait(t, 4);
    await shot('4-player');

    await t.dragFrom(const Offset(200, 600), const Offset(0, -500));
    await wait(t, 3);
    await shot('5-player-lyrics-upnext');

    await t.dragFrom(const Offset(200, 300), const Offset(0, 1500));
    await wait(t, 2);
    debugPrint('CLOSED-BY-PULL ${find.byTooltip('Close').evaluate().isEmpty}');
    if (find.byTooltip('Close').evaluate().isNotEmpty) await t.tap(find.byTooltip('Close'));
    await wait(t, 3);
    for (final tab in ['Request', 'Charts', 'More']) {
      await t.tap(find.descendant(of: find.byType(GlassTabBar), matching: find.text(tab)));
      await wait(t, 5);
      await shot('6-${tab.toLowerCase()}');
    }
    // Request: search.
    await t.tap(find.descendant(of: find.byType(GlassTabBar), matching: find.text('Request')));
    await wait(t, 1);
    await t.enterText(find.byType(TextField), 'IU');
    await wait(t, 5);
    await shot('7-search');
    await t.drag(find.byType(CustomScrollView).last, const Offset(0, -400));
    await wait(t, 2);
    await shot('7b-search-collapsed');

    // Charts → Artists → an artist.
    await t.tap(find.descendant(of: find.byType(GlassTabBar), matching: find.text('Charts')));
    await wait(t, 2);
    await t.ensureVisible(find.text('Artists').last);
    await wait(t, 1);
    await t.tap(find.text('Artists').last);
    await wait(t, 5);
    await t.tap(find.byType(ListTile).first);
    await wait(t, 6);
    await shot('8-artist');
    await t.drag(find.byType(CustomScrollView).last, const Offset(0, -600));
    await wait(t, 2);
    await shot('8b-artist-collapsed');

    // Last: the output picker (AirPlay on iOS, the output switcher on Android); it is native,
    // so capture it from outside the app.
    await t.tap(find.byType(MiniPlayer));
    await wait(t, 4);
    await t.tap(find.byIcon(Platform.isIOS ? AppIcons.airplay : AppIcons.output));
    debugPrint('AIRPLAY-TAPPED');
    await wait(t, 8);

    final after = radio.playbackState.value;
    debugPrint('PLAYBACK-END playing=${after.playing} state=${after.processingState}');
  });
}
