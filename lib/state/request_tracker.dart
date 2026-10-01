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

  void follow(String requestId, String token) {
    if (_subs.containsKey(requestId)) return;
    _subs[requestId] = sseConnect(api.requestEvents(requestId, token)).listen(
      (e) {
        if (e.name == 'request_status') {
          try {
            final s = RequestStatus.fromJson((jsonDecode(e.data) as Map).cast());
            final prev = active[requestId];
            active[requestId] = s;
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
  }

  @override
  void dispose() {
    for (final s in _subs.values) {
      s.cancel();
    }
    super.dispose();
  }
}
