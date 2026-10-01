import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/data/channels.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/state/now_playing_controller.dart';
import 'package:seoulfm/state/stations_now_playing.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/share.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/marathon_panel.dart';
import 'package:seoulfm/ui/widgets/notices.dart';
import 'package:seoulfm/ui/widgets/request_shelf.dart';
import 'package:seoulfm/ui/widgets/sleep_timer.dart';

/// The Now Playing tab: the player fills the first screen (the cover over its own blurred
/// glow, the song, progress and controls); scrolling up brings the station's lyrics, Up Next,
/// requests (Marathon: the vote) and history. Always dark: the text sits on artwork.
class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final page = AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: const _NowPlayingPage(),
    );
    if (theme.brightness == Brightness.dark) return page;
    return Theme(data: buildTheme(Brightness.dark, context.select<AppState, Color>((a) => a.accent)), child: page);
  }
}

class _NowPlayingPage extends StatefulWidget {
  const _NowPlayingPage();
  @override
  State<_NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<_NowPlayingPage> {
  final _scroll = ScrollController();
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

  void _openLyrics() {
    setState(() => _showLyrics = true);
    _scroll.animateTo(0, duration: Motion.slow, curve: Motion.inOut);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final np = context.watch<NowPlayingController>();
    final channel = context.watch<ChannelController>().active;
    final t = np.track;
    _loadLyrics(t);
    final hasLyrics = _lyrics != null && !_lyrics!.isEmpty;
    final showLyrics = _showLyrics && hasLyrics;

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: Stack(
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
          LayoutBuilder(
            // The player takes the first screen less a sliver, so the sections below peek up.
            builder: (context, box) => CustomScrollView(
              controller: _scroll,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: box.maxHeight - 28,
                    child: _Player(
                      lyrics: showLyrics ? _lyrics : null,
                      hasLyrics: hasLyrics,
                      onToggleLyrics: () => setState(() => _showLyrics = !_showLyrics),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xF209090B),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                        ),
                        const Notices(lossless: true),
                        if (hasLyrics && !showLyrics)
                          _LyricsCard(lyrics: _lyrics!, color: channel.color, onExpand: _openLyrics),
                        const _UpNext(),
                        if (channel.marathon) const MarathonPanel() else RequestShelf(key: ValueKey(channel.key)),
                        const _Recent(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Keeps the clock readable over whatever scrolls under it.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.paddingOf(context).top + 12,
            child: const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xE609090B), Color(0x0009090B)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── The player ────────────────────────────────────────────────────────────

class _Player extends StatelessWidget {
  const _Player({required this.lyrics, required this.hasLyrics, required this.onToggleLyrics});

  /// The lyrics to show in place of the cover, or null for the cover.
  final Lyrics? lyrics;
  final bool hasLyrics;
  final VoidCallback onToggleLyrics;

  @override
  Widget build(BuildContext context) {
    final np = context.watch<NowPlayingController>();
    final channel = context.watch<ChannelController>().active;
    final radio = context.read<RadioHandler>();
    final t = np.track;
    final top = MediaQuery.paddingOf(context).top;
    const white = Colors.white;

    return Padding(
      padding: EdgeInsets.only(top: top + 4, bottom: 8),
      child: Column(
        children: [
          // Share · "Playing from SeoulFM Pop!" (tap to switch station) · lyrics.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: context.l.share,
                  onPressed: () => t != null ? shareSong(context, t) : shareStation(context, channel),
                  icon: Icon(Icons.ios_share_rounded, color: white.withValues(alpha: 0.75), size: 22),
                ),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: context.l.chooseStation,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(Radii.md),
                      onTap: () => showStationPicker(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: [
                            Text(
                              context.l.playingFrom.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                                color: white.withValues(alpha: 0.5),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (channel.onAir) ...[
                                  LiveDot(color: channel.color, size: 6),
                                  const SizedBox(width: 6),
                                ],
                                Flexible(
                                  child: Text(
                                    'SeoulFM ${channel.name}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: white),
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: white.withValues(alpha: 0.7)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: hasLyrics ? 1 : 0,
                  duration: Motion.base,
                  child: IconButton(
                    onPressed: hasLyrics ? onToggleLyrics : null,
                    tooltip: context.l.lyrics,
                    style: IconButton.styleFrom(backgroundColor: lyrics != null ? white.withValues(alpha: 0.15) : null),
                    icon: Icon(Icons.lyrics_outlined, color: white.withValues(alpha: lyrics != null ? 1 : 0.75)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              // Swipe the cover sideways to change station.
              onHorizontalDragEnd: (d) {
                final v = d.primaryVelocity ?? 0;
                if (v.abs() < 300) return;
                v < 0 ? radio.skipToNext() : radio.skipToPrevious();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 20),
                child: AnimatedSwitcher(
                  duration: Motion.base,
                  switchInCurve: Motion.out,
                  child: lyrics != null
                      ? LyricsView(key: const ValueKey('lyrics'), lyrics: lyrics!)
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
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xD9000000),
                                        blurRadius: 80,
                                        offset: Offset(0, 30),
                                        spreadRadius: -20,
                                      ),
                                    ],
                                  ),
                                  child: Artwork(t?.artworkUrl, radius: 14, iconSize: 56),
                                ),
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
                        onTap: t == null ? null : () => Nav.openSong(t),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    t?.displayTitle ??
                                        (np.station?.onAir == false ? context.l.offAir : 'SeoulFM ${channel.name}'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
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
                              style: TextStyle(fontSize: 16, color: white.withValues(alpha: 0.6)),
                            ),
                            if (t?.dedication?.name != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  context.l.dedicatedBy(t!.dedication!.name!),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: white.withValues(alpha: 0.5)),
                                ),
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
                const SizedBox(height: 10),
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
                      icon: Icon(Icons.skip_previous_rounded, color: white.withValues(alpha: 0.9), size: 38),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: radio.wantPlaying,
                      builder: (_, playing, _) => ValueListenableBuilder<bool>(
                        valueListenable: radio.buffering,
                        builder: (_, buffering, _) => PlayButton(
                          playing: playing,
                          buffering: buffering,
                          size: 72,
                          onImage: true,
                          onPressed: () =>
                              playing ? radio.pause() : context.read<AppState>().tuneIn(channel.key, play: true),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: context.l.nextStation,
                      onPressed: radio.skipToNext,
                      icon: Icon(Icons.skip_next_rounded, color: white.withValues(alpha: 0.9), size: 38),
                    ),
                    SizedBox(
                      width: 48,
                      child: Center(child: _QualityBadge(app: context.read<AppState>())),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Align(alignment: AlignmentDirectional.centerStart, child: SleepTimerButton(onImage: true)),
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
            return IconButton(
              tooltip: context.l.retryFlac,
              onPressed: radio.retryLossless,
              icon: const Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFF5B73C)),
            );
          }
          return Text(
            lossless ? 'FLAC' : 'AUTO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: Colors.white.withValues(alpha: 0.55),
            ),
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
    final style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: Colors.white.withValues(alpha: 0.5),
      fontFeatures: tabular,
    );
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

/// The blurred cover glow behind the page (`AmbientArt`).
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

// ── Station picker ────────────────────────────────────────────────────────

/// Every station with what it is playing; picking one tunes and plays it.
Future<void> showStationPicker(BuildContext context) => showModalBottomSheet(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  builder: (_) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.7,
    maxChildSize: 0.92,
    builder: (context, scroll) => _StationPicker(scroll: scroll),
  ),
);

class _StationPicker extends StatelessWidget {
  const _StationPicker({required this.scroll});
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) {
    final cc = context.watch<ChannelController>();
    final others = context.watch<StationsNowPlaying>().byStation;
    final heard = context.watch<NowPlayingController>().track;
    final radio = context.read<RadioHandler>();
    final c = context.sfm;
    return ListView(
      controller: scroll,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 16),
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(color: c.text.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(9)),
          ),
        ),
        ShelfTitle(context.l.chooseStation),
        for (final ch in cc.channels)
          _StationRow(
            channel: ch,
            track: ch.key == cc.active.key ? heard : others[ch.key]?.current,
            tuned: ch.key == cc.active.key,
            playing: radio.wantPlaying,
            onTap: ch.tunable
                ? () {
                    Navigator.pop(context);
                    context.read<AppState>().tuneIn(ch.key, play: true);
                  }
                : null,
          ),
      ],
    );
  }
}

class _StationRow extends StatelessWidget {
  const _StationRow({
    required this.channel,
    required this.track,
    required this.tuned,
    required this.playing,
    required this.onTap,
  });
  final Channel channel;
  final Track? track;
  final bool tuned;
  final ValueListenable<bool> playing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return Opacity(
      opacity: channel.tunable ? 1 : 0.45,
      child: ListTile(
        onTap: onTap,
        selected: tuned,
        leading: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            children: [
              Positioned.fill(
                child: track?.artworkUrl != null
                    ? Artwork(track!.artworkUrl, radius: Radii.sm)
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          color: channel.color.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(Radii.sm),
                        ),
                      ),
              ),
              Positioned(
                left: 4,
                bottom: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: channel.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          channel.name,
          style: TextStyle(fontWeight: FontWeight.w700, color: tuned ? channel.color : c.text),
        ),
        subtitle: Text(
          channel.comingSoon
              ? context.l.comingSoon
              : track != null
              ? '${track!.displayTitle} · ${track!.displayArtist}'
              : channel.tagline,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: c.muted),
        ),
        trailing: tuned
            ? ValueListenableBuilder<bool>(
                valueListenable: playing,
                builder: (_, p, _) => p ? EqBars(color: channel.color, height: 14) : const SizedBox.shrink(),
              )
            : null,
      ),
    );
  }
}

// ── Sections under the player ─────────────────────────────────────────────

/// A peek at the lyrics in the station's colour; "Show lyrics" puts them in place of the cover.
class _LyricsCard extends StatelessWidget {
  const _LyricsCard({required this.lyrics, required this.color, required this.onExpand});
  final Lyrics lyrics;
  final Color color;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          color: Color.lerp(color, Colors.black, 0.45),
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 6, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l.lyrics,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: onExpand,
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: Text(context.l.showLyrics),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: LyricsView(lyrics: lyrics, compact: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpNext extends StatelessWidget {
  const _UpNext();
  @override
  Widget build(BuildContext context) {
    final upcoming = context.watch<NowPlayingController>().upcoming;
    if (upcoming.isEmpty) return const SizedBox.shrink();
    final c = context.sfm;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    const cover = 112.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShelfTitle(context.l.upNext),
        SizedBox(
          height: cover + 54,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: upcoming.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final t = upcoming[i];
              final mins = t.startsAtEpoch != null ? ((t.startsAtEpoch! - now) / 60).ceil() : null;
              return GestureDetector(
                onTap: () => Nav.openSong(t),
                child: SizedBox(
                  width: cover,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: cover,
                        height: cover,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Artwork(t.artworkUrl, radius: Radii.md),
                            if (mins != null && mins > 0)
                              Positioned(
                                right: 6,
                                bottom: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xB3000000),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    context.l.inMinutes(mins),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            if (t.isRequest)
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    context.l.requestBadge,
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      color: readableOn(Theme.of(context).colorScheme.secondary),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        t.displayArtist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: c.muted),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Recent extends StatelessWidget {
  const _Recent();
  @override
  Widget build(BuildContext context) {
    final recent = context.watch<NowPlayingController>().recent.take(10).toList();
    if (recent.isEmpty) return const SizedBox.shrink();
    final c = context.sfm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShelfTitle(context.l.recentlyPlayed),
        for (final t in recent)
          TrackRow(
            track: t,
            onTap: () => Nav.openSong(t),
            trailing: Text(
              t.playedAtEpoch == null ? '' : timeAgo(context, t.playedAtEpoch!),
              style: TextStyle(fontSize: 11, color: c.faint, fontFeatures: tabular),
            ),
          ),
      ],
    );
  }
}

// ── Lyrics ────────────────────────────────────────────────────────────────

/// Lyrics: synced lines follow the listener's position and scroll themselves; plain text scrolls.
/// [compact] is the smaller type for the card under the player.
class LyricsView extends StatefulWidget {
  const LyricsView({super.key, required this.lyrics, this.onImage = true, this.compact = false});
  final Lyrics lyrics;
  final bool onImage, compact;
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
    // Scroll only this list: `Scrollable.ensureVisible` would also move the page around it.
    final box = _keys[i]?.currentContext?.findRenderObject();
    if (box == null || !_scroll.hasClients) return;
    final target = RenderAbstractViewport.of(box).getOffsetToReveal(box, 0.35).offset;
    final p = _scroll.position;
    _scroll.animateTo(target.clamp(p.minScrollExtent, p.maxScrollExtent), duration: Motion.slow, curve: Motion.inOut);
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
    final size = widget.compact ? 18.0 : 22.0;
    if (!widget.lyrics.synced) {
      return SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          widget.lyrics.plain ?? '',
          style: TextStyle(
            fontSize: size - 4,
            height: 1.6,
            fontWeight: FontWeight.w600,
            color: base.withValues(alpha: 0.85),
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      itemCount: widget.lyrics.lines.length,
      padding: EdgeInsets.symmetric(vertical: widget.compact ? 40 : 120),
      itemBuilder: (_, i) {
        final key = _keys.putIfAbsent(i, GlobalKey.new);
        final line = widget.lyrics.lines[i];
        final active = i == _active;
        return AnimatedDefaultTextStyle(
          key: key,
          duration: Motion.base,
          style: TextStyle(
            fontSize: size,
            height: 1.35,
            fontWeight: FontWeight.w700,
            color: base.withValues(alpha: active ? 1 : (i < _active ? 0.35 : 0.5)),
            fontFamilyFallback: const ['Pretendard', 'Apple SD Gothic Neo', 'Noto Sans KR'],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(line.text.isEmpty ? '♪' : line.text),
          ),
        );
      },
    );
  }
}
