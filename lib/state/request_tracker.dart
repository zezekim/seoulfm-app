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
    if (_subs.containsKey(requestId)) return;
    _subs[requestId] = sseConnect(api.requestEvents(requestId, token)).listen(
      (e) {
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
          } catch (_) {}
        } else if (e.name == 'bye') {
          _end(requestId);
        }
      },
      onError: (_) => _end(requestId),
      onDone: () => _end(requestId),
    );
  }

  void _end(String id) {
    _subs.remove(id)?.cancel();
    final s = active[id];
    if (s != null && !s.isFinal) active.remove(id); // the stream ended without a verdict
    _syncCurrent();
  }

  @override
  void dispose() {
    for (final s in _subs.values) {
      s.cancel();
    }
    super.dispose();
  }
}
