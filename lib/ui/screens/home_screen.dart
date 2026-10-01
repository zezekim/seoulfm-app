import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/data/channels.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/state/now_playing_controller.dart';
import 'package:seoulfm/state/runtime_config.dart';
import 'package:seoulfm/state/stations_now_playing.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/share.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/marathon_panel.dart';
import 'package:seoulfm/ui/widgets/now_playing_sheet.dart';
import 'package:seoulfm/ui/widgets/request_sheet.dart';

/// The homepage on a phone: the full-bleed hero of what is on air, the channel chips,
/// Up Next, the station tiles, then the request grid (Marathon: the vote) and history.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final channel = context.watch<ChannelController>().active;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async => context.read<ChannelController>().select(channel.key),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: _Hero()),
              const SliverToBoxAdapter(child: _Notices()),
              const SliverToBoxAdapter(child: _UpNext()),
              const SliverToBoxAdapter(child: _StationTiles()),
              if (channel.marathon)
                const SliverToBoxAdapter(child: MarathonPanel())
              else
                SliverToBoxAdapter(child: _RequestGrid(key: ValueKey(channel.key))),
              const SliverToBoxAdapter(child: _Recent()),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final np = context.watch<NowPlayingController>();
    final channel = context.watch<ChannelController>().active;
    final radio = context.read<RadioHandler>();
    final t = np.track;
    final offAir = np.station?.onAir == false || !channel.onAir;
    final height = MediaQuery.sizeOf(context).height * 0.72;
    final top = MediaQuery.paddingOf(context).top;
    final bg = context.sfm.bg;
    const white = Colors.white;

    return SizedBox(
      height: height,
      child: GestureDetector(
        // Swipe the hero sideways to change station.
        onHorizontalDragEnd: (d) {
          final v = d.primaryVelocity ?? 0;
          if (v.abs() < 300) return;
          final next = context.read<ChannelController>().step(v < 0 ? 1 : -1);
          context.read<AppState>().tuneIn(next.key, play: radio.wantPlaying.value);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              layoutBuilder: _fill,
              child: t?.artworkUrl != null
                  ? Artwork(t!.artworkUrl, key: ValueKey(t.artworkUrl), radius: 0, fit: BoxFit.cover)
                  : Container(key: const ValueKey('none'), color: context.sfm.surface2),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF09090B).withValues(alpha: 0.35),
                    const Color(0xFF09090B).withValues(alpha: 0.05),
                    const Color(0xFF09090B).withValues(alpha: 0.75),
                    bg,
                  ],
                  stops: const [0, 0.3, 0.62, 1],
                ),
              ),
            ),
            // Brand, live badge and channel.
            Positioned(
              top: top + 12,
              left: 20,
              right: 12,
              child: Row(
                children: [
                  // The wordmark: "seoul" heavy, "fm" light.
                  Semantics(
                    label: 'SeoulFM',
                    child: const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'seoul',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: 'fm',
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                      style: TextStyle(color: white, fontSize: 21, letterSpacing: -0.6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (offAir)
                    _Badge(
                      dot: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: white.withValues(alpha: 0.4), shape: BoxShape.circle),
                      ),
                      text: context.l.offAir.toUpperCase(),
                      color: white.withValues(alpha: 0.6),
                    )
                  else
                    _Badge(
                      dot: LiveDot(color: channel.color),
                      text: context.l.live,
                      color: channel.color,
                    ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      channel.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 2, color: white.withValues(alpha: 0.7)),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: context.l.share,
                    onPressed: () => shareStation(context, channel),
                    icon: Icon(Icons.ios_share_rounded, color: white.withValues(alpha: 0.8), size: 20),
                  ),
                ],
              ),
            ),
            // What is on air.
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AnimatedSwitcher(
                      duration: Motion.slow,
                      switchInCurve: Motion.out,
                      transitionBuilder: (child, a) => FadeTransition(
                        opacity: a,
                        child: SlideTransition(
                          position: Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(a),
                          child: child,
                        ),
                      ),
                      child: t != null
                          ? _NowOnAir(key: ValueKey(t.id), track: t)
                          : offAir
                          ? Column(
                              key: const ValueKey('off'),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l.offAir,
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: white.withValues(alpha: 0.85)),
                                ),
                                Text(context.l.stationBreak, style: TextStyle(fontSize: 12, color: white.withValues(alpha: 0.5))),
                              ],
                            )
                          : Column(
                              key: const ValueKey('tagline'),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SeoulFM ${channel.name}',
                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: white, letterSpacing: -0.5),
                                ),
                                Text(channel.tagline, style: TextStyle(fontSize: 13, color: white.withValues(alpha: 0.6))),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _ChannelChips(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cross-fades that fill their box (the default switcher only centres its children).
Widget _fill(Widget? current, List<Widget> previous) => Stack(fit: StackFit.expand, children: [...previous, ?current]);

class _Badge extends StatelessWidget {
  const _Badge({required this.dot, required this.text, required this.color});
  final Widget dot;
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      dot,
      const SizedBox(width: 6),
      Text(
        text,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 2, color: color),
      ),
    ],
  );
}

class _NowOnAir extends StatelessWidget {
  const _NowOnAir({super.key, required this.track});
  final Track track;

  @override
  Widget build(BuildContext context) {
    final radio = context.read<RadioHandler>();
    final channel = context.read<ChannelController>().active;
    const white = Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => showNowPlaying(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          context.l.nowPlaying.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.2,
                            color: white.withValues(alpha: 0.55),
                          ),
                        ),
                        const SizedBox(width: 8),
                        HotChip(trackId: track.id),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track.displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: white, height: 1.1, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track.displayArtist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: white.withValues(alpha: 0.6)),
                    ),
                    if (track.dedication?.name != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          context.l.dedicatedBy(track.dedication!.name!),
                          style: TextStyle(fontSize: 10, color: white.withValues(alpha: 0.5)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            RatingButtons(trackId: track.id, onImage: true),
            ValueListenableBuilder<bool>(
              valueListenable: radio.wantPlaying,
              builder: (_, playing, _) => ValueListenableBuilder<bool>(
                valueListenable: radio.buffering,
                builder: (_, buffering, _) => PlayButton(
                  playing: playing,
                  buffering: buffering,
                  onImage: true,
                  onPressed: () => playing ? radio.pause() : context.read<AppState>().tuneIn(channel.key, play: true),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _HeroProgress(color: channel.color, durationMs: track.durationMs),
      ],
    );
  }
}

class _HeroProgress extends StatefulWidget {
  const _HeroProgress({required this.color, this.durationMs});
  final Color color;
  final int? durationMs;
  @override
  State<_HeroProgress> createState() => _HeroProgressState();
}

class _HeroProgressState extends State<_HeroProgress> {
  late final Timer _t = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.read<NowPlayingController>().positionMs() ?? 0;
    final dur = widget.durationMs ?? 0;
    final style = TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6), fontFeatures: tabular);
    return Row(
      children: [
        Text(fmtDuration(pos), style: style),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: dur > 0 ? (pos / dur).clamp(0.0, 1.0) : 0,
              minHeight: 2,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(widget.color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(dur > 0 ? fmtDuration(dur) : '', style: style),
      ],
    );
  }
}

class _ChannelChips extends StatelessWidget {
  const _ChannelChips();
  @override
  Widget build(BuildContext context) {
    final cc = context.watch<ChannelController>();
    final radio = context.read<RadioHandler>();
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: cc.channels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final ch = cc.channels[i];
          final selected = ch.key == cc.active.key;
          return Opacity(
            opacity: ch.tunable ? 1 : 0.45,
            child: Pill(
              label: ch.name,
              selected: selected,
              color: ch.color,
              onTap: ch.tunable ? () => context.read<AppState>().tuneIn(ch.key, play: radio.wantPlaying.value) : null,
            ),
          );
        },
      ),
    );
  }
}

// ── Notices from the control plane ───────────────────────────────────────

class _Notices extends StatelessWidget {
  const _Notices();
  @override
  Widget build(BuildContext context) {
    final cfg = context.watch<RuntimeConfigController>().config;
    final radio = context.read<RadioHandler>();
    final items = <Widget>[];
    // Operator text is plain text, rendered as is.
    if (cfg.maintenance && (cfg.maintenanceMessage ?? cfg.maintenanceTitle) != null) {
      items.add(_NoticeCard(text: cfg.maintenanceMessage ?? cfg.maintenanceTitle!, level: 'warning', title: cfg.maintenanceTitle));
    }
    if (!cfg.streamAvailable || cfg.streamNotice != null) {
      items.add(_NoticeCard(text: cfg.streamNotice ?? context.l.offline, level: 'warning'));
    }
    if (cfg.announcement != null) items.add(_NoticeCard(text: cfg.announcement!, level: cfg.announcementLevel));
    return ValueListenableBuilder<bool>(
      valueListenable: radio.losslessFailed,
      builder: (_, failed, _) => Column(
        children: [
          ...items,
          if (failed)
            _NoticeCard(
              text: context.l.losslessFailed,
              level: 'warning',
              action: TextButton(onPressed: radio.retryLossless, child: Text(context.l.retryFlac)),
            ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.text, required this.level, this.title, this.action});
  final String text, level;
  final String? title;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      'success' => const Color(0xFF2FB38F),
      'warning' => const Color(0xFFF5B73C),
      'danger' => const Color(0xFFFF5A5F),
      _ => const Color(0xFF3C9DF5),
    };
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) Text(title!, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(text, style: const TextStyle(fontSize: 13, height: 1.35)),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

// ── Up next ───────────────────────────────────────────────────────────────

class _UpNext extends StatelessWidget {
  const _UpNext();
  @override
  Widget build(BuildContext context) {
    final upcoming = context.watch<NowPlayingController>().upcoming;
    if (upcoming.isEmpty) return const SizedBox.shrink();
    final c = context.sfm;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(context.l.upNext, icon: Icons.schedule_rounded),
        SizedBox(
          height: 118,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: upcoming.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final t = upcoming[i];
              final mins = t.startsAtEpoch != null ? ((t.startsAtEpoch! - now) / 60).ceil() : null;
              return GestureDetector(
                onTap: () => Nav.openSong(t),
                child: SizedBox(
                  width: 76,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Artwork(t.artworkUrl, radius: Radii.sm),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 26,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0x8C000000),
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(Radii.sm)),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Row(
                                  children: [
                                    Text(
                                      '${i + 1}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70),
                                    ),
                                    const Spacer(),
                                    if (mins != null && mins > 0)
                                      Text(
                                        context.l.inMinutes(mins),
                                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.white70),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (t.isRequest)
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    context.l.requestBadge,
                                    style: TextStyle(
                                      fontSize: 7,
                                      fontWeight: FontWeight.w800,
                                      color: readableOn(Theme.of(context).colorScheme.secondary),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: c.text.withValues(alpha: 0.75)),
                      ),
                      Text(
                        t.displayArtist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: c.muted),
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

// ── Station tiles ─────────────────────────────────────────────────────────

/// Small square tiles, each with the artwork of what that station plays (`ChannelRail`).
class _StationTiles extends StatelessWidget {
  const _StationTiles();
  @override
  Widget build(BuildContext context) {
    final cc = context.watch<ChannelController>();
    final others = context.watch<StationsNowPlaying>().byStation;
    final heard = context.watch<NowPlayingController>().track;
    final radio = context.read<RadioHandler>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(context.l.stations, icon: Icons.radio_rounded),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, box) {
              final cols = box.maxWidth >= 560 ? 6 : 4;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: cc.channels.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: 8, crossAxisSpacing: 8),
                itemBuilder: (context, i) {
                  final ch = cc.channels[i];
                  final tuned = ch.key == cc.active.key;
                  final art = tuned ? heard?.artworkUrl : others[ch.key]?.current?.artworkUrl;
                  return _Tile(
                    channel: ch,
                    art: art,
                    tuned: tuned,
                    onTap: ch.tunable ? () => context.read<AppState>().tuneIn(ch.key, play: true) : null,
                    playing: radio.wantPlaying,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.channel, required this.art, required this.tuned, required this.onTap, required this.playing});
  final Channel channel;
  final String? art;
  final bool tuned;
  final VoidCallback? onTap;
  final ValueListenable<bool> playing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: tuned,
      label: 'SeoulFM ${channel.name}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Motion.base,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: tuned ? channel.color : Colors.transparent, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Radii.md - 2),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (art != null) Artwork(art, radius: 0) else ColoredBox(color: channel.color.withValues(alpha: 0.25)),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withValues(alpha: 0.05), Colors.black.withValues(alpha: 0.75)],
                    ),
                  ),
                ),
                Positioned(
                  left: 6,
                  right: 6,
                  bottom: 6,
                  child: Text(
                    channel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: channel.comingSoon
                      ? Text(
                          context.l.comingSoon.toUpperCase(),
                          style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w800, color: Colors.white70),
                        )
                      : Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: channel.color, shape: BoxShape.circle),
                        ),
                ),
                if (tuned)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: playing,
                      builder: (_, p, _) => p ? const EqBars(height: 10) : const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Request grid ──────────────────────────────────────────────────────────

/// Covers to request from (`RequestGrid`): random songs from the station's library,
/// spread so the same artist never sits close together.
class _RequestGrid extends StatefulWidget {
  const _RequestGrid({super.key});
  @override
  State<_RequestGrid> createState() => _RequestGridState();
}

class _RequestGridState extends State<_RequestGrid> {
  late Future<List<Track>> _f = _load();

  Future<List<Track>> _load() async => spreadByArtist((await api.random(limit: 24)).where((t) => t.requestable != false).toList());

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          context.l.requestASong,
          icon: Icons.music_note_rounded,
          trailing: IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => setState(() => _f = _load()),
            icon: Icon(Icons.shuffle_rounded, size: 18, color: c.muted),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(context.l.requestHint, style: TextStyle(fontSize: 12, color: c.muted)),
        ),
        FutureBuilder<List<Track>>(
          future: _f,
          builder: (context, s) {
            if (s.hasError) return ErrorRetry(onRetry: () => setState(() => _f = _load()));
            final items = s.data;
            if (items == null) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, i) {
                final t = items[i];
                return GestureDetector(
                  onTap: () => showRequestSheet(context, t),
                  onLongPress: () => Nav.openSong(t),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(aspectRatio: 1, child: Artwork(t.artworkUrl, radius: Radii.md)),
                      const SizedBox(height: 6),
                      Text(
                        t.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        t.displayArtist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: c.muted),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

/// Same-artist tracks at least three apart (`spreadByArtist` in RequestGrid.tsx).
List<Track> spreadByArtist(List<Track> input, {int gap = 3}) {
  final pool = [...input];
  final out = <Track>[];
  while (pool.isNotEmpty) {
    final recent = out.reversed.take(gap).map((t) => t.artist).toSet();
    final i = pool.indexWhere((t) => !recent.contains(t.artist));
    out.add(pool.removeAt(i < 0 ? 0 : i));
  }
  return out;
}

// ── Recently played ───────────────────────────────────────────────────────

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
        SectionHeader(context.l.recentlyPlayed, icon: Icons.history_rounded),
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
