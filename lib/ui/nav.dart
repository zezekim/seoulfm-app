import 'package:flutter/material.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/ui/screens/artist_screen.dart';
import 'package:seoulfm/ui/screens/song_screen.dart';

/// Opens pages inside the current tab, so the player bar and tabs stay put.
class Nav {
  static final List<GlobalKey<NavigatorState>> tabs = List.generate(5, (_) => GlobalKey<NavigatorState>());
  static int current = 0;

  static NavigatorState? get _nav => tabs[current].currentState;

  static void push(Widget page) => _nav?.push(MaterialPageRoute<void>(builder: (_) => page));

  static void openSong(Track t) {
    if (t.id != null) push(SongScreen(track: t));
  }

  static void openArtist(String key, {String? name}) => push(ArtistScreen(artistKey: key, name: name));
}
