import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/state/session.dart';

/// What every other station is playing (`useStationsNowPlaying`), for the channel tiles,
/// CarPlay's station list and the Android Auto browse tree. Station time, not heard time.
/// Re-fetched just after the earliest track ends, with a 45 s ceiling; paused when nothing shows it.
/// The last answers are kept on the device so a launch shows them at once (see [restore]).
class StationsNowPlaying extends ChangeNotifier {
  final Map<String, NowPlaying> byStation = {};
  List<String> _keys = const [];
  Timer? _timer;
  bool _active = false;

  /// Each station's body as the API sent it, and when (ms), for the copy kept on the device.
  final Map<String, ({int at, Json body})> _kept = {};

  static const _cacheKey = 'seoulfm-stations-now-playing';

  /// A kept song older than this isn't shown at launch, nor one whose end has passed: at most a
  /// few minutes of "on air" for a song that may be over, until the first fetch replaces it.
  static const maxAge = Duration(minutes: 5);

  /// Fills [byStation] from the last launch's answers that are still plausibly on air.
  void restore({DateTime? now}) {
    final raw = Session.prefs.getString(_cacheKey);
    if (raw == null) return;
    final nowMs = (now ?? DateTime.now()).millisecondsSinceEpoch;
    try {
      for (final MapEntry(:key, :value) in (jsonDecode(raw) as Map<String, dynamic>).entries) {
        final at = value['at'] as int;
        final body = (value['body'] as Map).cast<String, dynamic>();
        final np = NowPlaying.fromJson(body);
        if (_stale(np, at, nowMs)) continue;
        byStation[key] = np;
        _kept[key] = (at: at, body: body);
      }
    } catch (_) {}
  }

  static bool _stale(NowPlaying np, int at, int nowMs) {
    final ends = np.endsAtEpoch;
    return nowMs - at > maxAge.inMilliseconds || (ends != null && ends * 1000 < nowMs);
  }

  void setStations(List<String> keys) {
    if (listEquals(keys, _keys)) return;
    _keys = keys;
    if (_active) _fetch();
  }

  void setActive(bool on) {
    if (on == _active) return;
    _active = on;
    _timer?.cancel();
    if (on) _fetch();
  }

  Future<void> _fetch() async {
    _timer?.cancel();
    final keys = _keys;
    final results = await Future.wait(
      keys.map((k) async {
        try {
          return await api.nowPlayingJson(station: k);
        } catch (_) {
          return null;
        }
      }),
    );
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    var changed = false;
    for (var i = 0; i < keys.length; i++) {
      final key = keys[i];
      final body = results[i];
      if (body == null) {
        // No answer (offline): stop showing a song once it has ended, rather than as on air forever.
        final old = byStation[key];
        final kept = _kept[key];
        if (old != null && kept != null && _stale(old, kept.at, nowMs)) {
          byStation.remove(key);
          _kept.remove(key);
          changed = true;
        }
        continue;
      }
      final NowPlaying np;
      try {
        np = NowPlaying.fromJson(body);
      } catch (_) {
        continue;
      }
      final old = byStation[key];
      if (old?.current?.id != np.current?.id) changed = true;
      byStation[key] = np;
      _kept[key] = (at: nowMs, body: body);
    }
    if (changed) {
      notifyListeners();
      _save();
    }
    if (!_active) return;
    final now = nowMs ~/ 1000;
    final ends = byStation.values.map((n) => n.endsAtEpoch).whereType<int>().where((e) => e > now);
    var wait = 45;
    if (ends.isNotEmpty) wait = (ends.reduce((a, b) => a < b ? a : b) - now + 2).clamp(5, 45);
    _timer = Timer(Duration(seconds: wait), _fetch);
  }

  void _save() {
    final json = jsonEncode({
      for (final MapEntry(:key, :value) in _kept.entries) key: {'at': value.at, 'body': value.body},
    });
    Session.prefs.setString(_cacheKey, json);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
