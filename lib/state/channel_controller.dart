import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/data/channels.dart';
import 'package:seoulfm/state/session.dart';

/// `useChannel()`: the line-up (polled every 30 s from `/v3/stations`) and the tuned channel.
/// The last line-up is kept on the device, so a launch paints it at once and refreshes behind it.
class ChannelController extends ChangeNotifier {
  List<Channel> _channels = Channel.build(null);
  late String _activeKey;

  /// Whether there is a line-up from the API (this launch's, or the last one kept).
  bool loaded = false;
  Timer? _timer;
  String? _saved;

  static const _prefKey = 'seoulfm-channel';
  static const _cacheKey = 'seoulfm-stations-cache';

  List<Channel> get channels => _channels;
  List<Channel> get tunable => _channels.where((c) => c.tunable).toList();
  Channel get active => _channels.firstWhere((c) => c.key == _activeKey, orElse: () => _channels.first);

  /// The station tuned last time (kept on the device), else the first.
  static String get savedKey => Session.prefs.getString(_prefKey) ?? channelRegistry.first.key;

  void start() {
    _activeKey = savedKey;
    _restore();
    api.activeStation = _activeKey;
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }

  void _restore() {
    _saved = Session.prefs.getString(_cacheKey);
    if (_saved == null) return;
    try {
      _apply([for (final e in jsonDecode(_saved!) as List) (e as Map).cast<String, dynamic>()]);
    } catch (_) {}
  }

  void _apply(List<Json> items) {
    _channels = Channel.build(items.map(StationSummary.fromJson).toList());
    loaded = true;
    if (!_channels.any((c) => c.key == _activeKey && c.tunable)) _activeKey = _channels.first.key;
  }

  Future<void> _refresh() async {
    try {
      final items = await api.stationsJson();
      _apply(items);
      notifyListeners();
      // Kept without the listener counts, so it is rewritten only when the line-up changes.
      final json = jsonEncode([for (final e in items) Map.of(e)..remove('listener_count')]);
      if (json != _saved) {
        _saved = json;
        Session.prefs.setString(_cacheKey, json);
      }
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
