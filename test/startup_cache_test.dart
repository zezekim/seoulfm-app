import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:seoulfm/state/session.dart';
import 'package:seoulfm/state/stations_now_playing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _body(String id, {int? endsAt}) => {
  'station': {'key': 'x'},
  'current': {'track_id': id, 'title': 'Song $id', 'artist': 'Artist'},
  'ends_at_epoch': ?endsAt,
};

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Session.init();
  });

  test('the last songs come back at launch unless they are old or over', () async {
    final now = DateTime(2026, 10, 2, 12);
    final ms = now.millisecondsSinceEpoch;
    final s = ms ~/ 1000;
    await Session.prefs.setString(
      'seoulfm-stations-now-playing',
      jsonEncode({
        'fresh': {'at': ms - 60000, 'body': _body('a', endsAt: s + 90)},
        'no-end': {'at': ms - 60000, 'body': _body('b')},
        'ended': {'at': ms - 60000, 'body': _body('c', endsAt: s - 5)},
        'old': {'at': ms - 10 * 60000, 'body': _body('d', endsAt: s + 90)},
      }),
    );
    final stations = StationsNowPlaying()..restore(now: now);
    expect(stations.byStation.keys, unorderedEquals(['fresh', 'no-end']));
    expect(stations.byStation['fresh']!.current!.id, 'a');
  });

  test('a broken copy is ignored', () async {
    await Session.prefs.setString('seoulfm-stations-now-playing', '{not json');
    expect((StationsNowPlaying()..restore()).byStation, isEmpty);
  });
}
