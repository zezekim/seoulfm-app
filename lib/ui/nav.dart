import 'package:flutter/material.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/ui/screens/artist_screen.dart';
import 'package:seoulfm/ui/screens/now_playing_screen.dart';
import 'package:seoulfm/ui/screens/song_screen.dart';

/// The tabs, in bar order.
enum AppTab { home, request, charts, more }

/// Opens pages inside the current tab, so the player bar and tabs stay put.
class Nav {
  static final List<GlobalKey<NavigatorState>> tabs = List.generate(
    AppTab.values.length,
    (_) => GlobalKey<NavigatorState>(),
  );

  /// The selected tab; the shell follows it.
  static final ValueNotifier<AppTab> tab = ValueNotifier(AppTab.home);

  static NavigatorState? get _nav => tabs[tab.value.index].currentState;

  /// The open full-screen player's context, if any.
  static BuildContext? _player;

  /// Pushes [page] in the current tab, closing the player first so the page isn't hidden under it.
  static void push(Widget page) {
    final player = _player;
    if (player != null && player.mounted) Navigator.pop(player);
    _nav?.push(MaterialPageRoute<void>(builder: (_) => page));
  }

  /// The full-screen player, over everything. It slides up while the cover grows out of the
  /// player bar (a shared Hero); pulling down at its top, or the chevron, closes it.
  static Future<void> showNowPlaying(BuildContext context) async {
    if (_player?.mounted ?? false) return;
    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (route, _, _) {
          _player = route;
          return const NowPlayingScreen();
        },
        transitionsBuilder: (_, a, _, child) => SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(parent: a, curve: const Cubic(0.2, 0.9, 0.25, 1), reverseCurve: Curves.easeInCubic),
          ),
          child: child,
        ),
      ),
    );
    _player = null;
  }

  static void openSong(Track t) {
    if (t.id != null) push(SongScreen(track: t));
  }

  static void openArtist(String key, {String? name}) => push(ArtistScreen(artistKey: key, name: name));
}
