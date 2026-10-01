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
}
