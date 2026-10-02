import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/platform/accessibility_prefs.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/state/cover_colors.dart';
import 'package:seoulfm/state/now_playing_controller.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/player_progress.dart';
import 'package:seoulfm/ui/widgets/share_sheet.dart';
import 'package:seoulfm/ui/icons.dart';

/// The lyrics colour: the song's cover colour, as Spotify tints its card, or while that is
/// still being read, the station's accent a shade deeper. [watch] rebuilds when it arrives.
Color lyricsColor(BuildContext context, Track? track, Color stationAccent, {bool watch = true}) {
  final covers = watch ? context.watch<CoverColors>() : context.read<CoverColors>();
  // Deep enough for white lyrics (Spotify's are deep, saturated colours, never neon).
  return forWhiteText(covers.of(track?.artworkUrl) ?? Color.lerp(stationAccent, Colors.black, 0.22)!, ratio: 4.5);
}

/// Text colours on a lyrics background: the lines already sung (and the one being sung)
/// stand out, the ones still to come sit back. Light backgrounds get dark type.
class LyricsPalette {
  const LyricsPalette(this.sung, this.upcoming);
  final Color sung, upcoming;

  factory LyricsPalette.on(Color bg) {
    final lum = bg.computeLuminance();
    if (lum > 0.5) return LyricsPalette(Colors.black, Colors.black.withValues(alpha: 0.4));
    if (lum > 0.08) return LyricsPalette(Colors.white, Colors.black.withValues(alpha: 0.78));
    return LyricsPalette(Colors.white, Colors.white.withValues(alpha: 0.42));
  }
}

/// The synced line covering [positionMs], or -1 before the first.
int activeLyricLine(Lyrics lyrics, int? positionMs) {
  if (positionMs == null) return -1;
  var i = -1;
  for (var k = 0; k < lyrics.lines.length; k++) {
    if (lyrics.lines[k].startMs <= positionMs) i = k;
  }
  return i;
}

/// Lyrics on a coloured [background]: synced lines follow the listener's position and keep
/// the current one a third of the way down; plain text simply scrolls. The edges fade out.
/// With [interactive] false (the card under the player) the lines can't be scrolled by hand.
class LyricsView extends StatefulWidget {
  const LyricsView({
    super.key,
    required this.lyrics,
    required this.background,
    this.fontSize = 24,
    this.interactive = true,
    this.padding = const EdgeInsets.symmetric(vertical: 40),
  });
  final Lyrics lyrics;
  final Color background;
  final double fontSize;
  final bool interactive;
  final EdgeInsets padding;
  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  final _scroll = ScrollController();
  final _keys = <int, GlobalKey>{};
  Timer? _t;
  int _active = -1;

  @override
  void initState() {
    super.initState();
    if (widget.lyrics.synced) _t = Timer.periodic(const Duration(milliseconds: 300), (_) => _follow());
  }

  @override
  void didUpdateWidget(LyricsView old) {
    super.didUpdateWidget(old);
    if (!identical(old.lyrics, widget.lyrics)) {
      _active = -1;
      _keys.clear();
      _t?.cancel();
      _t = widget.lyrics.synced ? Timer.periodic(const Duration(milliseconds: 300), (_) => _follow()) : null;
      if (_scroll.hasClients) _scroll.jumpTo(0);
    }
  }

  void _follow() {
    if (!mounted) return;
    final i = activeLyricLine(widget.lyrics, context.read<NowPlayingController>().positionMs());
    if (i == _active) return;
    setState(() => _active = i);
    // Scroll only this list: `Scrollable.ensureVisible` would also move the page around it.
    final box = _keys[i]?.currentContext?.findRenderObject();
    if (box == null || !_scroll.hasClients) return;
    final target = RenderAbstractViewport.of(box).getOffsetToReveal(box, 0.3).offset;
    final p = _scroll.position;
    final to = target.clamp(p.minScrollExtent, p.maxScrollExtent);
    // Reduce Motion: the next line is simply there, not scrolled to.
    if (context.reduceMotion) {
      _scroll.jumpTo(to);
    } else {
      _scroll.animateTo(to, duration: Motion.slow, curve: Motion.inOut);
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = LyricsPalette.on(widget.background);
    final style = TextStyle(fontSize: widget.fontSize, height: 1.28, fontWeight: FontWeight.w800, letterSpacing: -0.4);
    final physics = widget.interactive ? null : const NeverScrollableScrollPhysics();
    final Widget body;
    if (!widget.lyrics.synced) {
      body = SingleChildScrollView(
        controller: _scroll,
        physics: physics,
        padding: widget.padding,
        child: Text(widget.lyrics.plain ?? '', style: style.copyWith(color: palette.sung)),
      );
    } else {
      // Every line is built (a song's lyrics are short), so the one being sung can always be
      // scrolled to, however far down it is.
      body = SingleChildScrollView(
        controller: _scroll,
        physics: physics,
        padding: widget.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < widget.lyrics.lines.length; i++)
              AnimatedDefaultTextStyle(
                key: _keys.putIfAbsent(i, GlobalKey.new),
                duration: Motion.base,
                style: style.copyWith(color: i <= _active ? palette.sung : palette.upcoming),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: widget.fontSize * 0.3),
                  child: Text(widget.lyrics.lines[i].text.isEmpty ? '♪' : widget.lyrics.lines[i].text),
                ),
              ),
          ],
        ),
      );
    }
    // Fade the lines out at the top and bottom edges.
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x00FFFFFF), Colors.white, Colors.white, Color(0x00FFFFFF)],
        stops: [0, 0.1, 0.88, 1],
      ).createShader(rect),
      child: body,
    );
  }
}

/// Opens the full-screen lyrics over everything.
Future<void> openLyrics(BuildContext context, {required Lyrics lyrics, required Track track}) =>
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        transitionDuration: Motion.slow,
        reverseTransitionDuration: Motion.base,
        pageBuilder: (_, _, _) => LyricsScreen(lyrics: lyrics, track: track),
        // Reduce Motion: a fade in place instead of the slide up.
        transitionsBuilder: (context, a, _, child) {
          final still = context.reduceMotion;
          return FadeTransition(
            opacity: still ? a : kAlwaysCompleteAnimation,
            child: SlideTransition(
              position: still
                  ? const AlwaysStoppedAnimation(Offset.zero)
                  : Tween(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: a, curve: Motion.out)),
              child: child,
            ),
          );
        },
      ),
    );

/// Full-screen lyrics in the station's colour (Spotify's expanded lyrics): the song at the top,
/// the lines in large type following along, progress and play at the bottom. Follows the
/// station on to the next song.
class LyricsScreen extends StatefulWidget {
  const LyricsScreen({super.key, required this.lyrics, required this.track});
  final Lyrics lyrics;
  final Track track;
  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  late Track _track = widget.track;
  late Lyrics? _lyrics = widget.lyrics;

  void _follow(Track? t) {
    if (t == null || t.id == _track.id) return;
    _track = t;
    _lyrics = null;
    final id = t.id;
    if (id == null || !t.hasLyrics) return;
    api
        .lyrics(id)
        .then((l) {
          if (mounted && _track.id == id) setState(() => _lyrics = l);
        })
        .catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    _follow(context.watch<NowPlayingController>().track);
    final channel = context.watch<ChannelController>().active;
    final radio = context.read<RadioHandler>();
    final bg = lyricsColor(context, _track, channel.color);
    final fg = LyricsPalette.on(bg).sung;
    final pad = MediaQuery.paddingOf(context);
    final lyrics = _lyrics;

    return Scaffold(
      backgroundColor: bg,
      body: Padding(
        padding: EdgeInsets.only(top: pad.top + 4, bottom: pad.bottom + 12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: context.l.close,
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(AppIcons.collapse, color: fg, size: 30),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _track.displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: fg),
                        ),
                        Text(
                          _track.displayArtist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: fg.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: context.l.share,
                    onPressed: () =>
                        showShareSheet(context, track: _track, lyrics: lyrics, color: bg, lyricsFirst: true),
                    icon: Icon(AppIcons.share, color: fg, size: 22),
                  ),
                ],
              ),
            ),
            Expanded(
              child: lyrics == null || lyrics.isEmpty
                  ? Center(child: Icon(AppIcons.lyrics, size: 48, color: fg.withValues(alpha: 0.4)))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: LyricsView(
                        lyrics: lyrics,
                        background: bg,
                        fontSize: 30,
                        padding: const EdgeInsets.symmetric(vertical: 80),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(28, 8, 28, 0),
              child: Column(
                children: [
                  PlayerProgress(color: fg),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<bool>(
                    valueListenable: radio.wantPlaying,
                    builder: (_, playing, _) => ValueListenableBuilder<bool>(
                      valueListenable: radio.buffering,
                      builder: (_, buffering, _) => PlayButton(
                        playing: playing,
                        buffering: buffering,
                        size: 64,
                        onImage: true,
                        onPressed: () =>
                            playing ? radio.pause() : context.read<AppState>().tuneIn(channel.key, play: true),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
