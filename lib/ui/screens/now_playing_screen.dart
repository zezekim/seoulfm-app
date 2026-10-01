import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/data/channels.dart';
import 'package:seoulfm/platform/output_devices.dart';
import 'package:seoulfm/platform/screenshots.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/state/now_playing_controller.dart';
import 'package:seoulfm/state/stations_now_playing.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/screens/lyrics_screen.dart';
import 'package:seoulfm/ui/share.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/marathon_panel.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';
import 'package:seoulfm/ui/widgets/notices.dart';
import 'package:seoulfm/ui/widgets/player_progress.dart';
import 'package:seoulfm/ui/widgets/request_shelf.dart';
import 'package:seoulfm/ui/widgets/share_sheet.dart';
import 'package:seoulfm/ui/widgets/sleep_timer.dart';
import 'package:seoulfm/ui/icons.dart';

/// The full-screen player, opened from the player bar (`Nav.showNowPlaying`). The player fills
/// the first screen (the cover over its own blurred glow, the song, progress and controls);
/// scrolling up brings the station's lyrics, Up Next, requests (Marathon: the vote) and history.
/// Always dark: the text sits on artwork.
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
  String? _lyricsFor;
  Lyrics? _lyrics;

  @override
  void initState() {
    super.initState();
    Screenshots.taken.addListener(_onScreenshot);
  }

  /// A screenshot of the player: offer the share sheet, on the lyrics card when there are lyrics.
  void _onScreenshot() {
    if (mounted && ModalRoute.of(context)?.isCurrent == true) _share(lyricsFirst: true);
  }

  void _share({bool lyricsFirst = false}) {
    final t = context.read<NowPlayingController>().track;
    final channel = context.read<ChannelController>().active;
    if (t == null) {
      shareStation(context, channel);
      return;
    }
    final lyrics = _lyrics != null && !_lyrics!.isEmpty ? _lyrics : null;
    final color = lyricsColor(context, t, channel.color, watch: false);
    showShareSheet(context, track: t, lyrics: lyrics, color: color, lyricsFirst: lyricsFirst);
  }

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

  bool _closing = false;

  /// Pulled down past the top by a finger: close, as Apple Music's player does.
  bool _onPull(ScrollUpdateNotification n) {
    if (!_closing && n.dragDetails != null && n.metrics.pixels < -110) {
      _closing = true;
      Navigator.of(context).maybePop();
    }
    return false;
  }

  void _openLyrics() {
    final t = context.read<NowPlayingController>().track;
    if (_lyrics != null && t != null) openLyrics(context, lyrics: _lyrics!, track: t);
  }

  @override
  void dispose() {
    Screenshots.taken.removeListener(_onScreenshot);
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
            builder: (context, box) => NotificationListener<ScrollUpdateNotification>(
              onNotification: _onPull,
              child: CustomScrollView(
                controller: _scroll,
                // Bouncing everywhere, so pulling down at the top can close the player.
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: box.maxHeight - 28,
                      child: _Player(hasLyrics: hasLyrics, onOpenLyrics: _openLyrics, onShare: _share),
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
                          if (hasLyrics)
                            _LyricsCard(
                              lyrics: _lyrics!,
                              color: lyricsColor(context, t, channel.color),
                              onExpand: _openLyrics,
                              onShare: () => _share(lyricsFirst: true),
                            ),
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
          ),
          // Keeps the clock readable over whatever scrolls under it; at the top the cover's own
          // scrim does that, so this one fades in only once the page moves.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.paddingOf(context).top + 12,
            child: IgnorePointer(
              child: ListenableBuilder(
                listenable: _scroll,
                builder: (_, child) =>
                    Opacity(opacity: _scroll.hasClients ? (_scroll.offset / 120).clamp(0.0, 1.0) : 0, child: child),
                child: const DecoratedBox(
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
          ),
        ],
      ),
    );
  }
}

// ── The player ────────────────────────────────────────────────────────────

class _Player extends StatelessWidget {
  const _Player({required this.hasLyrics, required this.onOpenLyrics, required this.onShare});

  final bool hasLyrics;
  final VoidCallback onOpenLyrics, onShare;

  @override
  Widget build(BuildContext context) {
    final np = context.watch<NowPlayingController>();
    final channel = context.watch<ChannelController>().active;
    final radio = context.read<RadioHandler>();
    final t = np.track;
    final top = MediaQuery.paddingOf(context).top;
    const white = Colors.white;

    final content = Padding(
      padding: EdgeInsets.only(top: top + 4, bottom: MediaQuery.paddingOf(context).bottom + 8),
      child: Column(
        children: [
          // Close · "Playing from SeoulFM Pop!" (tap to switch station) · lyrics.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: context.l.close,
                  onPressed: () => Navigator.maybePop(context),
                  icon: Icon(AppIcons.collapse, color: white.withValues(alpha: 0.8), size: 30),
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
                                Icon(AppIcons.collapse, size: 18, color: white.withValues(alpha: 0.7)),
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
                    onPressed: hasLyrics ? onOpenLyrics : null,
                    tooltip: context.l.lyrics,
                    icon: Icon(AppIcons.lyrics, color: white.withValues(alpha: 0.85)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              // Swipe the cover sideways to change station.
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (d) {
                final v = d.primaryVelocity ?? 0;
                if (v.abs() < 300) return;
                v < 0 ? radio.skipToNext() : radio.skipToPrevious();
              },
              child: const SizedBox.expand(),
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
                const PlayerProgress(),
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
                      icon: Icon(AppIcons.skipPrevious, color: white.withValues(alpha: 0.9), size: 38),
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
                      icon: Icon(AppIcons.skipNext, color: white.withValues(alpha: 0.9), size: 38),
                    ),
                    const SizedBox(width: 48, child: Center(child: OutputDeviceButton())),
                  ],
                ),
                const SizedBox(height: 4),
                // Equal columns either side, so the quality badge sits on the centre line.
                Row(
                  children: [
                    const Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: SleepTimerButton(onImage: true, iconOnly: true),
                      ),
                    ),
                    _QualityBadge(app: context.read<AppState>()),
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: IconButton(
                          tooltip: context.l.share,
                          onPressed: onShare,
                          icon: Icon(AppIcons.share, color: white.withValues(alpha: 0.75), size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // The cover runs edge to edge from the top of the screen and melts into its own glow
    // (Apple Music's full-bleed player).
    return LayoutBuilder(
      builder: (context, box) {
        // Down to just above the title, as square as that allows: on a tall phone the sides of
        // the cover are trimmed a little (never more than a quarter), on a wide one it stays square.
        // Whole pixels: a fractional edge leaves a row the fade doesn't reach.
        final art = (box.maxHeight - 290)
            .clamp(min(box.maxWidth, box.maxHeight * 0.5), box.maxWidth * 1.35)
            .floorToDouble();
        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: art,
              child: Hero(
                tag: playerCoverHero,
                child: _BleedArt(url: t?.artworkUrl),
              ),
            ),
            // Keeps the header readable on a bright cover.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: top + 150,
              child: const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xB3000000), Color(0x66000000), Color(0x00000000)],
                      stops: [0, 0.55, 1],
                    ),
                  ),
                ),
              ),
            ),
            content,
          ],
        );
      },
    );
  }
}

/// The cover, full width and square, cross-fading on a new song and fading out at its
/// lower edge into whatever sits behind it.
class _BleedArt extends StatefulWidget {
  const _BleedArt({this.url});
  final String? url;
  @override
  State<_BleedArt> createState() => _BleedArtState();
}

/// The cover drifts: a slow zoom and pan (Ken Burns), as Spotify's Canvas and Apple's animated
/// covers keep the player alive. Only while the station plays, so it also says "playing".
class _BleedArtState extends State<_BleedArt> with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(vsync: this, duration: const Duration(seconds: 28));
  late final RadioHandler _radio = context.read<RadioHandler>();

  @override
  void initState() {
    super.initState();
    _radio.wantPlaying.addListener(_sync);
    _sync();
  }

  void _sync() {
    if (_radio.wantPlaying.value) {
      if (!_drift.isAnimating) _drift.repeat(reverse: true);
    } else {
      _drift.stop();
    }
  }

  @override
  void dispose() {
    _radio.wantPlaying.removeListener(_sync);
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.url;
    // The clip sits outside the mask, and the fade is complete a little before the edge: the
    // drifting cover is larger than its box, and nothing it paints past the mask may show.
    return ClipRect(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.white, Color(0x00FFFFFF), Color(0x00FFFFFF)],
          stops: [0, 0.68, 0.97, 1],
        ).createShader(rect),
        child: LayoutBuilder(
          builder: (_, box) => AnimatedBuilder(
            animation: _drift,
            builder: (_, child) {
              final t = Curves.easeInOutSine.transform(_drift.value);
              final s = 1.0 + 0.1 * t;
              return OverflowBox(
                alignment: Alignment(-0.6 + 1.2 * t, -0.3 + 0.5 * t),
                minWidth: box.maxWidth * s,
                maxWidth: box.maxWidth * s,
                minHeight: box.maxHeight * s,
                maxHeight: box.maxHeight * s,
                child: child,
              );
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, children: [...previous, ?current]),
              child: url == null
                  ? const SizedBox.expand(key: ValueKey('none'))
                  : Artwork(url, key: ValueKey(url), radius: 0, fit: BoxFit.cover, iconSize: 56),
            ),
          ),
        ),
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
              icon: const Icon(AppIcons.warning, size: 20, color: Color(0xFFF5B73C)),
            );
          }
          return ValueListenableBuilder<int?>(
            valueListenable: radio.aacKbps,
            builder: (_, kbps, _) =>
                QualityPill(lossless: lossless, label: lossless || kbps == null ? null : 'AAC $kbps'),
          );
        },
      ),
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
  const _LyricsCard({required this.lyrics, required this.color, required this.onExpand, required this.onShare});
  final Lyrics lyrics;
  final Color color;
  final VoidCallback onExpand, onShare;

  @override
  Widget build(BuildContext context) {
    final fg = LyricsPalette.on(color).sung;
    Widget round(IconData icon, String tip, VoidCallback onTap) => IconButton(
      tooltip: tip,
      onPressed: onTap,
      style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha: 0.22), fixedSize: const Size(40, 40)),
      icon: Icon(icon, size: 20, color: fg),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Pressable(
        scale: 0.98,
        onTap: onExpand,
        child: Container(
          height: 360,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(Radii.lg)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l.lyrics,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: fg),
                      ),
                    ),
                    round(AppIcons.share, context.l.share, onShare),
                    const SizedBox(width: 8),
                    round(AppIcons.expand, context.l.showLyrics, onExpand),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LyricsView(
                    lyrics: lyrics,
                    background: color,
                    fontSize: 24,
                    interactive: false,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                  ),
                ),
              ),
            ],
          ),
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
              return Pressable(
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
