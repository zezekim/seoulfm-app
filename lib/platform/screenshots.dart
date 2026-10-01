import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Screenshots of the app, as the system reports them: on iOS every one
/// (`userDidTakeScreenshotNotification`), on Android 14 and later through the activity's
/// screen-capture callback (older Android has no way to tell). The player listens and offers
/// to share the song, as Spotify does.
class Screenshots {
  Screenshots._();

  static const _channel = MethodChannel('fm.seoul/screenshots');

  /// Bumped on every screenshot; listen to it.
  static final ValueNotifier<int> taken = ValueNotifier(0);

  static void start() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'taken') taken.value++;
      return null;
    });
  }
}
