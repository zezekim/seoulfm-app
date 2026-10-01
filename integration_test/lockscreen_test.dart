import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';

import 'helpers.dart';

/// The lock screen's progress: the media item carries the song's length and the playback
/// state the heard position. Plays for a minute so the system's media session can be read
/// meanwhile (`adb shell dumpsys media_session`).
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('lock screen progress', (t) async {
    await launch(binding, inAppShots: false);
    await wait(t, 8);
    final radio = t.element(find.byType(MiniPlayer)).read<RadioHandler>();
    await radio.play();
    await wait(t, 20);
    for (var i = 0; i < 4; i++) {
      final item = radio.mediaItem.value;
      final s = radio.playbackState.value;
      debugPrint('LOCK title=${item?.title} duration=${item?.duration?.inSeconds}s position=${s.position.inSeconds}s playing=${s.playing}');
      expect(item?.duration, isNotNull);
      expect(s.position, greaterThan(Duration.zero));
      await wait(t, 10);
    }
    await radio.pause();
  });
}
