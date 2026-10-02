import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/data/channels.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';

import 'helpers.dart';

/// Station changes while playing: slow ones crossfade, a burst of skips lands on the last
/// station only, a pause mid-crossfade silences both. After each, exactly one player is
/// alive and heard, holding the right station, and nothing failed.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('station switching', (t) async {
    final log = <String>[];
    final original = debugPrint;
    debugPrint = (m, {wrapWidth}) {
      if (m != null && m.startsWith('radio:')) log.add(m);
      original(m, wrapWidth: wrapWidth);
    };
    addTearDown(() => debugPrint = original);

    await launch(binding, inAppShots: false);
    await wait(t, 6);
    final radio = t.element(find.byType(MiniPlayer)).read<RadioHandler>();
    final app = t.element(find.byType(MiniPlayer)).read<AppState>();
    final stations = app.channels.tunable.where((c) => !c.lossless).toList();
    expect(stations.length, greaterThanOrEqualTo(4));

    // Sample the players all along: never more than three alive (heard, incoming, outgoing).
    var most = 0, mostAudible = 0;
    final sampler = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final ps = radio.debugPlayers;
      if (ps.length > most) most = ps.length;
      final audible = ps.where((p) => p.playing && p.volume > 0.01).length;
      if (audible > mostAudible) mostAudible = audible;
    });
    addTearDown(sampler.cancel);

    bool holds(String? url, Channel c) => url != null && url.contains('/streams/${Uri.encodeComponent(c.stream)}/');

    Future<void> settledOn(Channel c, String step) async {
      // Wait for the station to be heard (up to the 8 s switch limit plus a load).
      for (var i = 0; i < 80; i++) {
        final ps = radio.debugPlayers;
        if (ps.length == 1 && ps.single.playing && ps.single.volume > 0.99 && !radio.buffering.value) break;
        await wait(t, 0.25);
      }
      final ps = radio.debugPlayers;
      debugPrint(
        'SWITCH $step: ${ps.map((p) => '${p.url?.split('/streams/').last} heard=${p.heard} playing=${p.playing} vol=${p.volume.toStringAsFixed(2)}').join(' | ')}',
      );
      expect(ps.length, 1, reason: '$step: one player alive');
      expect(ps.single.heard, isTrue);
      expect(ps.single.playing, isTrue, reason: '$step: playing');
      expect(ps.single.volume, greaterThan(0.99), reason: '$step: full volume');
      expect(holds(ps.single.url, c), isTrue, reason: '$step: holds ${c.key}, not ${ps.single.url}');
      expect(radio.channel?.key, c.key);
      expect(radio.wantPlaying.value, isTrue);
    }

    app.tuneIn(stations[0].key);
    await radio.play();
    await settledOn(stations[0], 'start');

    // Slow: one station at a time, each crossfade left to finish.
    for (final c in [stations[1], stations[2], stations[0]]) {
      app.tuneIn(c.key);
      await wait(t, 1);
      // The old station still plays while the new one loads: never a gap.
      expect(radio.debugPlayers.where((p) => p.playing).length, greaterThanOrEqualTo(1));
      await settledOn(c, 'slow ${c.key}');
    }

    // Fast: skip skip skip, as from a steering wheel; only the last survives.
    for (var i = 0; i < 6; i++) {
      await radio.skipToNext();
      await wait(t, 0.3);
    }
    await settledOn(app.channels.active, 'skips');

    // Mid-crossfade skips: wait for each fade to begin, then move on.
    for (final c in [stations[3], stations[1], stations[2]]) {
      app.tuneIn(c.key);
      for (var i = 0; i < 40 && radio.debugPlayers.where((p) => p.playing).length < 2; i++) {
        await wait(t, 0.25);
      }
      await wait(t, 0.5);
    }
    await settledOn(stations[2], 'mid-fade skips');

    // Pause mid-crossfade: both fall silent.
    app.tuneIn(stations[0].key);
    for (var i = 0; i < 40 && radio.debugPlayers.where((p) => p.playing).length < 2; i++) {
      await wait(t, 0.25);
    }
    await radio.pause();
    await wait(t, 1);
    final paused = radio.debugPlayers;
    debugPrint('SWITCH paused: ${paused.length} alive, ${paused.where((p) => p.playing).length} playing');
    expect(paused.where((p) => p.playing), isEmpty);
    expect(paused.length, lessThanOrEqualTo(1));
    await radio.play();
    await settledOn(stations[0], 'resumed');

    sampler.cancel();
    final fades = log.where((m) => m.startsWith('radio: crossfading after')).toList();
    final failures = log.where((m) => m.startsWith('radio: recover') || m.contains('not ready')).toList();
    debugPrint(
      'SWITCH-SUMMARY crossfades=${fades.length} ready=[${fades.map((m) => m.split(' ').last).join(', ')}] '
      'mostAlive=$most mostAudible=$mostAudible failures=$failures',
    );
    expect(failures, isEmpty);
    expect(radio.streamFailing.value, isFalse);
    expect(most, lessThanOrEqualTo(3));
    expect(mostAudible, lessThanOrEqualTo(2));
  });
}
