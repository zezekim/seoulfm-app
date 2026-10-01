import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/state/cover_colors.dart';
import 'package:seoulfm/state/now_playing_controller.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/widgets/common.dart';

/// Hero tag shared by the player bar's cover and the full-screen player's, so the cover grows
/// from one into the other.
const playerCoverHero = 'player-cover';

/// The player bar floating above the tabs (Spotify's, iOS 26's): a rounded card tinted from the
/// cover, the heard song, play, and its progress as a hairline along the bottom. Tap it for
/// the full-screen player, where the thumbs are.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final np = context.watch<NowPlayingController>();
    final channel = context.watch<ChannelController>().active;
    final radio = context.read<RadioHandler>();
    final t = np.track;
    final tint = context.watch<CoverColors>().of(t?.artworkUrl) ?? channel.color;
    final bg = Color.lerp(tint, Colors.black, 0.5)!;
    const white = Colors.white;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      child: Pressable(
        scale: 0.98,
        onTap: () => Nav.showNowPlaying(context),
        child: AnimatedContainer(
          duration: Motion.slow,
          curve: Motion.out,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(Radii.md),
            boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 6))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 4, 10),
                child: Row(
                  children: [
                    Hero(
                      tag: playerCoverHero,
                      child: Artwork(t?.artworkUrl, size: 42, radius: 6),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t?.displayTitle ?? 'SeoulFM ${channel.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: white),
                          ),
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              ValueListenableBuilder<bool>(
                                valueListenable: radio.losslessActive,
                                builder: (_, lossless, _) => lossless
                                    ? const Padding(
                                        padding: EdgeInsets.only(right: 6),
                                        child: QualityPill(lossless: true, compact: true),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              if (channel.onAir) ...[LiveDot(color: white, size: 5), const SizedBox(width: 5)],
                              Flexible(
                                child: Text(
                                  t == null ? channel.tagline : '${t.displayArtist} · ${channel.name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12.5, color: white.withValues(alpha: 0.7)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: radio.wantPlaying,
                      builder: (_, playing, _) => ValueListenableBuilder<bool>(
                        valueListenable: radio.buffering,
                        builder: (_, buffering, _) => _BarPlay(playing: playing, buffering: buffering, onPressed: radio.toggle),
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(left: 10, right: 10, bottom: 0, child: _Hairline()),
            ],
          ),
        ),
      ),
    );
  }
}

/// A bare play/pause glyph, as the bar has it (the round button belongs to the full player).
class _BarPlay extends StatelessWidget {
  const _BarPlay({required this.playing, required this.buffering, required this.onPressed});
  final bool playing, buffering;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: playing ? context.l.pause : context.l.play,
      child: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        icon: Stack(
          alignment: Alignment.center,
          children: [
            if (buffering)
              const SizedBox(width: 34, height: 34, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54)),
            AnimatedSwitcher(
              duration: Motion.fast,
              child: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                key: ValueKey(playing),
                size: 32,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hairline extends StatefulWidget {
  const _Hairline();
  @override
  State<_Hairline> createState() => _HairlineState();
}

class _HairlineState extends State<_Hairline> {
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
    final dur = np.track?.durationMs ?? 0;
    final f = dur > 0 ? ((np.positionMs() ?? 0) / dur).clamp(0.0, 1.0) : 0.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Stack(
        children: [
          Container(height: 2, color: Colors.white.withValues(alpha: 0.2)),
          FractionallySizedBox(
            widthFactor: f,
            child: Container(height: 2, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
