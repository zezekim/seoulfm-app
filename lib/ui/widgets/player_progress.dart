import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/state/now_playing_controller.dart';
import 'package:seoulfm/ui/widgets/common.dart';

/// Elapsed and −remaining on the listener's own clock (`positionMs`), ticking each second.
/// Drawn in [color] (white on artwork and on the lyrics colour).
class PlayerProgress extends StatefulWidget {
  const PlayerProgress({super.key, this.color = Colors.white, this.center});
  final Color color;

  /// Shown between the elapsed and remaining times (Apple Music puts its Dolby Atmos badge there).
  final Widget? center;
  @override
  State<PlayerProgress> createState() => _PlayerProgressState();
}

class _PlayerProgressState extends State<PlayerProgress> {
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
    final c = widget.color;
    final style = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: c.withValues(alpha: 0.6), fontFeatures: tabular);
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: LinearProgressIndicator(
            value: f,
            minHeight: 4,
            backgroundColor: c.withValues(alpha: 0.25),
            valueColor: AlwaysStoppedAnimation(c.withValues(alpha: 0.9)),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: Text(fmtDuration(pos), style: style)),
            ?widget.center,
            Expanded(
              child: Text(dur > 0 ? '−${fmtDuration(dur - pos)}' : '', style: style, textAlign: TextAlign.end),
            ),
          ],
        ),
      ],
    );
  }
}
