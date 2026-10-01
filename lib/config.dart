import 'package:package_info_plus/package_info_plus.dart';

/// Build-time configuration. Pass values with `--dart-define` (see README):
///
///   flutter run --dart-define=SEOULFM_API_KEY=pk_... --dart-define=TURNSTILE_SITE_KEY=0x...
///
/// The API key must be a `publishable` key issued for the app (the site's key is
/// locked to seoul.fm's origins for writes). Never ship a partner key in the app.
class Config {
  static const apiBase = String.fromEnvironment('SEOULFM_API_URL', defaultValue: 'https://api.seoul.fm/v3');
  static const apiKey = String.fromEnvironment('SEOULFM_API_KEY');
  static const siteUrl = String.fromEnvironment('SEOULFM_SITE_URL', defaultValue: 'https://seoul.fm');
  static const streamBase = String.fromEnvironment('SEOULFM_STREAM_URL', defaultValue: 'https://stream.seoul.fm');
  static const runtimeConfigUrl = String.fromEnvironment(
    'SEOULFM_RUNTIME_CONFIG_URL',
    defaultValue: 'https://dash-api.seoul.fm/public/runtime-config',
  );

  /// Cloudflare Turnstile site key; empty disables the captcha (development only:
  /// the API requires it for writes in production).
  static const turnstileSiteKey = String.fromEnvironment('TURNSTILE_SITE_KEY');
  static bool get captchaEnabled => turnstileSiteKey.isNotEmpty;

  /// Sentry DSN for crash and error reports; empty turns reporting off (nothing is sent).
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static const appVersion = String.fromEnvironment('SEOULFM_APP_VERSION', defaultValue: '3.0.0');

  /// The commit the build came from (`--dart-define=GIT_COMMIT=$(git rev-parse --short HEAD)`).
  static const gitCommit = String.fromEnvironment('GIT_COMMIT');
}

/// The installed build: version and build number from the app itself (pubspec's
/// `version: 3.0.0+300` becomes 3.0.0 and 300), plus the commit. Loaded once at launch.
abstract final class AppBuild {
  static String version = Config.appVersion;
  static String number = '';

  static Future<void> load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) version = info.version;
      number = info.buildNumber;
    } catch (_) {}
  }

  /// "3.0.0 (300) · 4cbd3c3", as More shows it.
  static String get label => [
    number.isEmpty ? version : '$version ($number)',
    if (Config.gitCommit.isNotEmpty) Config.gitCommit,
  ].join(' · ');
}
