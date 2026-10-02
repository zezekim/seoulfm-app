import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/ui/widgets/stations_editor.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/data/app_language.dart';
import 'package:seoulfm/data/channels.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/state/cover_colors.dart';
import 'package:seoulfm/state/now_playing_controller.dart';
import 'package:seoulfm/state/saved_songs.dart';
import 'package:seoulfm/state/stations_now_playing.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/screens/your_songs_screen.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/notices.dart';
import 'package:seoulfm/ui/widgets/support_card.dart';

/// The home tab is the stations' shop window: a greeting, the featured stations as large
/// cards, the listener's saved songs, then every other station as a genre tile. Each shows what it is playing right now.
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
                const SliverToBoxAdapter(child: _YourStations()),
                SliverToBoxAdapter(child: ShelfTitle(context.l.featuredStations)),
                SliverToBoxAdapter(child: _FeaturedCarousel(channels: featured)),
                const SliverToBoxAdapter(child: _YourSongs()),
                if (rest.isNotEmpty) ...[
                  if (Config.supportEnabled) const SliverToBoxAdapter(child: SupportCard()),
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
                // Clear of the floating player and the tab bar, which the page runs under.
                SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 24)),
              ],
            ),
            // Keeps the clock readable over whatever scrolls under it.
            PositionedDirectional(
              top: 0,
              start: 0,
              end: 0,
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
  final station = context.watch<StationsNowPlaying>().byStation[ch.key]?.current;
  if (!tuned) return station;
  final heard = context.watch<NowPlayingController>();
  // Until the live feed's first answer (a second or so at launch), the station's last known song.
  return heard.station == null ? station : heard.track;
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
      padding: EdgeInsetsDirectional.fromSTEB(16, MediaQuery.paddingOf(context).top + 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const Spacer(),
              // Support, always a tap away (when it's on).
              if (Config.supportEnabled) IconButton(
                tooltip: context.l.support,
                onPressed: Nav.openSupport,
                style: IconButton.styleFrom(backgroundColor: c.text.withValues(alpha: 0.08)),
                icon: Icon(AppIcons.support, size: 20, color: c.text),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
          padding: EdgeInsetsDirectional.only(start: i == 0 ? 16 : 6, end: i == widget.channels.length - 1 ? 16 : 6),
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
    // The fade takes the colour of the cover on air (the station's while that is read).
    final shade = Color.lerp(context.watch<CoverColors>().of(t?.artworkUrl) ?? channel.color, Colors.black, 0.45)!;
    const white = Colors.white;

    return Semantics(
      button: true,
      selected: tuned,
      label: 'SeoulFM ${channel.name}. ${channel.localTagline}',
      child: Pressable(
        scale: 0.97,
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
              PositionedDirectional(
                top: 14,
                start: 14,
                end: 14,
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
              PositionedDirectional(
                start: 18,
                end: 14,
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
                      channel.localTagline,
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
    if (channel.lossless && !channel.comingSoon) {
      return QualityPill(lossless: true, label: (channel.localGenre ?? 'Lossless · FLAC').toUpperCase());
    }
    final label = channel.comingSoon ? context.l.comingSoon : (channel.localGenre ?? context.l.live);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (channel.onAir) ...[LiveDot(color: channel.color, size: 6), const SizedBox(width: 6)],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: tracking(1.6),
              color: Colors.white,
            ),
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
            letterSpacing: tracking(1.8),
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
    // The colour of the cover on air (as Spotify's browse tiles take theirs), the station's
    // while that is read.
    final tint = context.watch<CoverColors>().of(t?.artworkUrl) ?? channel.color;
    final fill = forWhiteText(Color.lerp(tint, Colors.black, 0.18)!);
    const white = Colors.white;

    return Semantics(
      button: true,
      selected: tuned,
      label: isolate('SeoulFM ${channel.rawName}'),
      child: Opacity(
        opacity: channel.tunable ? 1 : 0.5,
        child: Pressable(
          onTap: channel.tunable ? () => _listen(context, channel) : null,
          child: AnimatedContainer(
            duration: Motion.slow,
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
                    PositionedDirectional(
                      end: -14,
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
                  PositionedDirectional(
                    top: 12,
                    start: 12,
                    end: 36,
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
                          channel.comingSoon ? context.l.comingSoon : (channel.localGenre ?? ''),
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
                    PositionedDirectional(
                      top: 12,
                      end: 12,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: radio.wantPlaying,
                        builder: (_, p, _) => p ? const EqBars(height: 12) : const SizedBox.shrink(),
                      ),
                    ),
                  if (t != null)
                    PositionedDirectional(
                      start: 12,
                      end: 72,
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

// ── Your stations ─────────────────────────────────────────────────────────

/// The listener's own stations, as round covers of what each plays: one tap to listen. Edit
/// (or the + at the end) opens the editor; with none picked, an invitation to pick some.
class _YourStations extends StatelessWidget {
  const _YourStations();
  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return ValueListenableBuilder<List<String>>(
      valueListenable: app.favourites,
      builder: (context, keys, _) {
        final cc = context.watch<ChannelController>();
        final picked = [for (final k in keys) ?cc.byKey(k)].where((c) => c.tunable).toList();
        final title = ShelfTitle(
          context.l.yourStations,
          trailing: picked.isEmpty
              ? null
              : TextButton(onPressed: () => showStationsEditor(context), child: Text(context.l.edit)),
        );
        if (picked.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, _PickStations(onTap: () => showStationsEditor(context))],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: picked.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, i) => i < picked.length
                    ? _StationBubble(channel: picked[i])
                    : _AddBubble(onTap: () => showStationsEditor(context)),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The + at the end of Your stations: opens the editor.
class _AddBubble extends StatelessWidget {
  const _AddBubble({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return Pressable(
      onTap: onTap,
      semanticLabel: context.l.addStations,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.text.withValues(alpha: 0.08)),
              child: Icon(AppIcons.add, size: 28, color: c.text),
            ),
            const SizedBox(height: 6),
            Text(
              context.l.addStations,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Your stations with none picked: an invitation, not an empty row.
class _PickStations extends StatelessWidget {
  const _PickStations({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Pressable(
        onTap: onTap,
        semanticLabel: context.l.pickStationsTitle,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.border),
            borderRadius: BorderRadius.circular(Radii.lg),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(shape: BoxShape.circle, color: c.text.withValues(alpha: 0.08)),
                child: Icon(AppIcons.add, color: c.text),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l.pickStationsTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(context.l.pickStationsBody, style: TextStyle(color: c.muted, fontSize: 13)),
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

class _StationBubble extends StatelessWidget {
  const _StationBubble({required this.channel});
  final Channel channel;
  @override
  Widget build(BuildContext context) {
    final t = _onAir(context, channel);
    final tuned = context.watch<ChannelController>().active.key == channel.key;
    final ring = forWhiteText(context.watch<CoverColors>().of(t?.artworkUrl) ?? channel.color, ratio: 3);
    final radio = context.read<RadioHandler>();
    return Semantics(
      button: true,
      selected: tuned,
      label: isolate('SeoulFM ${channel.rawName}'),
      child: Pressable(
        onTap: () => _listen(context, channel),
        child: SizedBox(
          width: 76,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ring, width: 2.5),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipOval(child: Artwork(t?.artworkUrl, size: 64, radius: 0)),
                    if (tuned)
                      ValueListenableBuilder<bool>(
                        valueListenable: radio.wantPlaying,
                        builder: (_, p, _) => p
                            ? Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(color: Color(0x73000000), shape: BoxShape.circle),
                                child: const Center(child: EqBars(height: 16)),
                              )
                            : const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                channel.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Your songs ────────────────────────────────────────────────────────────

/// The newest saved songs as a shelf of covers; See all opens the list. Hidden until one is saved.
class _YourSongs extends StatelessWidget {
  const _YourSongs();

  static const _shown = 20;

  @override
  Widget build(BuildContext context) {
    final songs = context.watch<SavedSongs>().songs;
    if (songs.isEmpty) return const SizedBox.shrink();
    final c = context.sfm;
    final shown = songs.take(_shown).map((s) => s.track).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShelfTitle(
          context.l.yourSongs,
          trailing: TextButton(
            onPressed: () => Nav.push(const YourSongsScreen()),
            style: TextButton.styleFrom(foregroundColor: c.muted),
            child: Text(context.l.seeAll, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        SizedBox(
          // The cover plus two lines of text, which grow with the system text size.
          height: 146 + MediaQuery.textScalerOf(context).scale(40),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: shown.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final t = shown[i];
              return Pressable(
                semanticLabel: '${t.displayTitle}, ${t.displayArtist}',
                // A live-feed song without an id has no page: its menu instead.
                onTap: t.id == null ? () => showTrackActions(context, t) : () => Nav.openSong(t),
                onLongPress: () {
                  HapticFeedback.mediumImpact();
                  showTrackActions(context, t);
                },
                child: SizedBox(
                  width: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Artwork(t.artworkUrl, size: 140, radius: Radii.md, iconSize: 32),
                      const SizedBox(height: 6),
                      Text(
                        t.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(
                        t.displayArtist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: c.muted, fontSize: 12),
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
