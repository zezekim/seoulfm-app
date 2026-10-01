import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/api/sse.dart';

/// One `/v3/events` connection for the tuned station (`useStationEvents`), shifted to
/// what the listener actually hears (`useHeardNowPlaying`): the pushes are station time,
/// a listener runs [delayMs] behind, so the bodies are kept on a timeline by their start
/// on the stream's clock and the one covering `now − delay` is shown.
class NowPlayingController extends ChangeNotifier {
  NowPlayingController({required this.delayMs});

  /// How far behind the station the listener is right now.
  final int Function(String station) delayMs;

  static const _recentLimit = 30;
  static const _upcomingLimit = 12;
  static const _timelineMax = 8;

  String _station = defaultStation;
  final List<NowPlaying> _timeline = [];
  NowPlaying? _heard;
  List<Track> _recent = [];
  List<Track> upcoming = [];
  ListenerCount? listeners;
  bool connected = false;

  StreamSubscription<SseEvent>? _sub;
  Timer? _retry, _tick, _snapshotTimer;
  int _attempt = 0;
  bool _gotSnapshot = false;
  int? _askedAt;

  /// The body covering what the listener hears.
  NowPlaying? get station => _heard;
  Track? get track => _heard?.current;
  String get stationKey => _station;

  /// Plays the listener has heard end (the station's recent list minus what is still ahead of them).
  List<Track> get recent {
    final heardStart = _heard?.startedAtEpochMs;
    if (heardStart == null) return _recent;
    return _recent.where((t) => (t.playedAtEpoch ?? 0) * 1000 < heardStart).toList();
  }

  int heardAt() => DateTime.now().millisecondsSinceEpoch - delayMs(_station);

  /// The listener's position in the heard track, ms (never `now − started_at`).
  int? positionMs() {
    final start = _heard?.startMs;
    if (start == null) return null;
    final dur = _heard?.current?.durationMs;
    final p = heardAt() - start;
    return dur == null ? max(0, p) : p.clamp(0, dur);
  }

  void tune(String station) {
    if (station == _station && _sub != null) return;
    _station = station;
    _timeline.clear();
    _heard = null;
    _recent = [];
    upcoming = [];
    listeners = null;
    _askedAt = null;
    notifyListeners();
    _connect(reset: true);
    _tick ??= Timer.periodic(const Duration(seconds: 1), (_) => _reselect());
  }

  void _connect({bool reset = false}) {
    _sub?.cancel();
    _retry?.cancel();
    _snapshotTimer?.cancel();
    if (reset) _attempt = 0;
    _gotSnapshot = false;
    final stationAtConnect = _station;
    _sub = sseConnect(api.stationEvents(_station, recentLimit: _recentLimit, upcomingLimit: _upcomingLimit)).listen(
      (e) {
        if (stationAtConnect != _station) return;
        _onEvent(e);
      },
      onError: (_) {
        _restFallback();
        _reconnectLater(_backoff(_attempt++));
      },
      onDone: () => _reconnectLater(Duration(milliseconds: 1000 + Random().nextInt(2000))),
    );
    _snapshotTimer = Timer(const Duration(seconds: 5), () {
      if (!_gotSnapshot) _restFallback();
    });
  }

  Duration _backoff(int attempt) {
    final base = min(60000, 5000 * pow(2, attempt).toInt());
    return Duration(milliseconds: base ~/ 2 + Random().nextInt(base ~/ 2 + 1));
  }

  void _reconnectLater(Duration d) {
    _sub?.cancel();
    _sub = null;
    connected = false;
    notifyListeners();
    _retry = Timer(d, _connect);
  }

  void _onEvent(SseEvent e) {
    Json data;
    try {
      data = (jsonDecode(e.data) as Map).cast<String, dynamic>();
    } catch (_) {
      return;
    }
    switch (e.name) {
      case 'hello':
        _attempt = 0;
        connected = true;
      case 'now_playing':
        _gotSnapshot = true;
        _push(NowPlaying.fromJson(data));
      case 'recent':
        _recent = tracksOf(data);
      case 'upcoming':
        upcoming = tracksOf(data);
      case 'listeners':
        listeners = ListenerCount.fromJson(data);
      case 'bye':
        _reconnectLater(Duration(milliseconds: 1000 + Random().nextInt(2000)));
        return;
    }
    _reselect(force: true);
  }

  void _restFallback() {
    final s = _station;
    api
        .nowPlaying(station: s)
        .then((np) {
          if (s == _station) {
            _push(np);
            _reselect(force: true);
          }
        })
        .catchError((_) {});
    api
        .recent(limit: _recentLimit, station: s)
        .then((r) {
          if (s == _station) {
            _recent = r;
            notifyListeners();
          }
        })
        .catchError((_) {});
    api
        .upcoming(limit: _upcomingLimit, station: s)
        .then((u) {
          if (s == _station) {
            upcoming = u;
            notifyListeners();
          }
        })
        .catchError((_) {});
  }

  void _push(NowPlaying np) {
    final start = np.startMs;
    _timeline.removeWhere((t) => t.startMs == start);
    _timeline.add(np);
    _timeline.sort((a, b) => (a.startMs ?? 0).compareTo(b.startMs ?? 0));
    while (_timeline.length > _timelineMax) {
      _timeline.removeAt(0);
    }
  }

  /// Picks the body covering `heardAt()`; when the listener is behind everything known,
  /// asks `/now-playing?at=` once for that moment.
  void _reselect({bool force = false}) {
    if (_timeline.isEmpty) {
      if (force) notifyListeners();
      return;
    }
    final at = heardAt();
    NowPlaying? pick;
    for (final np in _timeline) {
      if ((np.startMs ?? 0) <= at) pick = np;
    }
    if (pick == null) {
      pick = _timeline.first;
      final first = _timeline.first.startMs;
      if (first != null && _askedAt != first) {
        _askedAt = first;
        final s = _station;
        api
            .nowPlaying(station: s, at: at)
            .then((np) {
              if (s == _station) {
                _push(np);
                _reselect(force: true);
              }
            })
            .catchError((_) {});
      }
    }
    if (force || !identical(pick, _heard)) {
      _heard = pick;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _retry?.cancel();
    _tick?.cancel();
    _snapshotTimer?.cancel();
    super.dispose();
  }
}
