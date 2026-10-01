import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/data/channels.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/state/now_playing_controller.dart';
import 'package:seoulfm/state/stations_now_playing.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/notices.dart';

/// The home tab is the stations' shop window: a greeting, the featured stations as large
/// cards, then every other station as a genre tile. Each shows what it is playing right now.
/// Tapping a station tunes and plays it; tapping the one already playing opens the player.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// The first four in the registry (Pop!, HIFI, Fresh K-Pop!, Marathon) are featured;
  /// the registry's order is the site's, so that is where to change it.
  static const _featuredCount = 4;

  @override
  Widget build(BuildContext context) {
    final channels = context.watch<ChannelController>().channels;
    final featured = channels.take(_featuredCount).toList();
    final rest = channels.skip(_featuredCount).toList();
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: _Header()),
                const SliverToBoxAdapter(child: Notices()),
                SliverToBoxAdapter(child: ShelfTitle(context.l.featuredStations)),
                SliverToBoxAdapter(child: _FeaturedCarousel(channels: featured)),
                if (rest.isNotEmpty) ...[
                  SliverToBoxAdapter(child: ShelfTitle(context.l.genresAndEras)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 240,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.45,
                      ),
                      itemCount: rest.length,
                      itemBuilder: (_, i) => _GenreTile(channel: rest[i]),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
            // Keeps the clock readable over whatever scrolls under it.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.paddingOf(context).top + 8,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [context.sfm.bg, context.sfm.bg.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// What a station is playing: the heard track for the tuned one, station time for the rest.
Track? _onAir(BuildContext context, Channel ch) {
  final tuned = context.watch<ChannelController>().active.key == ch.key;
  if (tuned) return context.watch<NowPlayingController>().track;
  return context.watch<StationsNowPlaying>().byStation[ch.key]?.current;
}

/// Tune and play; on the station already playing, open the player instead.
void _listen(BuildContext context, Channel ch) {
  if (!ch.tunable) return;
  final radio = context.read<RadioHandler>();
  if (context.read<ChannelController>().active.key == ch.key && radio.wantPlaying.value) {
    Nav.showNowPlaying(context);
    return;
  }
  context.read<AppState>().tuneIn(ch.key, play: true);
}

// ── Header ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  String _greeting(BuildContext context) {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return context.l.goodMorning;
    if (h >= 12 && h < 18) return context.l.goodAfternoon;
    return context.l.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The wordmark: "seoul" heavy, "fm" light.
          Semantics(
            label: 'SeoulFM',
            child: Text.rich(
              const TextSpan(
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
              style: TextStyle(color: c.text, fontSize: 19, letterSpacing: -0.6),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _greeting(context),
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -1, height: 1.1),
          ),
        ],
      ),
    );
  }
}

// ── Featured ──────────────────────────────────────────────────────────────

class _FeaturedCarousel extends StatefulWidget {
  const _FeaturedCarousel({required this.channels});
  final List<Channel> channels;
  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  final _page = PageController(viewportFraction: 0.86);

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // Square-ish cards on a phone, capped so a tablet doesn't get a wall of artwork.
    final height = min(width * 0.86 * 1.12, 460.0);
    return SizedBox(
      height: height,
      child: PageView.builder(
        controller: _page,
        padEnds: false,
        itemCount: widget.channels.length,
        itemBuilder: (_, i) => Padding(
          padding: EdgeInsets.only(left: i == 0 ? 16 : 6, right: i == widget.channels.length - 1 ? 16 : 6),
          child: _FeaturedCard(channel: widget.channels[i]),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.channel});
  final Channel channel;

  @override
  Widget build(BuildContext context) {
    final t = _onAir(context, channel);
    final tuned = context.watch<ChannelController>().active.key == channel.key;
    final radio = context.read<RadioHandler>();
    final shade = Color.lerp(channel.color, Colors.black, 0.6)!;
    const white = Colors.white;

    return Semantics(
      button: true,
      selected: tuned,
      label: 'SeoulFM ${channel.name}. ${channel.tagline}',
      child: GestureDetector(
        onTap: () => _listen(context, channel),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Radii.lg),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, children: [...previous, ?current]),
                child: t?.artworkUrl != null
                    ? Artwork(t!.artworkUrl, key: ValueKey(t.artworkUrl), radius: 0)
                    : ColoredBox(key: const ValueKey('none'), color: shade),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      Colors.transparent,
                      shade.withValues(alpha: 0.88),
                      shade,
                    ],
                    stops: const [0, 0.25, 0.62, 1],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: Row(
                  children: [
                    _Tag(channel: channel),
                    const Spacer(),
                    if (tuned)
                      ValueListenableBuilder<bool>(
                        valueListenable: radio.wantPlaying,
                        builder: (_, p, _) => p ? const EqBars(height: 14) : const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
              Positioned(
                left: 18,
                right: 14,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: white,
                        letterSpacing: -1,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      channel.tagline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, height: 1.35, color: white.withValues(alpha: 0.75)),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _OnAirLine(track: t, channel: channel),
                        ),
                        const SizedBox(width: 12),
                        ValueListenableBuilder<bool>(
                          valueListenable: radio.wantPlaying,
                          builder: (_, playing, _) => ValueListenableBuilder<bool>(
                            valueListenable: radio.buffering,
                            builder: (_, buffering, _) => PlayButton(
                              playing: tuned && playing,
                              buffering: tuned && buffering,
                              onImage: true,
                              size: 50,
                              onPressed: () => tuned && playing
                                  ? radio.pause()
                                  : context.read<AppState>().tuneIn(channel.key, play: true),
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
        ),
      ),
    );
  }
}

/// The live dot and the genre, or "Coming soon".
class _Tag extends StatelessWidget {
  const _Tag({required this.channel});
  final Channel channel;
  @override
  Widget build(BuildContext context) {
    final label = channel.comingSoon ? context.l.comingSoon : (channel.genre ?? context.l.live);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (channel.onAir) ...[LiveDot(color: channel.color, size: 6), const SizedBox(width: 6)],
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.6, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// "Song · Artist" under a station, or its off-air state.
class _OnAirLine extends StatelessWidget {
  const _OnAirLine({required this.track, required this.channel});
  final Track? track;
  final Channel channel;
  @override
  Widget build(BuildContext context) {
    final t = track;
    const white = Colors.white;
    if (t == null) {
      return Text(
        channel.onAir ? context.l.listenNow : context.l.offAir,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: white.withValues(alpha: 0.85)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l.nowPlaying.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.8,
            color: white.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          t.displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: white),
        ),
        Text(
          t.displayArtist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: white.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}

// ── Genre tiles ───────────────────────────────────────────────────────────

/// A browse tile: the station's colour, its name, and the cover of what it plays
/// tipped into the corner.
class _GenreTile extends StatelessWidget {
  const _GenreTile({required this.channel});
  final Channel channel;

  @override
  Widget build(BuildContext context) {
    final t = _onAir(context, channel);
    final tuned = context.watch<ChannelController>().active.key == channel.key;
    final radio = context.read<RadioHandler>();
    final fill = Color.lerp(channel.color, Colors.black, 0.3)!;
    const white = Colors.white;

    return Semantics(
      button: true,
      selected: tuned,
      label: 'SeoulFM ${channel.name}',
      child: Opacity(
        opacity: channel.tunable ? 1 : 0.5,
        child: GestureDetector(
          onTap: () => _listen(context, channel),
          child: AnimatedContainer(
            duration: Motion.base,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(color: tuned ? white : Colors.transparent, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radii.md - 2),
              child: Stack(
                children: [
                  if (t?.artworkUrl != null)
                    Positioned(
                      right: -14,
                      bottom: -8,
                      child: Transform.rotate(
                        angle: 0.42,
                        child: Container(
                          decoration: const BoxDecoration(
                            boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 4))],
                          ),
                          child: Artwork(t!.artworkUrl, size: 76, radius: 6),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 36,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          channel.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: white,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          channel.comingSoon ? context.l.comingSoon : (channel.genre ?? ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (tuned)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: radio.wantPlaying,
                        builder: (_, p, _) => p ? const EqBars(height: 12) : const SizedBox.shrink(),
                      ),
                    ),
                  if (t != null)
                    Positioned(
                      left: 12,
                      right: 72,
                      bottom: 10,
                      child: Text(
                        t.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
