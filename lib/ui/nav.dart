import 'package:flutter/material.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/ui/screens/artist_screen.dart';
import 'package:seoulfm/ui/screens/song_screen.dart';

/// The tabs, in bar order.
enum AppTab { home, nowPlaying, search, charts, more }

/// Opens pages inside the current tab, so the player bar and tabs stay put.
class Nav {
  static final List<GlobalKey<NavigatorState>> tabs = List.generate(
    AppTab.values.length,
    (_) => GlobalKey<NavigatorState>(),
  );

  /// The selected tab; the shell follows it.
  static final ValueNotifier<AppTab> tab = ValueNotifier(AppTab.home);

  static NavigatorState? get _nav => tabs[tab.value.index].currentState;

  static void push(Widget page) => _nav?.push(MaterialPageRoute<void>(builder: (_) => page));

  static void showNowPlaying() => tab.value = AppTab.nowPlaying;

  static void openSong(Track t) {
    if (t.id != null) push(SongScreen(track: t));
  }

  static void openArtist(String key, {String? name}) => push(ArtistScreen(artistKey: key, name: name));
}
