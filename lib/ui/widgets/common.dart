import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/l10n/app_localizations.dart';
import 'package:seoulfm/state/ratings_controller.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/widgets/request_sheet.dart';
import 'package:seoulfm/ui/share.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/state/now_playing_controller.dart';
import 'package:seoulfm/ui/icons.dart';

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

/// A cover that shimmers while it loads and fades in once decoded; a radio glyph when there is none.
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
      child: Icon(AppIcons.radio, size: iconSize, color: c.faint),
    );
    // Decode at the size it is drawn (plus the screen's density), not the file's: a 1000 px
    // cover in a 52 pt row is ~16x the memory and the decode time.
    final px = size == null ? null : (size! * MediaQuery.devicePixelRatioOf(context)).round();
    final child = url == null
        ? placeholder
        : CachedNetworkImage(
            imageUrl: url!,
            memCacheWidth: px,
            memCacheHeight: px,
            fit: fit,
            fadeInDuration: Motion.slow,
            fadeOutDuration: Duration.zero,
            placeholder: (_, _) => const Skeleton(),
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
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat(reverse: true);
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

/// A section's heading inside a page (Top songs, Albums, Settings): the same bold voice as
/// the shelves, a size down. [icon] is accepted for old call sites and not drawn: titles
/// carry the hierarchy, as in Spotify and Apple Music.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.icon, this.trailing});
  final String title;
  final IconData? icon;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 26, trailing == null ? 16 : 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.4)),
          ),
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
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
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
                    playing ? AppIcons.pause : AppIcons.play,
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
          onPressed: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  r.rate(trackId!, active ? null : value);
                }
              : null,
          // Outline icons only: the chosen one sits in a soft disc and pops when picked.
          icon: AnimatedScale(
            scale: active ? 1.08 : 1,
            duration: Motion.base,
            curve: Curves.easeOutBack,
            child: Icon(active ? on : off, size: size),
          ),
          style: IconButton.styleFrom(backgroundColor: active ? base.withValues(alpha: 0.16) : Colors.transparent),
          color: active ? base : base.withValues(alpha: 0.7),
          disabledColor: base.withValues(alpha: 0.28),
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn('up', AppIcons.like, AppIcons.like, context.l.like),
        btn('down', AppIcons.dislike, AppIcons.dislike, context.l.dislike),
      ],
    );
  }
}

/// A song in a list, as Spotify draws one: the cover, the title (in the accent with bars
/// while it is on air), the artist, and whatever goes at the end. Long-press for the song's
/// actions; with [requestable], swipe right to request it.
class TrackRow extends StatelessWidget {
  const TrackRow({
    super.key,
    required this.track,
    this.leading,
    this.trailing,
    this.subtitle,
    this.onTap,
    this.requestable = false,
  });
  final Track track;
  final Widget? leading, trailing;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool requestable;

  bool get _canRequest => requestable && track.requestable != false && track.id != null;

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    final onAir = track.id != null && context.select<NowPlayingController, String?>((n) => n.track?.id) == track.id;
    final accent = Theme.of(context).colorScheme.secondary;
    final row = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          showTrackActions(context, track);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 12)],
                Artwork(track.artworkUrl, size: 52, radius: 6),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (onAir) ...[EqBars(color: accent, height: 11), const SizedBox(width: 7)],
                          Flexible(
                            child: Text(
                              track.displayTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500, color: onAir ? accent : c.text),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle ?? track.displayArtist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: c.muted),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
          ),
        ),
      ),
    );
    if (!_canRequest) return row;
    // Swipe right to request: the row springs back and the request sheet opens.
    return Dismissible(
      key: ValueKey('req-${track.id}-${identityHashCode(this)}'),
      direction: DismissDirection.startToEnd,
      dismissThresholds: const {DismissDirection.startToEnd: 0.28},
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        showRequestSheet(context, track);
        return false;
      },
      background: Container(
        color: accent,
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.only(left: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.request, color: readableOn(accent), size: 22),
            const SizedBox(width: 10),
            Text(
              context.l.swipeToRequest,
              style: TextStyle(fontWeight: FontWeight.w700, color: readableOn(accent)),
            ),
          ],
        ),
      ),
      child: row,
    );
  }
}

/// A song's actions (long-press on a row): request, its page, its artist, share.
Future<void> showTrackActions(BuildContext context, Track t) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  builder: (sheet) {
    final c = sheet.sfm;
    void go(VoidCallback f) {
      Navigator.pop(sheet);
      f();
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 36,
            height: 4,
            decoration: BoxDecoration(color: c.text.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(9)),
          ),
          ListTile(
            leading: Artwork(t.artworkUrl, size: 48, radius: 6),
            title: Text(t.displayTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(t.displayArtist, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const Divider(),
          if (t.requestable != false && t.id != null)
            ListTile(
              leading: const Icon(AppIcons.request),
              title: Text(sheet.l.request),
              onTap: () => go(() => showRequestSheet(context, t)),
            ),
          if (t.id != null)
            ListTile(
              leading: const Icon(AppIcons.music),
              title: Text(sheet.l.goToSong),
              onTap: () => go(() => Nav.openSong(t)),
            ),
          if (t.artistKey != null)
            ListTile(
              leading: const Icon(AppIcons.artist),
              title: Text(sheet.l.goToArtist),
              onTap: () => go(() => Nav.openArtist(t.artistKey!, name: t.displayArtist)),
            ),
          ListTile(
            leading: const Icon(AppIcons.share),
            title: Text(sheet.l.share),
            onTap: () => go(() => shareSong(context, t)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  },
);

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

/// A designed empty or error state: an icon in a soft disc, a title, a line of help, and an
/// action. Used for errors, offline, no results and empty lists.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.body, this.action, this.onAction});
  final IconData icon;
  final String title;
  final String? body, action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: c.text.withValues(alpha: 0.07), shape: BoxShape.circle),
            child: Icon(icon, size: 30, color: c.muted),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3),
          ),
          if (body != null) ...[
            const SizedBox(height: 6),
            Text(body!, textAlign: TextAlign.center, style: TextStyle(color: c.muted, height: 1.45)),
          ],
          if (action != null && onAction != null) ...[
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: c.solid,
                foregroundColor: c.solidFg,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: const StadiumBorder(),
              ),
              child: Text(action!, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}

/// A failed load: offline (no connection) or the server's problem (with its message), and a
/// retry.
class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.onRetry, this.message, this.error});
  final VoidCallback onRetry;
  final String? message;
  final Object? error;
  @override
  Widget build(BuildContext context) {
    final server = error is ApiError;
    return EmptyState(
      icon: server ? AppIcons.warning : AppIcons.offline,
      title: server ? context.l.serverErrorTitle : context.l.offlineTitle,
      body: message ?? (server ? (error as ApiError).message : context.l.offline),
      action: context.l.retry,
      onAction: onRetry,
    );
  }
}

/// Loads once and rebuilds with the result; `retry` re-runs. [frame], when given, wraps the
/// loading and error states (e.g. to keep them clear of a pinned header).
class Loader<T> extends StatefulWidget {
  const Loader({super.key, required this.load, required this.builder, this.loading, this.frame});
  final Future<T> Function() load;
  final Widget Function(BuildContext, T data) builder;
  final Widget? loading;
  final Widget Function(BuildContext, Widget child)? frame;
  @override
  State<Loader<T>> createState() => _LoaderState<T>();
}

class _LoaderState<T> extends State<Loader<T>> {
  late Future<T> _f = widget.load();
  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: _f,
    builder: (context, s) {
      final frame = widget.frame ?? (_, Widget child) => child;
      if (s.hasError) {
        return frame(
          context,
          ErrorRetry(
            error: s.error,
            onRetry: () => setState(() {
              _f = widget.load();
            }),
          ),
        );
      }
      if (!s.hasData) return frame(context, widget.loading ?? const SkeletonList());
      return widget.builder(context, s.data as T);
    },
  );
}

/// Shrinks a touch while pressed, as Spotify's and Apple Music's cards do, with a light tap
/// on release. [onTap] null leaves the child inert.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.onLongPress, this.scale = 0.96});
  final Widget child;
  final VoidCallback? onTap, onLongPress;
  final double scale;
  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null && widget.onLongPress == null) return widget.child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              widget.onTap!();
            },
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: Motion.fast,
        curve: Motion.out,
        child: widget.child,
      ),
    );
  }
}

/// A shimmering placeholder in the shape of what is loading.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.width, this.height, this.radius = 0});
  final double? width, height;
  final double radius;
  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = context.sfm.text;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final t = _c.value * 3 - 1; // sweeps from left of the box to right of it
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(t - 1, -0.3),
              end: Alignment(t + 1, 0.3),
              colors: [base.withValues(alpha: 0.05), base.withValues(alpha: 0.12), base.withValues(alpha: 0.05)],
              stops: const [0.25, 0.5, 0.75],
            ),
          ),
        );
      },
    );
  }
}

/// A list's shape while it loads: a few song rows.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.rows = 7});
  final int rows;
  @override
  Widget build(BuildContext context) => Column(children: [for (var i = 0; i < rows; i++) const SkeletonRow()]);
}

/// A song row's shape while the list loads.
class SkeletonRow extends StatelessWidget {
  const SkeletonRow({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        Skeleton(width: 48, height: 48, radius: Radii.sm),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(width: 160, height: 12, radius: 4),
              SizedBox(height: 8),
              Skeleton(width: 100, height: 10, radius: 4),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Spotify's pill switch: a dark track, the chosen option a white pill sliding under it.
/// The same on iOS and Android, unlike Material's segmented button.
class PillSegmented<T> extends StatelessWidget {
  const PillSegmented({super.key, required this.options, required this.selected, required this.onChanged});
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    final keys = options.keys.toList();
    final index = keys.indexOf(selected);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.text.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(99)),
      child: IntrinsicWidth(
        child: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (_, box) {
                  final w = box.maxWidth / keys.length;
                  return AnimatedPadding(
                    duration: Motion.base,
                    curve: Motion.out,
                    padding: EdgeInsets.only(left: w * index, right: w * (keys.length - 1 - index)),
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: c.text, borderRadius: BorderRadius.circular(99)),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final k in keys)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (k == selected) return;
                        HapticFeedback.selectionClick();
                        onChanged(k);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                        child: AnimatedDefaultTextStyle(
                          duration: Motion.base,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: k == selected ? c.bg : c.text.withValues(alpha: 0.85),
                          ),
                          child: Text(options[k]!, textAlign: TextAlign.center, maxLines: 1),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The stream's quality, as Tidal and Apple Music badge it: gold for lossless, a quiet
/// outline for the standard stream. [compact] is the small one for the player bar.
class QualityPill extends StatelessWidget {
  const QualityPill({super.key, required this.lossless, this.compact = false, this.label});
  final bool lossless, compact;
  final String? label;

  static const gold = [Color(0xFFF6DA8B), Color(0xFFD9A441)];

  @override
  Widget build(BuildContext context) {
    final text = label ?? (lossless ? (compact ? 'FLAC' : 'LOSSLESS') : 'AAC');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 5 : 9, vertical: compact ? 1.5 : 4),
      decoration: BoxDecoration(
        gradient: lossless ? const LinearGradient(colors: gold) : null,
        border: lossless ? null : Border.all(color: Colors.white.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(compact ? 4 : 99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lossless && !compact) ...[
            const Icon(AppIcons.quality, size: 12, color: Color(0xFF2A1E05)),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            // Caps only: centre them on the line box, not on room left for descenders.
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
            style: TextStyle(
              fontSize: compact ? 8.5 : 10,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: compact ? 0.6 : 1.2,
              color: lossless ? const Color(0xFF2A1E05) : Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

/// A large title that shrinks into the bar as the page scrolls (iOS's large titles): a big title
/// under the bar that fades and shrinks while a small centred one fades in. Pinned; [bottom]
/// (a search field, tabs) stays under it.
SliverAppBar largeTitleBar(BuildContext context, String title, {PreferredSizeWidget? bottom, List<Widget>? actions}) {
  final c = context.sfm;
  const large = 56.0; // room for the big title under the bar
  final bottomHeight = bottom?.preferredSize.height ?? 0;
  return SliverAppBar(
    pinned: true,
    expandedHeight: kToolbarHeight + large + bottomHeight,
    backgroundColor: c.bg,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    actions: actions,
    bottom: bottom,
    flexibleSpace: LayoutBuilder(
      builder: (context, box) {
        final top = MediaQuery.paddingOf(context).top;
        final min = top + kToolbarHeight + bottomHeight;
        final t = ((box.maxHeight - min) / large).clamp(0.0, 1.0); // 1 = fully expanded
        return Stack(
          children: [
            Positioned(
              top: top,
              left: 56,
              right: 56,
              height: kToolbarHeight,
              child: Center(
                child: Opacity(
                  opacity: (1 - t * 2).clamp(0.0, 1.0),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: bottomHeight + 6,
              child: Opacity(
                opacity: t,
                child: Transform.scale(
                  alignment: Alignment.bottomLeft,
                  scale: 0.9 + 0.1 * t,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1, height: 1.15),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
