import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/l10n/app_localizations.dart';
import 'package:seoulfm/state/ratings_controller.dart';
import 'package:seoulfm/theme.dart';

extension L10nX on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this);
}

String fmtDuration(int? ms) {
  if (ms == null || ms <= 0) return '0:00';
  final s = ms ~/ 1000;
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

String timeAgo(BuildContext context, int epochSeconds) {
  final mins = (DateTime.now().millisecondsSinceEpoch ~/ 1000 - epochSeconds) ~/ 60;
  if (mins < 1) return context.l.justNow;
  if (mins < 60) return context.l.minutesAgo(mins);
  return context.l.hoursAgo(mins ~/ 60);
}

const tabular = [FontFeature.tabularFigures()];

/// A cover that fades in once decoded; a radio glyph while there is none.
class Artwork extends StatelessWidget {
  const Artwork(this.url, {super.key, this.size, this.radius = Radii.sm, this.fit = BoxFit.cover, this.iconSize = 18});
  final String? url;
  final double? size;
  final double radius;
  final BoxFit fit;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    final placeholder = Container(
      color: c.text.withValues(alpha: 0.05),
      alignment: Alignment.center,
      child: Icon(Icons.radio_rounded, size: iconSize, color: c.faint),
    );
    final child = url == null
        ? placeholder
        : CachedNetworkImage(
            imageUrl: url!,
            fit: fit,
            fadeInDuration: Motion.base,
            fadeOutDuration: Duration.zero,
            placeholder: (_, _) => placeholder,
            errorWidget: (_, _, _) => placeholder,
          );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: size, height: size, child: child),
    );
  }
}

/// The on-air dot: the accent, breathing.
class LiveDot extends StatefulWidget {
  const LiveDot({super.key, this.color, this.size = 6});
  final Color? color;
  final double size;
  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.secondary;
    return FadeTransition(
      opacity: Tween(begin: 0.45, end: 1.0).animate(_c),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6)],
        ),
      ),
    );
  }
}

/// Four bouncing bars while the tuned station plays.
class EqBars extends StatefulWidget {
  const EqBars({super.key, this.color = Colors.white, this.height = 14, this.animate = true});
  final Color color;
  final double height;
  final bool animate;
  @override
  State<EqBars> createState() => _EqBarsState();
}

class _EqBarsState extends State<EqBars> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void initState() {
    super.initState();
    if (widget.animate) _c.repeat();
  }

  @override
  void didUpdateWidget(EqBars old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_c.isAnimating) _c.repeat();
    if (!widget.animate) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(4, (i) {
          final t = (_c.value + i * 0.23) % 1.0;
          final h = widget.animate ? 0.25 + 0.75 * (t < 0.5 ? t * 2 : (1 - t) * 2) : 0.3;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.2),
            width: 3,
            height: widget.height * h,
            decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(2)),
          );
        }),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.icon, this.trailing});
  final String title;
  final IconData? icon;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: c.muted), const SizedBox(width: 8)],
          Expanded(child: Text(title.toUpperCase(), style: eyebrow(context))),
          ?trailing,
        ],
      ),
    );
  }
}

/// A shelf's heading on the home and Now Playing tabs: a bold title, an optional line under it.
class ShelfTitle extends StatelessWidget {
  const ShelfTitle(this.title, {super.key, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 28, trailing == null ? 16 : 4, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!, style: TextStyle(fontSize: 13, color: c.muted)),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// The round play/pause button (`.play-btn`).
class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.playing,
    required this.onPressed,
    this.size = 52,
    this.buffering = false,
    this.onImage = false,
  });
  final bool playing, buffering, onImage;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    final bg = onImage ? Colors.white : c.solid;
    final fg = onImage ? const Color(0xFF09090B) : c.solidFg;
    return Semantics(
      button: true,
      label: playing ? context.l.pause : context.l.play,
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (buffering)
                  SizedBox(
                    width: size - 6,
                    height: size - 6,
                    child: CircularProgressIndicator(strokeWidth: 2, color: fg.withValues(alpha: 0.35)),
                  ),
                AnimatedSwitcher(
                  duration: Motion.fast,
                  child: Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    key: ValueKey(playing),
                    size: size * 0.5,
                    color: fg,
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

/// 🔥 Hot, when listeners made the track hot. Never counts.
class HotChip extends StatelessWidget {
  const HotChip({super.key, required this.trackId});
  final String? trackId;
  @override
  Widget build(BuildContext context) {
    final hot = context.select<RatingsController, bool>((r) => r.stateOf(trackId)?.hot ?? false);
    if (!hot) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: const Color(0x33FF7A1A), borderRadius: BorderRadius.circular(99)),
      child: Text(
        '🔥 ${context.l.hot}',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFFFA54D), letterSpacing: 0.3),
      ),
    );
  }
}

/// 👍 / 👎 on the heard track. Disabled until 25 s of listening on the station.
class RatingButtons extends StatelessWidget {
  const RatingButtons({super.key, required this.trackId, this.onImage = false, this.size = 22});
  final String? trackId;
  final bool onImage;
  final double size;

  @override
  Widget build(BuildContext context) {
    final r = context.watch<RatingsController>();
    if (r.hiddenFor(trackId)) return const SizedBox.shrink();
    final rating = r.stateOf(trackId)?.rating;
    final enabled = r.canRate;
    final base = onImage ? Colors.white : context.sfm.text;
    Widget btn(String value, IconData off, IconData on, String label) {
      final active = rating == value;
      return Tooltip(
        message: enabled ? label : context.l.startListeningToRate,
        child: IconButton(
          onPressed: enabled ? () => r.rate(trackId!, active ? null : value) : null,
          icon: Icon(active ? on : off, size: size),
          color: active ? base : base.withValues(alpha: 0.7),
          disabledColor: base.withValues(alpha: 0.28),
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn('up', Icons.thumb_up_alt_outlined, Icons.thumb_up_alt, context.l.like),
        btn('down', Icons.thumb_down_alt_outlined, Icons.thumb_down_alt, context.l.dislike),
      ],
    );
  }
}

/// A song in a list: cover, title, artist, and whatever goes at the end.
class TrackRow extends StatelessWidget {
  const TrackRow({super.key, required this.track, this.leading, this.trailing, this.subtitle, this.onTap});
  final Track track;
  final Widget? leading, trailing;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Artwork(track.artworkUrl, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle ?? track.displayArtist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: c.muted),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

/// Small pill buttons (`.chip`).
class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, this.selected = false, this.onTap, this.color, this.leading});
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? color;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    final accent = color ?? c.solid;
    return Material(
      color: selected ? accent : c.text.withValues(alpha: 0.06),
      shape: StadiumBorder(side: BorderSide(color: selected ? accent : c.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? readableOn(accent) : c.text.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.onRetry, this.message});
  final VoidCallback onRetry;
  final String? message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message ?? context.l.offline,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.sfm.muted),
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: Text(context.l.retry)),
      ],
    ),
  );
}

/// Loads once and rebuilds with the result; `retry` re-runs.
class Loader<T> extends StatefulWidget {
  const Loader({super.key, required this.load, required this.builder, this.loading});
  final Future<T> Function() load;
  final Widget Function(BuildContext, T data) builder;
  final Widget? loading;
  @override
  State<Loader<T>> createState() => _LoaderState<T>();
}

class _LoaderState<T> extends State<Loader<T>> {
  late Future<T> _f = widget.load();
  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: _f,
    builder: (context, s) {
      if (s.hasError) return ErrorRetry(onRetry: () => setState(() => _f = widget.load()));
      if (!s.hasData) {
        return widget.loading ??
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
      }
      return widget.builder(context, s.data as T);
    },
  );
}
