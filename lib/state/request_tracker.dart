import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/api/sse.dart';

/// Follows the listener's own requests on `/v3/requests/{id}/events` and reports each
/// change (`RequestToastContext`): queued, scheduled, played.
class RequestTracker extends ChangeNotifier {
  final Map<String, RequestStatus> active = {};
  final Map<String, StreamSubscription<SseEvent>> _subs = {};
  final Map<String, _Follow> _follows = {};
  bool _disposed = false;

  /// Past this, a request the stream never settled is dropped rather than retried forever.
  static const _maxAge = Duration(hours: 4);

  /// The latest change, for the toast.
  RequestStatus? lastChange;

  /// The listener's latest request still on its way (queued, scheduled, playing), with its
  /// ETA as it updates; null when there is none. Drives the tracker above the player bar.
  final ValueNotifier<RequestStatus?> current = ValueNotifier(null);

  void _syncCurrent() {
    final open = active.values.where((s) => !s.isFinal).toList();
    current.value = open.isEmpty ? null : open.last;
  }

  void follow(String requestId, String token) {
    if (_follows.containsKey(requestId)) return;
    _follows[requestId] = _Follow(token);
    _connect(requestId);
  }

  void _connect(String requestId) {
    final f = _follows[requestId];
    if (f == null || _disposed) return;
    _subs[requestId] = sseConnect(api.requestEvents(requestId, f.token)).listen(
      (e) {
        f.attempt = 0; // connected: the next drop starts the backoff over
        if (e.name == 'request_status') {
          try {
            final s = RequestStatus.fromJson((jsonDecode(e.data) as Map).cast());
            final prev = active[requestId];
            active.remove(requestId); // re-insert: the latest request is last
            active[requestId] = s;
            _syncCurrent();
            if (prev?.status != s.status) {
              lastChange = s;
              notifyListeners();
            }
            if (s.isFinal) _end(requestId);
          } catch (_) {}
        } else if (e.name == 'bye') {
          _end(requestId);
        }
      },
      // A dropped stream (network change, server restart) isn't a verdict: keep the
      // request and reconnect, backing off 2, 4, 8 … 30 s.
      onError: (_) => _retry(requestId),
      onDone: () => _retry(requestId),
      cancelOnError: true,
    );
  }

  void _retry(String id) {
    final f = _follows[id];
    _subs.remove(id)?.cancel();
    if (f == null || _disposed) return;
    if (DateTime.now().difference(f.since) > _maxAge) return _end(id);
    f.retry?.cancel();
    final wait = Duration(seconds: (2 << f.attempt).clamp(2, 30));
    if (f.attempt < 5) f.attempt++;
    f.retry = Timer(wait, () => _connect(id));
  }

  void _end(String id) {
    _follows.remove(id)?.retry?.cancel();
    _subs.remove(id)?.cancel();
    final s = active[id];
    if (s != null && !s.isFinal) active.remove(id); // the stream ended without a verdict
    _syncCurrent();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final s in _subs.values) {
      s.cancel();
    }
    for (final f in _follows.values) {
      f.retry?.cancel();
    }
    super.dispose();
  }
}

/// One followed request: its stream token, when it started, and the reconnect backoff.
class _Follow {
  _Follow(this.token);
  final String token;
  final DateTime since = DateTime.now();
  int attempt = 0;
  Timer? retry;
}
