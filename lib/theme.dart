import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

/// Inter for Latin, Cyrillic and Vietnamese; Hangul falls to Pretendard when the
/// device has it, then the system's Korean face.
const _fallback = ['Pretendard', 'Apple SD Gothic Neo', 'Noto Sans KR', 'Noto Sans CJK KR'];

ThemeData buildTheme(Brightness brightness, Color accent) {
  final c = brightness == Brightness.dark ? SfmColors.dark : SfmColors.light;
  final base = ThemeData(brightness: brightness, useMaterial3: true);
  final inter = GoogleFonts.interTextTheme(base.textTheme).apply(bodyColor: c.text, displayColor: c.text, fontFamilyFallback: _fallback);
  // Large titles (headlineMedium, expanded) heavy and tight like Apple's and Spotify's; the
  // collapsed title (titleLarge) a step lighter.
  final text = inter.copyWith(
    headlineMedium: inter.headlineMedium?.copyWith(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1),
    titleLarge: inter.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3),
  );
  return base.copyWith(
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

/// `#rrggbb` → Color; null for anything else.
Color? parseHex(String? hex) {
  if (hex == null) return null;
  final m = RegExp(r'^#?([0-9a-fA-F]{6})$').firstMatch(hex.trim());
  if (m == null) return null;
  return Color(0xFF000000 | int.parse(m.group(1)!, radix: 16));
}

/// Near-black or white, whichever reads better on a solid fill (`readableOn` in lib/channels.ts).
Color readableOn(Color c) => c.computeLuminance() > 0.3 ? const Color(0xFF09090B) : Colors.white;

/// Eyebrow label: tiny, tracked, uppercase.
TextStyle eyebrow(BuildContext context, {Color? color}) =>
    TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 2, color: color ?? context.sfm.muted);
