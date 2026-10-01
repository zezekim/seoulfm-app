import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:seoulfm/config.dart';
import 'package:seoulfm/state/session.dart';

/// The operators' control plane (lib/runtimeConfig.ts), trimmed to what the app shows.
/// Rule zero: fail open. A body without `maintenance` is a failure, never "maintenance off".
class RuntimeConfig {
  const RuntimeConfig({
    this.version = 0,
    this.maintenance = false,
    this.maintenanceTitle,
    this.maintenanceMessage,
    this.announcement,
    this.announcementLevel = 'info',
    this.streamNotice,
    this.streamAvailable = true,
    this.delayMs = defaultDelayMs,
    this.stationDelayMs = const {},
  });

  static const defaultDelayMs = 15000;

  final int version;
  final bool maintenance;
  final String? maintenanceTitle, maintenanceMessage;
  final String? announcement;
  final String announcementLevel;
  final String? streamNotice;
  final bool streamAvailable;
  final int delayMs;
  final Map<String, int> stationDelayMs;

  /// How far a listener runs behind the station when the player can't say (`lyricsDelayMs`).
  int delayFor(String station) => stationDelayMs[station] ?? delayMs;

  static String? _text(Object? v) => v is String && v.trim().isNotEmpty ? v.trim() : null;
  static int? _delay(Object? v) => v is num && v >= 0 && v <= 120000 ? v.toInt() : null;

  static RuntimeConfig? parse(Object? body) {
    if (body is! Map || body['maintenance'] is! Map) return null;
    final m = body['maintenance'] as Map;
    final a = body['announcement'] is Map ? body['announcement'] as Map : const {};
    final s = body['stream'] is Map ? body['stream'] as Map : const {};
    final ly = body['lyrics'] is Map ? body['lyrics'] as Map : const {};
    final perStation = <String, int>{};
    if (ly['station_delay_ms'] is Map) {
      (ly['station_delay_ms'] as Map).forEach((k, v) {
        final d = _delay(v);
        if (k is String && d != null) perStation[k] = d;
      });
    }
    const levels = {'info', 'success', 'warning', 'danger'};
    return RuntimeConfig(
      version: body['config_version'] is num ? (body['config_version'] as num).toInt() : 0,
      maintenance: m['enabled'] == true,
      maintenanceTitle: _text(m['title']),
      maintenanceMessage: _text(m['message']),
      announcement: a['enabled'] == true ? _text(a['text']) : null,
      announcementLevel: levels.contains(a['level']) ? a['level'] as String : 'info',
      streamAvailable: s['available'] != false,
      streamNotice: _text(s['notice']),
      delayMs: _delay(ly['delay_ms']) ?? defaultDelayMs,
      stationDelayMs: perStation,
    );
  }
}

class RuntimeConfigController extends ChangeNotifier {
  RuntimeConfig _config = const RuntimeConfig();
  RuntimeConfig get config => _config;
  Timer? _timer;
  static const _cacheKey = 'seoulfm_runtime_config';

  void start() {
    final cached = Session.prefs.getString(_cacheKey);
    if (cached != null) {
      try {
        _config = RuntimeConfig.parse(jsonDecode(cached)) ?? _config;
      } catch (_) {}
    }
    _fetch();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _fetch());
  }

  Future<void> _fetch() async {
    try {
      final res = await http.get(Uri.parse(Config.runtimeConfigUrl)).timeout(const Duration(seconds: 4));
      if (res.statusCode != 200) return;
      final parsed = RuntimeConfig.parse(jsonDecode(utf8.decode(res.bodyBytes)));
      if (parsed == null) return;
      await Session.prefs.setString(_cacheKey, utf8.decode(res.bodyBytes));
      _config = parsed;
      notifyListeners();
    } catch (_) {
      // Fail open: keep the last good copy.
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
