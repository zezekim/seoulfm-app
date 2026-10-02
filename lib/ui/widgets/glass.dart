import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:seoulfm/platform/accessibility_prefs.dart';

/// Apple's Liquid Glass, as iOS 26 draws its tab bar and player bar: what is behind is blurred
/// and brightened through a thin tinted pane, lit along its top edge, with a hairline rim that
/// catches the light. [tint] colours the pane (the player bar takes its cover's colour).
class Glass extends StatelessWidget {
  const Glass({super.key, required this.child, this.radius = 28, this.tint, this.blur = 22, this.shadow = true});

  final Widget child;
  final double radius;
  final Color? tint;
  final double blur;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
    final pane = tint ?? (dark ? const Color(0xFF1C1C1F) : Colors.white);
    final shadows = shadow
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.45 : 0.14),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ]
        : null;
    // Reduce Transparency or a high-contrast setting: the same shape, opaque and unblurred, as
    // Apple's own bars become; high contrast also gets a clear edge.
    if (context.solidGlass) {
      final strong = context.highContrast;
      final edge = strong
          ? BorderSide(
              color: dark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.5),
              width: 1.5,
            )
          : BorderSide(
              color: dark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
              width: 0.5,
            );
      return DecoratedBox(
        decoration: ShapeDecoration(shape: shape, shadows: shadows),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: ColoredBox(
            color: pane.withValues(alpha: 1),
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: edge),
              ),
              child: child,
            ),
          ),
        ),
      );
    }
    return DecoratedBox(
      decoration: ShapeDecoration(shape: shape, shadows: shadows),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: CustomPaint(
            foregroundPainter: _Rim(radius: radius, dark: dark),
            child: DecoratedBox(
              decoration: BoxDecoration(
                // The pane, with the light falling on its top edge.
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.alphaBlend(
                      Colors.white.withValues(alpha: dark ? 0.10 : 0.35),
                      pane.withValues(alpha: dark ? 0.55 : 0.6),
                    ),
                    pane.withValues(alpha: dark ? 0.62 : 0.72),
                  ],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// The glass's rim: bright where the light hits (top), fading round the sides.
class _Rim extends CustomPainter {
  _Rim({required this.radius, required this.dark});
  final double radius;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: dark ? 0.28 : 0.8),
          Colors.white.withValues(alpha: dark ? 0.06 : 0.25),
          Colors.white.withValues(alpha: dark ? 0.12 : 0.4),
        ],
        stops: const [0, 0.6, 1],
      ).createShader(rect);
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(0.5), Radius.circular(radius)), paint);
  }

  @override
  bool shouldRepaint(_Rim old) => old.radius != radius || old.dark != dark;
}

/// A round glass button floating over a photo (Apple Music's back and ⋯ buttons on an artist).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({super.key, required this.icon, required this.tooltip, required this.onPressed});
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onPressed,
          child: Glass(
            radius: 22,
            blur: 16,
            shadow: false,
            tint: const Color(0xFF2A2A2E),
            child: SizedBox(width: 44, height: 44, child: Icon(icon, size: 21, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
