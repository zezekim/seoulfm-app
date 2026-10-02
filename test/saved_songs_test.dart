import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/state/saved_songs.dart';
import 'package:seoulfm/state/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

Track _t(String id, {String? artistKey, bool? requestable, String? artwork}) => Track(
  trackId: id,
  title: 'Song $id',
  artist: 'Artist $id',
  artistKey: artistKey,
  requestable: requestable,
  artworkUrl: artwork,
);

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Session.init();
  });

  setUp(() => Session.prefs.remove(SavedSongs.prefsKey));

  test('saves newest first, once, and keeps them across launches', () {
    final s = SavedSongs()
      ..save(_t('a', artistKey: 'artist-a', requestable: false, artwork: 'https://seoul.fm/api/art/a.jpg'))
      ..save(_t('b'))
      ..save(_t('a'));
    expect(s.songs.map((x) => x.track.id), ['b', 'a']);

    final later = SavedSongs();
    expect(later.songs.map((x) => x.track.id), ['b', 'a']);
    final a = later.songs.last.track;
    expect(a.title, 'Song a');
    expect(a.artist, 'Artist a');
    expect(a.artistKey, 'artist-a');
    expect(a.requestable, isFalse);
    expect(a.artworkUrl, 'https://seoul.fm/api/art/a.jpg');
    expect(later.songs.first.savedAt.isAfter(DateTime(2020)), isTrue);
  });

  test('toggle saves and removes; undo puts it back in its place', () {
    final s = SavedSongs()
      ..save(_t('a'))
      ..save(_t('b'))
      ..save(_t('c'));
    expect(s.toggle(_t('d')), isTrue);
    expect(s.toggle(_t('d')), isFalse);
    expect(s.isSaved(_t('d')), isFalse);

    final removed = s.remove(_t('b'))!;
    expect(removed.$2, 1);
    expect(s.songs.map((x) => x.track.id), ['c', 'a']);
    s.restore(removed.$1, removed.$2);
    expect(s.songs.map((x) => x.track.id), ['c', 'b', 'a']);
    expect(SavedSongs().songs.map((x) => x.track.id), ['c', 'b', 'a']);
  });

  test('a live-feed song without an id is saved by artist and title', () {
    final s = SavedSongs();
    final live = Track(title: 'Hype Boy', artist: 'NewJeans');
    expect(SavedSongs.canSave(live), isTrue);
    expect(SavedSongs.canSave(Track(artist: 'No title')), isFalse);
    s.save(live);
    expect(s.isSaved(Track(title: ' hype boy', artist: 'NEWJEANS ')), isTrue);
    expect(SavedSongs().isSaved(live), isTrue);
  });

  test('a fuller copy fills in what the saved one lacked', () {
    final live = Track(legacySongId: 7, title: 'X', artist: 'Y');
    final s = SavedSongs()..save(live);
    s.enrich(live, Track(trackId: 'uuid', title: 'X (new)', artist: 'Y', artistKey: 'y', requestable: false));
    final t = s.songs.single.track;
    expect(t.title, 'X');
    expect(t.id, '7');
    expect(s.isSaved(live), isTrue);
    expect(t.artistKey, 'y');
    expect(t.requestable, isFalse);
    expect(SavedSongs().songs.single.track.artistKey, 'y');
  });

  test('keeps at most the newest ${SavedSongs.max}', () {
    final s = SavedSongs();
    for (var i = 0; i < SavedSongs.max + 5; i++) {
      s.save(_t('$i'));
    }
    expect(s.length, SavedSongs.max);
    expect(s.songs.first.track.id, '${SavedSongs.max + 4}');
    expect(s.isSaved(_t('4')), isFalse);
    expect(s.isSaved(_t('5')), isTrue);
  });

  test('corrupt data is skipped, not fatal', () async {
    await Session.prefs.setString(SavedSongs.prefsKey, '{not json');
    expect(SavedSongs().isEmpty, isTrue);

    await Session.prefs.setString(SavedSongs.prefsKey, jsonEncode({'track_id': 'a'}));
    expect(SavedSongs().isEmpty, isTrue);

    await Session.prefs.setString(
      SavedSongs.prefsKey,
      jsonEncode([
        42,
        'text',
        {'title': 7},
        {'track_id': 'a', 'title': 'A', 'saved_at': 'yesterday', 'duration_ms': 'long'},
        {'track_id': 'a', 'title': 'A again'},
        {'track_id': 'b', 'title': 'B', 'saved_at': 1700000000000},
      ]),
    );
    final s = SavedSongs();
    expect(s.songs.map((x) => x.track.id), ['a', 'b']);
    expect(s.songs.first.track.title, 'A');
    expect(s.songs.last.savedAt, DateTime.fromMillisecondsSinceEpoch(1700000000000));
  });
}
