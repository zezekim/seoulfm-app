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

  /// The full-screen player, over everything; swipe down or the chevron closes it.
  static Future<void> showNowPlaying(BuildContext context) async {
    if (_player?.mounted ?? false) return;
    // The player covers the status bar, so it needs the window's insets: a sheet drops the top
    // one, and so does the Scaffold's bottom bar the player bar sits in.
    final padding = MediaQueryData.fromView(View.of(context)).padding;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: false,
      backgroundColor: const Color(0xFF09090B),
      shape: const RoundedRectangleBorder(),
      clipBehavior: Clip.antiAlias,
      builder: (sheet) {
        _player = sheet;
        return MediaQuery(
          data: MediaQuery.of(sheet).copyWith(padding: padding),
          child: SizedBox(height: MediaQuery.sizeOf(sheet).height, child: const NowPlayingScreen()),
        );
      },
    );
    _player = null;
  }

  static void openSong(Track t) {
    if (t.id != null) push(SongScreen(track: t));
  }

  static void openArtist(String key, {String? name}) => push(ArtistScreen(artistKey: key, name: name));
}
