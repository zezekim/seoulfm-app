import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/state/session.dart';

/// A song the listener saved, and when.
@immutable
class SavedSong {
  const SavedSong(this.track, this.savedAt);
  final Track track;
  final DateTime savedAt;
}

/// Songs the listener saved ("Your songs", Apple Music's favourites without an account). Kept on
/// the device only, newest first. Each is stored as the v3 fields needed to show and request it,
/// so [Track.fromJson] reads them back; songs from the live feed may lack some (no artist key),
/// and a richer copy seen later fills them in ([enrich]).
class SavedSongs extends ChangeNotifier {
  SavedSongs() {
    _load();
  }

  static const prefsKey = 'seoulfm-saved-songs';
  static const max = 1000;

  final List<SavedSong> _songs = [];

  List<SavedSong> get songs => List.unmodifiable(_songs);
  int get length => _songs.length;
  bool get isEmpty => _songs.isEmpty;

  /// What identifies a song: its id, else (a live-feed song without one) its artist and title.
  static String? keyOf(Track? t) {
    if (t == null) return null;
    if (t.id != null) return t.id;
    final title = (t.title ?? '').trim().toLowerCase();
    if (title.isEmpty) return null;
    return 'name:${(t.artist ?? '').trim().toLowerCase()}|$title';
  }

  /// Whether [t] can be saved at all (it has an id or at least a title).
  static bool canSave(Track? t) => keyOf(t) != null;

  int _indexOf(Track? t) {
    final k = keyOf(t);
    return k == null ? -1 : _songs.indexWhere((s) => keyOf(s.track) == k);
  }

  bool isSaved(Track? t) => _indexOf(t) >= 0;

  /// Saves [t] at the top. Already saved: nothing changes.
  void save(Track t) {
    if (!canSave(t) || isSaved(t)) return;
    _songs.insert(0, SavedSong(t, DateTime.now()));
    if (_songs.length > max) _songs.removeRange(max, _songs.length);
    _changed();
  }

  /// Removes [t]; returns what was removed and where, for an undo ([restore]).
  (SavedSong, int)? remove(Track t) {
    final i = _indexOf(t);
    if (i < 0) return null;
    final s = _songs.removeAt(i);
    _changed();
    return (s, i);
  }

  /// Puts a removed song back where it was.
  void restore(SavedSong s, int index) {
    if (isSaved(s.track)) return;
    _songs.insert(index.clamp(0, _songs.length), s);
    if (_songs.length > max) _songs.removeRange(max, _songs.length);
    _changed();
  }

  /// Saves or removes [t]; returns whether it is saved now.
  bool toggle(Track t) {
    if (isSaved(t)) {
      remove(t);
      return false;
    }
    save(t);
    return isSaved(t);
  }

  /// A fuller copy ([fuller], e.g. from the song's page) of saved song [t] fills in the fields the
  /// saved one lacked, keeping its place, its date and its ids (which the player and lists match on).
  void enrich(Track t, Track fuller) {
    final i = _indexOf(t);
    if (i < 0) return;
    final old = _songs[i].track;
    final before = jsonEncode(_encode(old));
    Json known(Track x) => _encode(x)..removeWhere((_, v) => v == null);
    final merged = Track.fromJson({
      ...known(fuller),
      ...known(old),
      'track_id': old.trackId,
      'legacy_song_id': old.legacySongId,
      // Whether it can be requested changes; the fresh copy knows better.
      'requestable': fuller.requestable ?? old.requestable,
    });
    if (jsonEncode(_encode(merged)) == before) return;
    _songs[i] = SavedSong(merged, _songs[i].savedAt);
    _changed();
  }

  void _changed() {
    Session.prefs.setString(prefsKey, jsonEncode([for (final s in _songs) _encode(s.track, s.savedAt)]));
    notifyListeners();
  }

  /// Reads the saved list (stored newest first); anything unreadable is skipped rather than
  /// losing the rest.
  void _load() {
    final raw = Session.prefs.getString(prefsKey);
    if (raw == null) return;
    Object? list;
    try {
      list = jsonDecode(raw);
    } catch (_) {
      return;
    }
    if (list is! List) return;
    final seen = <String>{};
    for (final e in list) {
      if (e is! Map) continue;
      try {
        final j = e.cast<String, dynamic>();
        final t = Track.fromJson(j);
        final k = keyOf(t);
        if (k == null || !seen.add(k)) continue;
        final at = j['saved_at'];
        _songs.add(SavedSong(t, DateTime.fromMillisecondsSinceEpoch(at is num ? at.toInt() : 0)));
      } catch (_) {}
      if (_songs.length >= max) break;
    }
  }

  /// The v3 fields [Track.fromJson] reads (the artwork already resolved; reading it again keeps it).
  static Json _encode(Track t, [DateTime? savedAt]) => {
    'track_id': t.trackId,
    'legacy_song_id': t.legacySongId,
    'title': t.title,
    'artist': t.artist,
    'album': t.album,
    'artwork_url': t.artworkUrl,
    'duration_ms': t.durationMs,
    'has_lyrics': t.hasLyrics ? true : null,
    'artist_key': t.artistKey,
    'album_key': t.albumKey,
    'release_year': t.releaseYear,
    'genre': t.genre,
    'requestable': t.requestable,
    'saved_at': ?savedAt?.millisecondsSinceEpoch,
  };
}
