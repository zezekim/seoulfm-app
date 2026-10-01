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

  static const appVersion = String.fromEnvironment('SEOULFM_APP_VERSION', defaultValue: '3.0.0');
}
