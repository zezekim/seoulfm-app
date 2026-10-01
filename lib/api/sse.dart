import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class SseEvent {
  SseEvent(this.name, this.data);
  final String name;
  final String data;
}

/// A minimal Server-Sent Events reader for `/v3/events` and request streams: frames are
/// `event: <name>` plus `data: <JSON>`, comments (`: ka`) are keep-alives. The stream
/// errors on a non-200 answer and closes when the server does; the caller reconnects.
Stream<SseEvent> sseConnect(Uri uri, {http.Client? client}) {
  final c = client ?? http.Client();
  late final StreamController<SseEvent> out;
  StreamSubscription<String>? sub;

  Future<void> start() async {
    try {
      final req = http.Request('GET', uri)
        ..headers['Accept'] = 'text/event-stream'
        ..headers['Cache-Control'] = 'no-cache';
      final res = await c.send(req);
      if (res.statusCode != 200) {
        out.addError(http.ClientException('SSE ${res.statusCode}', uri));
        await out.close();
        return;
      }
      var name = 'message';
      final data = StringBuffer();
      sub = res.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (line.isEmpty) {
                if (data.isNotEmpty) out.add(SseEvent(name, data.toString()));
                name = 'message';
                data.clear();
              } else if (line.startsWith(':')) {
                // keep-alive comment
              } else if (line.startsWith('event:')) {
                name = line.substring(6).trim();
              } else if (line.startsWith('data:')) {
                if (data.isNotEmpty) data.write('\n');
                data.write(line.substring(5).trimLeft());
              }
            },
            onError: (Object e) {
              if (!out.isClosed) out.addError(e);
            },
            onDone: () {
              if (!out.isClosed) out.close();
            },
            cancelOnError: true,
          );
    } catch (e) {
      if (!out.isClosed) {
        out.addError(e);
        await out.close();
      }
    }
  }

  out = StreamController<SseEvent>(
    onListen: start,
    onCancel: () async {
      await sub?.cancel();
      if (client == null) c.close();
    },
  );
  return out.stream;
}
