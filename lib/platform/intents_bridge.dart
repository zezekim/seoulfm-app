import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Siri, Shortcuts and Control Center (`ios/Runner/RadioIntents.swift`): play a station,
/// resume, pause. An intent can launch the app in the background, so native holds its
/// commands until [start] says Dart is listening; each call returns once the radio has acted.
class IntentsBridge {
  IntentsBridge({required this.onPlay, required this.onResume, required this.onPause});

  final Future<void> Function(String key) onPlay;
  final Future<void> Function() onResume;
  final Future<void> Function() onPause;

  static const _channel = MethodChannel('fm.seoul/intents');

  Future<void> start() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
    _channel.setMethodCallHandler(handle);
    try {
      await _channel.invokeMethod('ready');
    } on MissingPluginException {
      // A build without the intents bridge.
    } catch (_) {}
  }

  @visibleForTesting
  Future<void> handle(MethodCall call) async {
    switch (call.method) {
      case 'play' when call.arguments is String:
        await onPlay(call.arguments as String);
      case 'resume':
        await onResume();
      case 'pause':
        await onPause();
      default:
        throw MissingPluginException();
    }
  }
}
