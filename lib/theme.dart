import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransition, CupertinoPageTransitionsBuilder;
import 'package:seoulfm/data/app_language.dart';

/// The site's design tokens (`app/globals.css`): a neutral base, near-black surfaces,
/// hairline borders, off-white type, and one accent (the tuned channel's colour, or
/// the on-air song's) marking what is live. Album art and the accent carry the screen.
@immutable
class SfmColors extends ThemeExtension<SfmColors> {
  const SfmColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.muted,
    required this.faint,
    required this.solid,
    required this.solidFg,
  });

  final Color bg, surface, surface2, surface3, border, borderStrong, text, muted, faint, solid, solidFg;

  static const dark = SfmColors(
    bg: Color(0xFF09090B),
    surface: Color(0xFF0F0F11),
    surface2: Color(0xFF151517),
    surface3: Color(0xFF1D1D20),
    border: Color(0xFF232327),
    borderStrong: Color(0xFF303036),
    text: Color(0xFFF4F4F5),
    muted: Color(0xFF8F8F97),
    faint: Color(0xFF5C5C64),
    solid: Color(0xFFF4F4F5),
    solidFg: Color(0xFF09090B),
  );

  static const light = SfmColors(
    bg: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF4F4F5),
    surface3: Color(0xFFEBEBEE),
    border: Color(0xFFE6E6EA),
    borderStrong: Color(0xFFD6D6DC),
    text: Color(0xFF101012),
    muted: Color(0xFF6B6B73),
    faint: Color(0xFF9A9AA3),
    solid: Color(0xFF101012),
    solidFg: Color(0xFFFFFFFF),
  );

  @override
  SfmColors copyWith() => this;

  @override
  SfmColors lerp(SfmColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return SfmColors(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      surface3: l(surface3, other.surface3),
      border: l(border, other.border),
      borderStrong: l(borderStrong, other.borderStrong),
      text: l(text, other.text),
      muted: l(muted, other.muted),
      faint: l(faint, other.faint),
      solid: l(solid, other.solid),
      solidFg: l(solidFg, other.solidFg),
    );
  }
}

/// Motion vocabulary (`lib/motion.ts`): three durations, two curves. Nothing else.
class Motion {
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
  static const out = Cubic(0.2, 0.8, 0.2, 1);
  static const inOut = Cubic(0.4, 0, 0.2, 1);
}

class Radii {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

extension SfmTheme on BuildContext {
  SfmColors get sfm => Theme.of(this).extension<SfmColors>()!;
}

/// Pretendard (bundled, variable): Inter's Latin drawn together with Hangul, so a title like
/// "AHOF(아홉)" is one face at one weight. Scripts it lacks fall to the system.
const fontFamily = 'Pretendard';
const _fallback = ['Apple SD Gothic Neo', 'Hiragino Sans', 'PingFang SC', 'Noto Sans CJK KR', 'Noto Sans'];

ThemeData buildTheme(Brightness brightness, Color accent) {
  final c = brightness == Brightness.dark ? SfmColors.dark : SfmColors.light;
  final base = ThemeData(brightness: brightness, useMaterial3: true);
  final p = base.textTheme.apply(
    bodyColor: c.text,
    displayColor: c.text,
    fontFamily: fontFamily,
    fontFamilyFallback: _fallback,
  );
  // One scale for the app. Pretendard reads best tracked in a little.
  TextStyle? s(TextStyle? t, double size, FontWeight w, {double track = -0.2, double? height}) =>
      t?.copyWith(fontSize: size, fontWeight: w, letterSpacing: track, height: height);
  final text = p.copyWith(
    headlineMedium: s(p.headlineMedium, 32, FontWeight.w800, track: -1),
    headlineSmall: s(p.headlineSmall, 24, FontWeight.w800, track: -0.6),
    titleLarge: s(p.titleLarge, 18, FontWeight.w700, track: -0.3),
    titleMedium: s(p.titleMedium, 16, FontWeight.w600),
    titleSmall: s(p.titleSmall, 14, FontWeight.w600),
    bodyLarge: s(p.bodyLarge, 16, FontWeight.w400, height: 1.45),
    bodyMedium: s(p.bodyMedium, 14, FontWeight.w400, height: 1.4),
    bodySmall: s(p.bodySmall, 12.5, FontWeight.w400, track: -0.1),
    labelLarge: s(p.labelLarge, 14, FontWeight.w600, track: -0.1),
    labelMedium: s(p.labelMedium, 12, FontWeight.w600, track: 0),
    labelSmall: s(p.labelSmall, 11, FontWeight.w600, track: 0.2),
  );
  return base.copyWith(
    // Apple Music's navigation on both platforms: pages slide in from the side over a dimmed,
    // parallaxed page behind, and swipe back from the edge (a cross-fade with Reduce Motion).
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: MotionAwarePageTransitionsBuilder(),
        TargetPlatform.android: MotionAwarePageTransitionsBuilder(),
      },
    ),
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
      surface: c.surface,
      primary: c.solid,
      onPrimary: c.solidFg,
      secondary: accent,
    ),
    textTheme: text,
    dividerColor: c.border,
    dividerTheme: DividerThemeData(color: c.border, thickness: 0.5, space: 0.5),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minVerticalPadding: 10,
      iconColor: c.muted,
      titleTextStyle: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500, height: 1.25),
      subtitleTextStyle: text.bodySmall?.copyWith(color: c.muted),
    ),
    iconTheme: IconThemeData(color: c.text, size: 22),
    // iOS apps don't ripple; Android keeps its sparkle.
    splashFactory: defaultTargetPlatform == TargetPlatform.iOS ? NoSplash.splashFactory : InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      surfaceTintColor: Colors.transparent,
      foregroundColor: c.text,
      elevation: 0,
      centerTitle: false,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl))),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.surface3,
      contentTextStyle: text.bodyMedium?.copyWith(color: c.text),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface2,
      hintStyle: TextStyle(color: c.faint),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        borderSide: BorderSide(color: c.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        borderSide: BorderSide(color: c.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        borderSide: BorderSide(color: c.borderStrong),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    extensions: [c],
  );
}

/// iOS's page transition, or with Reduce Motion (iOS) / Remove animations (Android) a short
/// cross-fade, as iOS itself does. The swipe back still works: it drives the fade. Both ways
/// build the same widgets (only the animations differ), so the setting can change mid-route.
class MotionAwarePageTransitionsBuilder extends PageTransitionsBuilder {
  const MotionAwarePageTransitionsBuilder();

  static const _slide = CupertinoPageTransitionsBuilder();

  @override
  Duration get transitionDuration => _slide.transitionDuration;

  // The page behind keeps still under a cross-fade (no parallax).
  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      (context, animation, secondaryAnimation, allowSnapshotting, child) => CupertinoPageTransition.delegatedTransition(
        context,
        animation,
        MediaQuery.disableAnimationsOf(context) ? kAlwaysDismissedAnimation : secondaryAnimation,
        allowSnapshotting,
        child,
      );

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final still = MediaQuery.disableAnimationsOf(context);
    return FadeTransition(
      // Done in the first third of the route's time: a quick fade.
      opacity: still ? animation.drive(CurveTween(curve: const Interval(0, 0.35))) : kAlwaysCompleteAnimation,
      child: _slide.buildTransitions(
        route,
        context,
        still ? kAlwaysCompleteAnimation : animation,
        still ? kAlwaysDismissedAnimation : secondaryAnimation,
        child,
      ),
    );
  }
}

/// `#rrggbb` → Color; null for anything else.
Color? parseHex(String? hex) {
  if (hex == null) return null;
  final m = RegExp(r'^#?([0-9a-fA-F]{6})$').firstMatch(hex.trim());
  if (m == null) return null;
  return Color(0xFF000000 | int.parse(m.group(1)!, radix: 16));
}

/// [c] darkened until white text on it reaches [ratio] (WCAG: 4.5 for body text, 3 for large).
/// Cover colours can be light (a gold, a pastel); this keeps the white type on them readable.
Color forWhiteText(Color c, {double ratio = 4.5}) {
  var hsl = HSLColor.fromColor(c);
  double contrast(Color x) => 1.05 / (x.computeLuminance() + 0.05);
  while (contrast(hsl.toColor()) < ratio && hsl.lightness > 0.02) {
    hsl = hsl.withLightness((hsl.lightness - 0.02).clamp(0.0, 1.0));
  }
  return hsl.toColor();
}

/// Near-black or white, whichever reads better on a solid fill (`readableOn` in lib/channels.ts).
Color readableOn(Color c) => c.computeLuminance() > 0.3 ? const Color(0xFF09090B) : Colors.white;

/// Eyebrow label: tiny, tracked, uppercase.
TextStyle eyebrow(BuildContext context, {Color? color}) =>
    TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: tracking(2), color: color ?? context.sfm.muted);
