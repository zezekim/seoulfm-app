import 'package:flutter/material.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/ui/screens/artist_screen.dart';
import 'package:seoulfm/ui/screens/now_playing_screen.dart';
import 'package:seoulfm/ui/screens/song_screen.dart';
import 'package:seoulfm/ui/screens/support_screen.dart';

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

  /// The player's presentation while it is open: the app behind it sinks back into a card as
  /// it rises (Apple Music's sheet), and comes forward again as it closes.
  static final ValueNotifier<Animation<double>?> playerPresentation = ValueNotifier(null);

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
    // Reduce Motion: a quick fade in place, no slide and no card (the shell drops its scale too).
    final still = MediaQuery.disableAnimationsOf(context);
    final route = PageRouteBuilder<void>(
      transitionDuration: Duration(milliseconds: still ? 200 : 420),
      reverseTransitionDuration: Duration(milliseconds: still ? 150 : 320),
      pageBuilder: (page, _, _) {
        _player = page;
        return const NowPlayingScreen();
      },
      transitionsBuilder: (context, a, _, child) {
        final still = MediaQuery.disableAnimationsOf(context);
        final curved = CurvedAnimation(
          parent: a,
          curve: const Cubic(0.2, 0.9, 0.25, 1),
          reverseCurve: Curves.easeInCubic,
        );
        // A card while it moves (the screen's own corner radius), square once it settles.
        final corner = MediaQuery.paddingOf(context).top > 30 ? 48.0 : 16.0;
        return FadeTransition(
          opacity: still ? a.drive(CurveTween(curve: Curves.easeOut)) : kAlwaysCompleteAnimation,
          child: SlideTransition(
            position: still
                ? const AlwaysStoppedAnimation(Offset.zero)
                : Tween(begin: const Offset(0, 1), end: Offset.zero).animate(curved),
            child: AnimatedBuilder(
              animation: a,
              builder: (_, child) => a.isCompleted || still
                  ? child!
                  : ClipRRect(borderRadius: BorderRadius.circular(corner), child: child),
              child: child,
            ),
          ),
        );
      },
    );
    final closed = Navigator.of(context, rootNavigator: true).push(route);
    // The route's animation exists once it is pushed (not during a build, where setting this
    // would rebuild the app mid-frame).
    playerPresentation.value = route.animation;
    await closed;
    _player = null;
    playerPresentation.value = null;
  }

  static void openSupport() => push(const SupportScreen());

  static void openSong(Track t) {
    if (t.id != null) push(SongScreen(track: t));
  }

  static void openArtist(String key, {String? name}) => push(ArtistScreen(artistKey: key, name: name));

  /// The artist of [t]. Library songs carry their artist's key; songs from the live feed don't,
  /// so it is looked up from the song.
  static Future<void> openArtistOf(Track t) async {
    var key = t.artistKey;
    if (key == null && t.id != null) {
      try {
        key = (await api.track(t.id!)).track.artistKey;
      } catch (_) {}
    }
    if (key != null) openArtist(key, name: t.displayArtist);
  }

  /// Whether [openArtistOf] can find an artist for [t].
  static bool hasArtist(Track t) => t.artistKey != null || (t.id != null && t.displayArtist.isNotEmpty);
}
