import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/screens/album_screen.dart';
import 'package:seoulfm/ui/widgets/common.dart';

import 'helpers.dart';

/// An artist's albums open: tap one, see its songs, each with Request.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('album opens', (t) async {
    await launch(binding, inAppShots: false);
    await wait(t, 8);
    // The first chart artist with albums.
    String? key, name;
    for (final a in await api.topArtists(limit: 15)) {
      final p = await api.artist(a.key);
      if (p.albums.any((x) => x.tracks.isNotEmpty)) {
        key = a.key;
        name = a.name;
        break;
      }
    }
    expect(key, isNotNull, reason: 'no chart artist has albums');
    Nav.openArtist(key!, name: name);
    await wait(t, 5);
    final albums = find.text('Albums');
    await t.scrollUntilVisible(albums, 300, scrollable: find.byType(Scrollable).first);
    await wait(t, 1);
    await t.drag(find.byType(Scrollable).first, const Offset(0, -250));
    await wait(t, 2);
    final tile = find.descendant(of: find.byType(Pressable), matching: find.byType(Artwork)).first;
    await t.tap(tile);
    await wait(t, 3);
    expect(find.byType(AlbumScreen), findsOneWidget);
    final rows = find.byType(TrackRow).evaluate().length;
    debugPrint('ALBUM artist=$name rows=$rows');
    debugPrint('SHOT album');
    await wait(t, 6);
    expect(rows, greaterThan(0));
  });
}
