import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/state/now_playing_controller.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/screens/artist_screen.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';
import 'package:seoulfm/ui/widgets/spatial_badge.dart';

import 'helpers.dart';

/// The iOS 26 look: glass bars, the player rising as a card, the 3D BS2B badge, and the
/// artist page reached from the player. Prints SHOT lines for a capture loop.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shot(WidgetTester t, String name) async {
    debugPrint('SHOT $name');
    await wait(t, 6);
  }

  testWidgets('glass', (t) async {
    await launch(binding, inAppShots: false);
    await wait(t, 10);
    final radio = t.element(find.byType(MiniPlayer)).read<RadioHandler>();
    await radio.play();
    await wait(t, 8);
    await t.drag(find.byType(CustomScrollView).first, const Offset(0, -500));
    await wait(t, 2);
    await shot(t, 'g1-glass-bars');

    // Mid-rise: the app behind sinks into a card.
    await t.tap(find.byType(MiniPlayer));
    await t.pump(const Duration(milliseconds: 160));
    debugPrint('SHOT g2-rising');
    await Future<void>.delayed(const Duration(seconds: 3));
    await wait(t, 4);
    expect(find.byType(SpatialAudioBadge), findsOneWidget);
    await shot(t, 'g3-player-badge');

    await t.tap(find.byType(SpatialAudioBadge));
    await wait(t, 2);
    await shot(t, 'g4-badge-info');
    Navigator.of(t.element(find.byType(SpatialAudioBadge)), rootNavigator: true).pop();
    await wait(t, 2);

    final track = t.element(find.byType(SpatialAudioBadge)).read<NowPlayingController>().track!;
    await Nav.openArtistOf(track);
    await wait(t, 6);
    expect(find.byType(ArtistScreen), findsOneWidget);
    await shot(t, 'g5-artist');
    await t.drag(find.byType(CustomScrollView).last, const Offset(0, -420));
    await wait(t, 2);
    await shot(t, 'g6-artist-scrolled');
    await radio.pause();
  });
}
