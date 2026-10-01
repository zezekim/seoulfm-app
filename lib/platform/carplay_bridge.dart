import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/data/channels.dart';

/// Talks to the native CarPlay scene (`ios/Runner/SceneDelegate.swift`). The car shows a
/// list of stations (with what each is playing) and the system Now Playing screen, which
/// reads the same lock-screen metadata `audio_service` publishes. Android Auto needs no
/// bridge: it browses `RadioHandler.getChildren`.
bool get _ios => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

class CarPlayBridge {
  CarPlayBridge({required this.onTune});

  final Future<void> Function(String key) onTune;
  static const _channel = MethodChannel('fm.seoul/carplay');
  String _lastPayload = '';

  void start() {
    if (!_ios) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'tune' && call.arguments is String) {
        await onTune(call.arguments as String);
      }
      return null;
    });
  }

  /// Sends the station list; only when it changed.
  Future<void> update({
    required List<Channel> channels,
    required String activeKey,
    required bool playing,
    required Map<String, NowPlaying> nowPlaying,
  }) async {
    if (!_ios) return;
    final items = [
      for (final c in channels.where((c) => c.tunable))
        {
          'key': c.key,
          'name': 'SeoulFM ${c.name}',
          'detail': _detail(c, nowPlaying[c.key]?.current),
          'art': nowPlaying[c.key]?.current?.artworkUrl ?? c.live?.artworkUrl,
          'color': c.color.toARGB32(),
          'playing': playing && c.key == activeKey,
        },
    ];
    final payload = items.toString();
    if (payload == _lastPayload) return;
    _lastPayload = payload;
    try {
      await _channel.invokeMethod('setStations', items);
    } on MissingPluginException {
      // No CarPlay scene in this build.
    } catch (_) {}
  }

  String _detail(Channel c, Track? t) => t == null ? c.tagline : '${t.displayTitle} · ${t.displayArtist}';
}
