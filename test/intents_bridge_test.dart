import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seoulfm/platform/intents_bridge.dart';

void main() {
  test('intents reach the radio', () async {
    final calls = <String>[];
    final bridge = IntentsBridge(
      onPlay: (key) async => calls.add('play $key'),
      onResume: () async => calls.add('resume'),
      onPause: () async => calls.add('pause'),
    );
    await bridge.handle(const MethodCall('play', 'ballad'));
    await bridge.handle(const MethodCall('resume'));
    await bridge.handle(const MethodCall('pause'));
    expect(calls, ['play ballad', 'resume', 'pause']);
  });

  test('unknown commands are refused, so the intent can tell', () {
    final bridge = IntentsBridge(onPlay: (_) async {}, onResume: () async {}, onPause: () async {});
    expect(bridge.handle(const MethodCall('play')), throwsA(isA<MissingPluginException>()));
    expect(bridge.handle(const MethodCall('skip')), throwsA(isA<MissingPluginException>()));
  });
}
