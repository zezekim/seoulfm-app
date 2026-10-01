import 'package:flutter/widgets.dart';

/// The language the app is showing, for text built outside the widget tree (station
/// taglines on the lock screen and in the car) and for script-aware typography. The app sets
/// it whenever its locale resolves (`SeoulFmApp`).
abstract final class AppLanguage {
  /// The locale's key in the translation tables: `en`, `es_ES`, `zh_Hant`...
  static String tag = 'en';
  static String language = 'en';
  static bool rtl = false;

  /// Scripts whose letters are joined or stacked (Arabic, Thai) or that have no case and are
  /// set solid (CJK): letter spacing breaks them, and upper-casing means nothing.
  static bool get tracks => !const {'ar', 'th', 'ja', 'zh', 'ko'}.contains(language);

  static void set(Locale l, TextDirection direction) {
    language = l.languageCode;
    tag = l.scriptCode == 'Hant'
        ? 'zh_Hant'
        : l.countryCode == 'ES' && l.languageCode == 'es'
        ? 'es_ES'
        : l.languageCode;
    rtl = direction == TextDirection.rtl;
  }
}

/// Letter spacing [v] where the script takes it, none where it would break the letters.
double tracking(double v) => AppLanguage.tracks ? v : 0;

/// A Latin name or title inside right-to-left text, kept in its own direction (a first-strong
/// isolate), so "Pop!" doesn't read "!Pop". Unchanged in left-to-right languages.
String isolate(String s) => AppLanguage.rtl && s.isNotEmpty ? '\u2068$s\u2069' : s;
