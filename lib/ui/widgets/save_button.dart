import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/state/saved_songs.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/screens/your_songs_screen.dart';
import 'package:seoulfm/ui/widgets/common.dart';

/// Saves or removes [t] and says so: "Saved" with a way to the list, "Removed" with an undo.
void toggleSaved(BuildContext context, Track t) {
  final store = context.read<SavedSongs>();
  final messenger = ScaffoldMessenger.maybeOf(context);
  final l = context.l;
  final removed = store.isSaved(t) ? store.remove(t) : null;
  if (removed == null) store.save(t);
  messenger
    ?..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(removed == null ? l.savedToYourSongs : l.removedFromYourSongs),
        action: removed == null
            ? SnackBarAction(label: l.view, onPressed: () => Nav.push(const YourSongsScreen()))
            : SnackBarAction(label: l.undo, onPressed: () => store.restore(removed.$1, removed.$2)),
      ),
    );
}

/// The heart that saves a song to Your songs (Apple Music's favourite): outline, or filled once
/// saved, popping with a tap of haptics. A toggle to screen readers.
class SaveButton extends StatefulWidget {
  const SaveButton({super.key, required this.track, this.onImage = false, this.size = 22, this.compact = false});
  final Track? track;
  final bool onImage, compact;
  final double size;

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> with SingleTickerProviderStateMixin {
  late final _pop = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  bool _popUp = true;

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  void _tap(Track t, bool saved) {
    saved ? HapticFeedback.selectionClick() : HapticFeedback.lightImpact();
    _popUp = !saved;
    if (!MediaQuery.disableAnimationsOf(context)) _pop.forward(from: 0);
    toggleSaved(context, t);
  }

  // Saving swells and settles; removing gives a small dip.
  static final _swell = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeOut)), weight: 35),
    TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.94).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 35),
  ]);
  static final _dip = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.82).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 0.82, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)), weight: 60),
  ]);

  @override
  Widget build(BuildContext context) {
    final t = widget.track;
    if (!SavedSongs.canSave(t)) return const SizedBox.shrink();
    final saved = context.select<SavedSongs, bool>((s) => s.isSaved(t));
    final base = widget.onImage ? Colors.white : context.sfm.text;
    final l = context.l;
    return Semantics(
      container: true,
      button: true,
      toggled: saved,
      label: l.favourite,
      hint: saved ? l.removeFromYourSongs : l.saveToYourSongs,
      onTap: () => _tap(t!, saved),
      excludeSemantics: true,
      child: IconButton(
        tooltip: saved ? l.removeFromYourSongs : l.saveToYourSongs,
        onPressed: () => _tap(t!, saved),
        visualDensity: widget.compact ? VisualDensity.compact : null,
        icon: AnimatedBuilder(
          animation: _pop,
          builder: (_, child) =>
              Transform.scale(scale: _pop.isAnimating ? (_popUp ? _swell : _dip).evaluate(_pop) : 1, child: child),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: saved ? 1 : 0),
            duration: Motion.fast,
            builder: (_, fill, _) =>
                HeartIcon(size: widget.size, fill: fill, color: Color.lerp(base.withValues(alpha: 0.85), base, fill)!),
          ),
        ),
      ),
    );
  }
}

/// Lucide's heart (the app's icon set has no filled glyphs), drawn so it can fill: [fill] 0 is the
/// outline, 1 solid.
class HeartIcon extends StatelessWidget {
  const HeartIcon({super.key, this.size = 22, this.fill = 0, this.color});
  final double size, fill;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _HeartPainter(color ?? IconTheme.of(context).color ?? context.sfm.text, fill)),
  );
}

class _HeartPainter extends CustomPainter {
  _HeartPainter(this.color, this.fill);
  final Color color;
  final double fill;

  // lucide.dev/icons/heart, on its 24-unit grid.
  static final _path = Path()
    ..moveTo(2, 9.5)
    ..arcToPoint(const Offset(11.591, 5.824), radius: const Radius.circular(5.5))
    ..arcToPoint(const Offset(12.409, 5.824), radius: const Radius.circular(0.56), clockwise: false)
    ..arcToPoint(const Offset(22, 9.5), radius: const Radius.circular(5.49))
    ..cubicTo(22, 11.79, 20.5, 13.5, 19, 15)
    ..lineTo(13.508, 20.313)
    ..arcToPoint(const Offset(10.508, 20.332), radius: const Radius.circular(2))
    ..lineTo(5, 15)
    ..cubicTo(3.5, 13.5, 2, 11.8, 2, 9.5)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    if (fill > 0) canvas.drawPath(_path, Paint()..color = color.withValues(alpha: color.a * fill));
    canvas.drawPath(
      _path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_HeartPainter old) => old.color != color || old.fill != fill;
}
