import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';

/// What every other station is playing (`useStationsNowPlaying`), for the channel tiles,
/// CarPlay's station list and the Android Auto browse tree. Station time, not heard time.
/// Re-fetched just after the earliest track ends, with a 45 s ceiling; paused when nothing shows it.
class StationsNowPlaying extends ChangeNotifier {
  final Map<String, NowPlaying> byStation = {};
  List<String> _keys = const [];
  Timer? _timer;
  bool _active = false;

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
    final results = await Future.wait(
      _keys.map((k) async {
        try {
          return await api.nowPlaying(station: k);
        } catch (_) {
          return null;
        }
      }),
    );
    var changed = false;
    for (var i = 0; i < _keys.length; i++) {
      final np = results[i];
      if (np == null) continue;
      final old = byStation[_keys[i]];
      if (old?.current?.id != np.current?.id) changed = true;
      byStation[_keys[i]] = np;
    }
    if (changed) notifyListeners();
    if (!_active) return;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final ends = byStation.values.map((n) => n.endsAtEpoch).whereType<int>().where((e) => e > now);
    var wait = 45;
    if (ends.isNotEmpty) wait = (ends.reduce((a, b) => a < b ? a : b) - now + 2).clamp(5, 45);
    _timer = Timer(Duration(seconds: wait), _fetch);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
