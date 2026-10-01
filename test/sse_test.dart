import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:seoulfm/api/sse.dart';

void main() {
  test('parses named events and skips keep-alives', () async {
    final client = MockClient.streaming((req, _) async {
      const body =
          'retry: 5000\nevent: hello\ndata: {"stream":"station"}\n\n'
          ': ka\n\n'
          'event: now_playing\ndata: {"on_air":true}\n\n'
          'event: bye\ndata: {"reason":"max_duration"}\n\n';
      return http.StreamedResponse(Stream.value(body.codeUnits), 200);
    });
    final events = await sseConnect(Uri.parse('https://api.seoul.fm/v3/events'), client: client).toList();
    expect(events.map((e) => e.name), ['hello', 'now_playing', 'bye']);
    expect(events[1].data, '{"on_air":true}');
  });

  test('errors on a non-200 answer', () async {
    final client = MockClient.streaming((req, _) async => http.StreamedResponse(const Stream.empty(), 429));
    expect(sseConnect(Uri.parse('https://api.seoul.fm/v3/events'), client: client).toList(), throwsA(isA<http.ClientException>()));
  });
}
