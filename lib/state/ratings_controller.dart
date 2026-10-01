import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/state/session.dart';

/// Netflix-style thumbs on the heard track (lib/RatingsContext.tsx). The API only takes a
/// rating while this session is listening, so [canRate] waits for 25 s of uninterrupted
/// playing on the station. Taps are optimistic and debounced; failures roll back.
class RatingsController extends ChangeNotifier {
  RatingsController({required this.listeningSince, required this.station});

  final ValueListenable<DateTime?> listeningSince;
  final String Function() station;

  static const listenFor = Duration(seconds: 25);

  final Map<String, RatingState> _states = {};
  final Set<String> _hidden = {};
  final Map<String, Timer> _debounce = {};
  bool closed = false;
  DateTime? _disabledUntil;
  Timer? _openTimer;

  RatingState? stateOf(String? id) => id == null ? null : _states[id];
  bool hiddenFor(String? id) => closed || id == null || _hidden.contains(id);

  bool get canRate {
    final since = listeningSince.value;
    if (since == null) return false;
    if (_disabledUntil != null && DateTime.now().isBefore(_disabledUntil!)) return false;
    return DateTime.now().difference(since) >= listenFor;
  }

  void start() {
    listeningSince.addListener(_armOpen);
  }

  void _armOpen() {
    _openTimer?.cancel();
    final since = listeningSince.value;
    notifyListeners();
    if (since == null) return;
    final left = listenFor - DateTime.now().difference(since);
    _openTimer = Timer(left.isNegative ? Duration.zero : left, notifyListeners);
  }

  Future<void> load(String? id) async {
    if (id == null || closed || _states.containsKey(id)) return;
    try {
      _states[id] = await api.rating(id, Session.listenerId);
      notifyListeners();
    } catch (_) {}
  }

  void rate(String id, String? rating) {
    if (!canRate) return;
    final before = _states[id];
    _states[id] = RatingState(rating, before?.hot ?? false);
    notifyListeners();
    _debounce[id]?.cancel();
    _debounce[id] = Timer(const Duration(milliseconds: 400), () => _send(id, rating, before));
  }

  Future<void> _send(String id, String? rating, RatingState? before) async {
    try {
      _states[id] = await api.rate(id, {
        'rating': rating,
        'session_id': Session.sessionId,
        'listener_id': Session.listenerId,
        'station': station(),
      });
    } on ApiError catch (e) {
      _states[id] = before ?? const RatingState(null, false);
      if (e.reason == 'ratings_closed') {
        closed = true;
      } else if (e.status == 409 || e.status == 404) {
        _hidden.add(id);
      } else if (e.status == 429) {
        _disabledUntil = DateTime.now().add(Duration(seconds: e.retryAfterSeconds ?? 60));
      }
    } catch (_) {
      _states[id] = before ?? const RatingState(null, false);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    listeningSince.removeListener(_armOpen);
    _openTimer?.cancel();
    for (final t in _debounce.values) {
      t.cancel();
    }
    super.dispose();
  }
}
