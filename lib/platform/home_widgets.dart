import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:seoulfm/data/app_language.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/data/channels.dart';

/// Feeds the home-screen widgets (iOS WidgetKit, Android app widget) what is on air: the
/// station, the heard song, its cover and whether it plays. iOS also gets the API settings,
/// so its widget can refresh on its own while the app is closed.
class HomeWidgets {
  HomeWidgets._();

  static const _channel = MethodChannel('fm.seoul/widgets');
  static String _last = '';

  static Future<void> update({required Channel channel, required Track? track, required bool playing}) async {
    if (kIsWeb) return;
    final data = <String, Object?>{
      'stationKey': channel.key,
      'stationName': isolate('SeoulFM ${channel.rawName}'),
      'title': track?.displayTitle,
      'artist': track?.displayArtist,
      'artUrl': track?.artworkUrl,
      'accent': channel.color.toARGB32(),
      'playing': playing,
      // For the iOS widget's own refreshes.
      'apiBase': Config.apiBase,
      'apiKey': Config.apiKey,
      'siteUrl': Config.siteUrl,
      'artCdn': 'https://cdn-albumart.kpopradio.net/',
    };
    final key = data.toString();
    if (key == _last) return;
    _last = key;
    try {
      await _channel.invokeMethod('update', data);
    } on MissingPluginException {
      // A build without the widget bridge.
    } catch (_) {}
  }

  static String _lastRequest = '';

  /// The listener's request on its way, for the iOS Live Activity's countdown: its title, when
  /// it should start ([at], null when not known) and whether it plays now; [title] null once it
  /// has played or gone.
  static Future<void> request({required String? title, DateTime? at, bool playing = false}) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
    final data = title == null
        ? null
        : <String, Object?>{
            'title': title,
            'at': at == null ? null : at.millisecondsSinceEpoch / 1000,
            'playing': playing,
          };
    final key = data.toString();
    if (key == _lastRequest) return;
    _lastRequest = key;
    try {
      await _channel.invokeMethod('request', data);
    } on MissingPluginException {
      // A build without the widget bridge.
    } catch (_) {}
  }
}
