import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/state/now_playing_controller.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/share.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/sleep_timer.dart';

/// The full-screen Now Playing view (`NowPlayingSheet`): the artwork over its own blurred
/// glow, the song, progress, play and share, the lyrics in place of the cover on request.
/// Swipe down to dismiss. Always dark: the text sits on artwork. The audio is untouched.
Future<void> showNowPlaying(BuildContext context) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  useRootNavigator: true,
  useSafeArea: false,
  backgroundColor: const Color(0xFF09090B),
  shape: const RoundedRectangleBorder(),
  clipBehavior: Clip.antiAlias,
  builder: (_) => const NowPlayingSheet(),
);

class NowPlayingSheet extends StatefulWidget {
  const NowPlayingSheet({super.key});
  @override
  State<NowPlayingSheet> createState() => _NowPlayingSheetState();
}

class _NowPlayingSheetState extends State<NowPlayingSheet> {
  bool _showLyrics = false;
  String? _lyricsFor;
  Lyrics? _lyrics;

  void _loadLyrics(Track? t) {
    final id = t?.id;
    if (id == _lyricsFor) return;
    _lyricsFor = id;
    _lyrics = null;
    if (id == null || t?.hasLyrics != true) return;
    api
        .lyrics(id)
        .then((l) {
          if (mounted && _lyricsFor == id) setState(() => _lyrics = l);
        })
        .catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final np = context.watch<NowPlayingController>();
    final channel = context.watch<ChannelController>().active;
    final radio = context.read<RadioHandler>();
    final t = np.track;
    _loadLyrics(t);
    final hasLyrics = _lyrics != null && !_lyrics!.isEmpty;
    final showLyrics = _showLyrics && hasLyrics;
    final pad = MediaQuery.paddingOf(context);
    const white = Colors.white;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      child: Stack(
        children: [
          Positioned.fill(child: _AmbientArt(url: t?.artworkUrl)),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x59000000), Color(0x8C000000), Color(0xBF000000)],
                  stops: [0, 0.6, 1],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: pad.top + 8, bottom: pad.bottom + 20),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(color: white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(9)),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        tooltip: context.l.close,
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: white.withValues(alpha: 0.75), size: 28),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              context.l.nowPlaying.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                                color: white.withValues(alpha: 0.5),
                              ),
                            ),
                            Text(
                              'SeoulFM ${channel.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: white.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: hasLyrics ? 1 : 0,
                        duration: Motion.base,
                        child: IconButton(
                          onPressed: hasLyrics ? () => setState(() => _showLyrics = !_showLyrics) : null,
                          tooltip: context.l.lyrics,
                          style: IconButton.styleFrom(backgroundColor: showLyrics ? white.withValues(alpha: 0.15) : null),
                          icon: Icon(Icons.lyrics_outlined, color: white.withValues(alpha: showLyrics ? 1 : 0.75)),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
                    child: AnimatedSwitcher(
                      duration: Motion.base,
                      switchInCurve: Motion.out,
                      child: showLyrics
                          ? LyricsView(key: const ValueKey('lyrics'), lyrics: _lyrics!)
                          : Center(
                              key: const ValueKey('art'),
                              child: ValueListenableBuilder<bool>(
                                valueListenable: radio.wantPlaying,
                                builder: (_, playing, _) => AnimatedScale(
                                  scale: playing ? 1 : 0.86,
                                  duration: Motion.slow,
                                  curve: Motion.out,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: const [
                                          BoxShadow(color: Color(0xD9000000), blurRadius: 80, offset: Offset(0, 30), spreadRadius: -20),
                                        ],
                                      ),
                                      child: Artwork(t?.artworkUrl, radius: 18, iconSize: 56),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: t == null
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      Nav.openSong(t);
                                    },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          t?.displayTitle ?? (np.station?.onAir == false ? context.l.offAir : ''),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            color: white,
                                            letterSpacing: -0.4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      HotChip(trackId: t?.id),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    t?.displayArtist ?? channel.tagline,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 15, color: white.withValues(alpha: 0.6)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          RatingButtons(trackId: t?.id, onImage: true, size: 24),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const _Progress(),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 48,
                            child: ValueListenableBuilder<bool>(
                              valueListenable: radio.wantPlaying,
                              builder: (_, playing, _) => Center(
                                child: playing
                                    ? EqBars(color: white.withValues(alpha: 0.8), height: 16)
                                    : Text(
                                        context.l.live,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5,
                                          color: white.withValues(alpha: 0.6),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: context.l.previousStation,
                            onPressed: radio.skipToPrevious,
                            icon: Icon(Icons.skip_previous_rounded, color: white.withValues(alpha: 0.85), size: 34),
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: radio.wantPlaying,
                            builder: (_, playing, _) => ValueListenableBuilder<bool>(
                              valueListenable: radio.buffering,
                              builder: (_, buffering, _) =>
                                  PlayButton(playing: playing, buffering: buffering, onPressed: radio.toggle, size: 72, onImage: true),
                            ),
                          ),
                          IconButton(
                            tooltip: context.l.nextStation,
                            onPressed: radio.skipToNext,
                            icon: Icon(Icons.skip_next_rounded, color: white.withValues(alpha: 0.85), size: 34),
                          ),
                          IconButton(
                            tooltip: context.l.share,
                            onPressed: () => t != null ? shareSong(context, t) : shareStation(context, channel),
                            icon: Icon(Icons.ios_share_rounded, color: white.withValues(alpha: 0.75)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SleepTimerButton(onImage: true),
                          _QualityBadge(app: context.read<AppState>()),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QualityBadge extends StatelessWidget {
  const _QualityBadge({required this.app});
  final AppState app;
  @override
  Widget build(BuildContext context) {
    final radio = app.radio;
    return ValueListenableBuilder<bool>(
      valueListenable: radio.losslessActive,
      builder: (_, lossless, _) => ValueListenableBuilder<bool>(
        valueListenable: radio.losslessFailed,
        builder: (_, failed, _) {
          if (failed) {
            return TextButton.icon(
              onPressed: radio.retryLossless,
              icon: const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFF5B73C)),
              label: Text(context.l.retryFlac, style: const TextStyle(color: Color(0xFFF5B73C), fontSize: 12)),
            );
          }
          return Text(
            lossless ? 'FLAC' : 'AUTO',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: Colors.white.withValues(alpha: 0.55)),
          );
        },
      ),
    );
  }
}

/// Elapsed and −remaining on the listener's own clock (`positionMs`), ticking each second.
class _Progress extends StatefulWidget {
  const _Progress();
  @override
  State<_Progress> createState() => _ProgressState();
}

class _ProgressState extends State<_Progress> {
  late final Timer _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final np = context.read<NowPlayingController>();
    final pos = np.positionMs() ?? 0;
    final dur = np.track?.durationMs ?? 0;
    final f = dur > 0 ? (pos / dur).clamp(0.0, 1.0) : 0.0;
    final style = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.5), fontFeatures: tabular);
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: LinearProgressIndicator(
            value: f,
            minHeight: 4,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.9)),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(fmtDuration(pos), style: style),
            Text(dur > 0 ? '−${fmtDuration(dur - pos)}' : '', style: style),
          ],
        ),
      ],
    );
  }
}

/// The blurred cover glow behind the sheet (`AmbientArt`).
class _AmbientArt extends StatelessWidget {
  const _AmbientArt({this.url});
  final String? url;
  @override
  Widget build(BuildContext context) {
    if (url == null) return const ColoredBox(color: Color(0xFF09090B));
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, children: [...previous, ?current]),
      child: ImageFiltered(
        key: ValueKey(url),
        imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60, tileMode: TileMode.decal),
        child: Transform.scale(scale: 1.4, child: Opacity(opacity: 0.95, child: Artwork(url, radius: 0))),
      ),
    );
  }
}

/// Lyrics: synced lines follow the listener's position and scroll themselves; plain text scrolls.
class LyricsView extends StatefulWidget {
  const LyricsView({super.key, required this.lyrics, this.onImage = true});
  final Lyrics lyrics;
  final bool onImage;
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

  void _follow() {
    final pos = context.read<NowPlayingController>().positionMs();
    if (pos == null) return;
    final lines = widget.lyrics.lines;
    var i = -1;
    for (var k = 0; k < lines.length; k++) {
      if (lines[k].startMs <= pos) i = k;
    }
    if (i == _active) return;
    setState(() => _active = i);
    final ctx = _keys[i]?.currentContext;
    if (ctx != null) Scrollable.ensureVisible(ctx, alignment: 0.35, duration: Motion.slow, curve: Motion.inOut);
  }

  @override
  void dispose() {
    _t?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.onImage ? Colors.white : context.sfm.text;
    if (!widget.lyrics.synced) {
      return SingleChildScrollView(
        controller: _scroll,
        child: Text(
          widget.lyrics.plain ?? '',
          style: TextStyle(fontSize: 18, height: 1.6, fontWeight: FontWeight.w600, color: base.withValues(alpha: 0.85)),
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      itemCount: widget.lyrics.lines.length,
      padding: const EdgeInsets.symmetric(vertical: 120),
      itemBuilder: (_, i) {
        final key = _keys.putIfAbsent(i, GlobalKey.new);
        final line = widget.lyrics.lines[i];
        final active = i == _active;
        return AnimatedDefaultTextStyle(
          key: key,
          duration: Motion.base,
          style: TextStyle(
            fontSize: 22,
            height: 1.35,
            fontWeight: FontWeight.w700,
            color: base.withValues(alpha: active ? 1 : (i < _active ? 0.35 : 0.5)),
            fontFamilyFallback: const ['Pretendard', 'Apple SD Gothic Neo', 'Noto Sans KR'],
          ),
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(line.text.isEmpty ? '♪' : line.text)),
        );
      },
    );
  }
}
