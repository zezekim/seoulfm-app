import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/state/now_playing_controller.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/now_playing_sheet.dart';

/// The player bar above the tabs (`PlayerBar` on phones): glass, the heard song, its
/// progress as a hairline in the accent, play. Tap the song for the Now Playing sheet.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    final np = context.watch<NowPlayingController>();
    final channel = context.watch<ChannelController>().active;
    final radio = context.read<RadioHandler>();
    final t = np.track;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: (dark ? const Color(0xFF09090B) : Colors.white).withValues(alpha: dark ? 0.82 : 0.84),
            border: Border(top: BorderSide(color: c.text.withValues(alpha: 0.06))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Hairline(color: channel.color),
              InkWell(
                onTap: () => showNowPlaying(context),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'mini-art',
                        child: Artwork(t?.artworkUrl, size: 44, radius: Radii.sm),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (channel.onAir) ...[LiveDot(color: channel.color, size: 5), const SizedBox(width: 6)],
                                Flexible(
                                  child: Text(
                                    t?.displayTitle ?? 'SeoulFM ${channel.name}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t == null ? channel.tagline : '${t.displayArtist} · ${channel.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: c.muted),
                            ),
                          ],
                        ),
                      ),
                      RatingButtons(trackId: t?.id, size: 20),
                      ValueListenableBuilder<bool>(
                        valueListenable: radio.wantPlaying,
                        builder: (_, playing, _) => ValueListenableBuilder<bool>(
                          valueListenable: radio.buffering,
                          builder: (_, buffering, _) =>
                              PlayButton(playing: playing, buffering: buffering, onPressed: radio.toggle, size: 42),
                        ),
                      ),
                    ],
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

class _Hairline extends StatefulWidget {
  const _Hairline({required this.color});
  final Color color;
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
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: f,
        child: Container(height: 2, color: widget.color),
      ),
    );
  }
}
