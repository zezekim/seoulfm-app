import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/data/channels.dart';
import 'package:seoulfm/state/session.dart';

/// `useChannel()`: the line-up (polled every 30 s from `/v3/stations`) and the tuned channel.
class ChannelController extends ChangeNotifier {
  List<Channel> _channels = Channel.build(null);
  late String _activeKey;
  bool loaded = false;
  Timer? _timer;

  static const _prefKey = 'seoulfm-channel';

  List<Channel> get channels => _channels;
  List<Channel> get tunable => _channels.where((c) => c.tunable).toList();
  Channel get active => _channels.firstWhere((c) => c.key == _activeKey, orElse: () => _channels.first);

  void start() {
    _activeKey = Session.prefs.getString(_prefKey) ?? channelRegistry.first.key;
    api.activeStation = _activeKey;
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }

  Future<void> _refresh() async {
    try {
      final stations = await api.stations();
      _channels = Channel.build(stations);
      loaded = true;
      if (!_channels.any((c) => c.key == _activeKey && c.tunable)) _activeKey = _channels.first.key;
      notifyListeners();
    } catch (_) {}
  }

  Channel? byKey(String key) {
    for (final c in _channels) {
      if (c.key == key) return c;
    }
    return null;
  }

  /// Selects a channel; the player follows (see `RadioHandler.attach`).
  void select(String key) {
    final c = byKey(key);
    if (c == null || !c.tunable || key == _activeKey) return;
    _activeKey = key;
    api.activeStation = key;
    Session.prefs.setString(_prefKey, key);
    notifyListeners();
  }

  /// The next or previous tunable channel (steering-wheel skip buttons, swipe on the hero).
  Channel step(int delta) {
    final list = tunable;
    final i = list.indexWhere((c) => c.key == _activeKey);
    return list[(i + delta) % list.length];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
