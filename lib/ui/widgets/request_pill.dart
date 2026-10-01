import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/state/request_tracker.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/widgets/common.dart';

/// The listener's request on its way, floating above the player bar: its cover, and "plays in
/// ~6 min", then "up next", then "playing now". Slides away once it has played.
class RequestPill extends StatelessWidget {
  const RequestPill({super.key});

  @override
  Widget build(BuildContext context) {
    final tracker = context.read<RequestTracker>();
    return ValueListenableBuilder<RequestStatus?>(
      valueListenable: tracker.current,
      builder: (context, s, _) => AnimatedSize(
        duration: Motion.slow,
        curve: Motion.out,
        alignment: Alignment.bottomCenter,
        child: AnimatedSwitcher(
          duration: Motion.base,
          child: s == null ? const SizedBox(width: double.infinity) : _Pill(key: ValueKey('${s.requestId}-${s.status}'), status: s),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({super.key, required this.status});
  final RequestStatus status;

  String _text(BuildContext context) {
    final l = context.l;
    final eta = status.eta;
    if (status.status == 'playing') return l.requestTrackerPlaying;
    if (eta.position == 1 || (eta.etaMinutes != null && eta.etaMinutes! <= 1)) return l.requestTrackerNext;
    if (eta.etaMinutes != null) return l.requestTrackerEta(eta.etaMinutes!);
    return l.requestTrackerQueued;
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    final fg = readableOn(accent);
    final playing = status.status == 'playing';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Pressable(
        onTap: () => Nav.openSong(status.track),
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(99),
            boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 14, offset: Offset(0, 4))],
          ),
          child: Row(
            children: [
              ClipOval(child: Artwork(status.track.artworkUrl, size: 30, radius: 0)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${_text(context)} — ${status.track.displayTitle}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fg),
                ),
              ),
              const SizedBox(width: 8),
              playing ? EqBars(color: fg, height: 12) : Icon(AppIcons.request, size: 16, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}
