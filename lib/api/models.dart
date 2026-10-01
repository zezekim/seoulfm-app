// Hand-written models for the v3 bodies the app reads (https://api.seoul.fm/v3/openapi.json).
// Field names follow v3 (`track_id`, `artwork_url`, `duration_ms`, `*_epoch`); every body
// always carries every field, so absent and null mean the same here.

import 'package:seoulfm/config.dart';

typedef Json = Map<String, dynamic>;

const _artworkCdn = 'https://cdn-albumart.kpopradio.net/';

/// The artwork CDN only answers seoul.fm Referers; the site keeps its own copy at
/// `/api/art/{file}` (lib/artwork.ts), which any client can load.
String? artworkSrc(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith(_artworkCdn)) return '${Config.siteUrl}/api/art/${url.substring(_artworkCdn.length)}';
  if (url.startsWith('/')) return '${Config.siteUrl}$url';
  return url;
}

int? _int(dynamic v) => v is num ? v.toInt() : null;
double? _num(dynamic v) => v is num ? v.toDouble() : null;
String? _str(dynamic v) => v is String ? v : null;
bool _bool(dynamic v) => v == true;
List<T> _list<T>(dynamic v, T Function(Json) f) => v is List ? v.whereType<Map>().map((e) => f(e.cast<String, dynamic>())).toList() : <T>[];
Json? _obj(dynamic v) => v is Map ? v.cast<String, dynamic>() : null;

class Dedication {
  const Dedication({this.name, this.message});
  final String? name;
  final String? message;
  static Dedication? fromJson(Json? j) {
    if (j == null) return null;
    final d = Dedication(name: _str(j['name']), message: _str(j['message']));
    return (d.name == null && d.message == null) ? null : d;
  }
}

/// Every track-shaped body: CurrentTrack, PlayItem, UpcomingItem, LibraryTrack,
/// SearchTrack, chart items, HotTrack. Fields a body doesn't carry stay null.
class Track {
  Track({
    this.trackId,
    this.legacySongId,
    this.artist,
    this.title,
    this.album,
    this.artworkUrl,
    this.durationMs,
    this.hasLyrics = false,
    this.artistKey,
    this.albumKey,
    this.releaseYear,
    this.genre,
    this.requestable,
    this.playCount,
    this.dedication,
    this.playedAtEpoch,
    this.source,
    this.position,
    this.startsAtEpoch,
    this.etaSeconds,
    this.movement,
    this.previousPosition,
    this.requestCount,
    this.lossless,
    this.codec,
    this.sampleRate,
    this.bitDepth,
  });

  final String? trackId;
  final int? legacySongId;
  final String? artist;
  final String? title;
  final String? album;
  final String? artworkUrl;
  final int? durationMs;
  final bool hasLyrics;
  final String? artistKey;
  final String? albumKey;
  final int? releaseYear;
  final String? genre;
  final bool? requestable;
  final int? playCount;
  final Dedication? dedication;
  final int? playedAtEpoch;

  /// Upcoming: `request` when a listener asked for it.
  final String? source;
  final int? position;
  final int? startsAtEpoch;
  final int? etaSeconds;
  final String? movement;
  final int? previousPosition;
  final int? requestCount;
  final bool? lossless;
  final String? codec;
  final int? sampleRate;
  final int? bitDepth;

  /// The id every endpoint takes: the UUID, else the legacy id.
  String? get id => trackId ?? legacySongId?.toString();
  String get displayTitle => title ?? '';
  String get displayArtist => artist ?? '';
  bool get isRequest => source == 'request';

  factory Track.fromJson(Json j) => Track(
    trackId: _str(j['track_id']),
    legacySongId: _int(j['legacy_song_id']),
    artist: _str(j['artist']),
    title: _str(j['title']),
    album: _str(j['album']),
    artworkUrl: artworkSrc(_str(j['artwork_url'])),
    durationMs: _int(j['duration_ms']),
    hasLyrics: _bool(j['has_lyrics']),
    artistKey: _str(j['artist_key']),
    albumKey: _str(j['album_key']),
    releaseYear: _int(j['release_year']),
    genre: _str(j['genre']),
    requestable: j['requestable'] is bool ? j['requestable'] as bool : null,
    playCount: _int(j['play_count']),
    dedication: Dedication.fromJson(_obj(j['dedication'])),
    playedAtEpoch: _int(j['played_at_epoch']),
    source: _str(j['source']),
    position: _int(j['position']),
    startsAtEpoch: _int(j['starts_at_epoch']),
    etaSeconds: _int(j['eta_seconds']),
    movement: _str(j['movement']),
    previousPosition: _int(j['previous_position']),
    requestCount: _int(j['request_count']),
    lossless: j['lossless'] is bool ? j['lossless'] as bool : null,
    codec: _str(j['codec']),
    sampleRate: _int(j['sample_rate']),
    bitDepth: _int(j['bit_depth']),
  );
}

class StationSummary {
  StationSummary({
    required this.key,
    required this.name,
    this.genre,
    this.description,
    this.accentColor,
    this.shortName,
    this.tagline,
    this.artworkUrl,
    this.sortOrder = 0,
    this.isPublic = false,
    this.onAir = true,
    this.listenerCount,
  });

  final String key;
  final String name;
  final String? genre, description, accentColor, shortName, tagline, artworkUrl;
  final int sortOrder;
  final bool isPublic;
  final bool onAir;
  final int? listenerCount;

  factory StationSummary.fromJson(Json j) => StationSummary(
    key: _str(j['key']) ?? '',
    name: _str(j['name']) ?? '',
    genre: _str(j['genre']),
    description: _str(j['description']),
    accentColor: _str(j['accent_color']),
    shortName: _str(j['short_name']),
    tagline: _str(j['tagline']),
    artworkUrl: artworkSrc(_str(j['artwork_url'])),
    sortOrder: _int(j['sort_order']) ?? 0,
    isPublic: _bool(j['public']),
    onAir: j['on_air'] != false,
    listenerCount: _int(j['listener_count']),
  );
}

class MarathonArtistRef {
  const MarathonArtistRef(this.artistKey, this.name);
  final String artistKey;
  final String name;
  factory MarathonArtistRef.fromJson(Json? j) => MarathonArtistRef(_str(j?['artist_key']) ?? '', _str(j?['name']) ?? '');
}

class MarathonBlock {
  MarathonBlock({
    required this.artist,
    this.artworkUrl,
    required this.startsAtEpoch,
    required this.endsAtEpoch,
    required this.source,
    this.nominationId,
    this.votes,
    this.boosts,
    this.boostable = false,
    this.dedication,
    this.note,
  });
  final MarathonArtistRef artist;
  final String? artworkUrl;
  final int startsAtEpoch, endsAtEpoch;
  final String source;
  final String? nominationId;
  final int? votes, boosts;
  final bool boostable;
  final Dedication? dedication;
  final String? note;

  factory MarathonBlock.fromJson(Json j) => MarathonBlock(
    artist: MarathonArtistRef.fromJson(_obj(j['artist'])),
    artworkUrl: artworkSrc(_str(j['artwork_url'])),
    startsAtEpoch: _int(j['starts_at_epoch']) ?? 0,
    endsAtEpoch: _int(j['ends_at_epoch']) ?? 0,
    source: _str(j['source']) ?? 'rotation',
    nominationId: _str(j['nomination_id']),
    votes: _int(j['votes']),
    boosts: _int(j['boosts']),
    boostable: _bool(j['boostable']),
    dedication: Dedication.fromJson(_obj(j['dedication'])),
    note: _str(j['note']),
  );
}

/// `GET /now-playing` (and the `now_playing` event).
class NowPlaying {
  NowPlaying({
    required this.stationKey,
    required this.onAir,
    this.current,
    this.startedAtEpochMs,
    this.streamStartedAtEpochMs,
    this.endsAtEpoch,
    this.marathon,
  });

  final String stationKey;
  final bool onAir;
  final Track? current;
  final int? startedAtEpochMs;

  /// Where the track starts on the manifests' PROGRAM-DATE-TIME clock.
  final int? streamStartedAtEpochMs;
  final int? endsAtEpoch;
  final MarathonBlock? marathon;

  /// The start on the stream's clock when the API stamps one, else station time.
  int? get startMs => streamStartedAtEpochMs ?? startedAtEpochMs;

  factory NowPlaying.fromJson(Json j) {
    final started = _int(j['started_at_epoch_ms']) ?? ((_int(j['started_at_epoch']) ?? 0) * 1000);
    return NowPlaying(
      stationKey: _str(_obj(j['station'])?['key']) ?? '',
      onAir: j['on_air'] != false,
      current: _obj(j['current']) == null ? null : Track.fromJson(_obj(j['current'])!),
      startedAtEpochMs: started == 0 ? null : started,
      streamStartedAtEpochMs: _int(j['stream_started_at_epoch_ms']),
      endsAtEpoch: _int(j['ends_at_epoch']),
      marathon: _obj(j['marathon']) == null ? null : MarathonBlock.fromJson(_obj(j['marathon'])!),
    );
  }
}

class ListenerCount {
  ListenerCount(this.listeners, this.peak24h);
  final int listeners, peak24h;
  factory ListenerCount.fromJson(Json j) => ListenerCount(_int(j['listeners']) ?? 0, _int(j['peak_24h']) ?? 0);
}

List<Track> tracksOf(Json j, [String key = 'items']) => _list(j[key], Track.fromJson);

class ArtistSummary {
  ArtistSummary({required this.key, required this.name, this.trackCount = 0, this.playCount = 0, this.artworkUrl});
  final String key, name;
  final int trackCount, playCount;
  final String? artworkUrl;
  factory ArtistSummary.fromJson(Json j) => ArtistSummary(
    key: _str(j['key']) ?? _str(j['artist_key']) ?? '',
    name: _str(j['name']) ?? _str(j['artist']) ?? '',
    trackCount: _int(j['track_count']) ?? _int(j['unique_tracks']) ?? 0,
    playCount: _int(j['play_count']) ?? 0,
    artworkUrl: artworkSrc(_str(j['artwork_url'])),
  );
}

class SearchResults {
  SearchResults(this.tracks, this.artists);
  final List<Track> tracks;
  final List<ArtistSummary> artists;
  factory SearchResults.fromJson(Json j) =>
      SearchResults(_list(_obj(j['tracks'])?['items'], Track.fromJson), _list(_obj(j['artists'])?['items'], ArtistSummary.fromJson));
}

class AlbumWithTracks {
  AlbumWithTracks(this.title, this.year, this.artworkUrl, this.tracks);
  final String title;
  final int? year;
  final String? artworkUrl;
  final List<Track> tracks;
  factory AlbumWithTracks.fromJson(Json j) =>
      AlbumWithTracks(_str(j['title']) ?? '', _int(j['year']), artworkSrc(_str(j['artwork_url'])), _list(j['tracks'], Track.fromJson));
}

class ArtistProfile {
  ArtistProfile(this.artist, this.topTracks, this.albums);
  final ArtistSummary artist;
  final List<Track> topTracks;
  final List<AlbumWithTracks> albums;
  factory ArtistProfile.fromJson(Json j) => ArtistProfile(
    ArtistSummary.fromJson(_obj(j['artist']) ?? const {}),
    _list(j['top_tracks'], Track.fromJson),
    _list(j['albums'], AlbumWithTracks.fromJson),
  );
}

class TrackDetail {
  TrackDetail(this.track, this.related, this.requestCount, this.mood, this.label);
  final Track track;
  final List<Track> related;
  final int? requestCount;
  final String? mood, label;
  factory TrackDetail.fromJson(Json j) {
    final t = _obj(j['track']) ?? const {};
    return TrackDetail(Track.fromJson(t), _list(j['related'], Track.fromJson), _int(t['request_count']), _str(t['mood']), _str(t['label']));
  }
}

class LyricLine {
  const LyricLine(this.startMs, this.text);
  final int startMs;
  final String text;
}

class Lyrics {
  Lyrics({this.plain, this.lines = const []});
  final String? plain;
  final List<LyricLine> lines;
  bool get synced => lines.isNotEmpty;
  bool get isEmpty => !synced && (plain == null || plain!.trim().isEmpty);

  factory Lyrics.fromJson(Json j) {
    final synced = _obj(j['synced']);
    return Lyrics(
      plain: _str(j['plain']),
      lines: synced == null ? const [] : _list(synced['lines'], (l) => LyricLine(_int(l['start_ms']) ?? 0, _str(l['text']) ?? '')),
    );
  }
}

class RequestEta {
  RequestEta({this.basis, this.etaMinutes, this.position});
  final String? basis;
  final int? etaMinutes, position;
  factory RequestEta.fromJson(Json? j) =>
      RequestEta(basis: _str(j?['basis']), etaMinutes: _int(j?['eta_minutes']), position: _int(j?['position']));
}

class RequestSubmission {
  RequestSubmission({
    required this.accepted,
    required this.reasonCode,
    required this.reason,
    this.requestId,
    this.statusToken,
    required this.status,
    required this.track,
    required this.eta,
    this.retryAfterSeconds,
  });
  final bool accepted;
  final String reasonCode, reason, status;
  final String? requestId, statusToken;
  final Track track;
  final RequestEta eta;
  final int? retryAfterSeconds;

  factory RequestSubmission.fromJson(Json j) => RequestSubmission(
    accepted: _bool(j['accepted']),
    reasonCode: _str(j['reason_code']) ?? '',
    reason: _str(j['reason']) ?? '',
    requestId: _str(j['request_id']),
    statusToken: _str(j['status_token']),
    status: _str(j['status']) ?? '',
    track: Track.fromJson(_obj(j['track']) ?? const {}),
    eta: RequestEta.fromJson(_obj(j['eta'])),
    retryAfterSeconds: _int(j['retry_after_seconds']),
  );
}

class RequestStatus {
  RequestStatus(this.requestId, this.status, this.track, this.eta, this.statusReason);
  final String requestId, status;
  final Track track;
  final RequestEta eta;
  final String? statusReason;
  bool get isFinal => status == 'played' || status == 'expired' || status == 'rejected' || status == 'cancelled';
  factory RequestStatus.fromJson(Json j) => RequestStatus(
    _str(j['request_id']) ?? '',
    _str(j['status']) ?? '',
    Track.fromJson(_obj(j['track']) ?? const {}),
    RequestEta.fromJson(_obj(j['eta'])),
    _str(j['status_reason']),
  );
}

class TrackAvailability {
  TrackAvailability(this.requestable, this.reason, this.state, this.eta);
  final bool requestable;
  final String? reason;
  final String state;
  final RequestEta eta;
  factory TrackAvailability.fromJson(Json j) =>
      TrackAvailability(_bool(j['requestable']), _str(j['reason']), _str(j['state']) ?? '', RequestEta.fromJson(_obj(j['eta'])));
}

class WallItem {
  WallItem(this.entryId, this.status, this.requestedAtEpoch, this.dedication, this.track, this.voteScore);
  final String entryId, status;
  final int requestedAtEpoch, voteScore;
  final Dedication? dedication;
  final Track track;
  factory WallItem.fromJson(Json j) => WallItem(
    _str(j['entry_id']) ?? _str(j['play_id']) ?? '',
    _str(j['status']) ?? 'played',
    _int(j['requested_at_epoch']) ?? _int(j['played_at_epoch']) ?? 0,
    Dedication.fromJson(_obj(j['dedication'])) ?? Dedication.fromJson({'name': j['name'], 'message': j['message']}),
    Track.fromJson(_obj(j['track']) ?? const {}),
    _int(j['vote_score']) ?? 0,
  );
}

class RatingState {
  const RatingState(this.rating, this.hot);
  final String? rating; // 'up' | 'down' | null
  final bool hot;
  factory RatingState.fromJson(Json j) => RatingState(_str(j['rating']), _bool(j['hot']));
}

class LosslessTier {
  LosslessTier({required this.available, required this.notice, required this.mbPerHour, this.defaultMbPerHour});
  final bool available;
  final String notice;
  final int mbPerHour;
  final int? defaultMbPerHour;
  factory LosslessTier.fromJson(Json j) {
    final opt = _obj(j['opt_in']) ?? const {};
    final def = _obj(opt['default_stream']);
    return LosslessTier(
      available: _bool(j['available']),
      notice: _str(opt['notice']) ?? '',
      mbPerHour: _int(opt['measured_mb_per_hour']) ?? _int(opt['estimated_mb_per_hour']) ?? 0,
      defaultMbPerHour: _int(def?['estimated_mb_per_hour']) ?? _int(def?['mb_per_hour']),
    );
  }
}

class MarathonNomination {
  MarathonNomination({
    required this.id,
    required this.artist,
    this.artworkUrl,
    required this.votes,
    required this.votesRequired,
    required this.status,
    required this.expiresAtEpoch,
  });
  final String id;
  final MarathonArtistRef artist;
  final String? artworkUrl;
  final int votes, votesRequired, expiresAtEpoch;
  final String status;
  factory MarathonNomination.fromJson(Json j) => MarathonNomination(
    id: _str(j['nomination_id']) ?? '',
    artist: MarathonArtistRef.fromJson(_obj(j['artist'])),
    artworkUrl: artworkSrc(_str(j['artwork_url'])),
    votes: _int(j['votes']) ?? 0,
    votesRequired: _int(j['votes_required']) ?? 2,
    status: _str(j['status']) ?? 'open',
    expiresAtEpoch: _int(j['expires_at_epoch']) ?? 0,
  );
}

class MarathonState {
  MarathonState({required this.accepting, required this.votesRequired, this.current, required this.queue, required this.nominations});
  final bool accepting;
  final int votesRequired;
  final MarathonBlock? current;
  final List<MarathonBlock> queue;
  final List<MarathonNomination> nominations;
  factory MarathonState.fromJson(Json j) {
    final policy = _obj(j['policy']) ?? const {};
    return MarathonState(
      accepting: policy['accepting'] != false,
      votesRequired: _int(policy['votes_required']) ?? 2,
      current: _obj(j['current']) == null ? null : MarathonBlock.fromJson(_obj(j['current'])!),
      queue: _list(j['queue'], MarathonBlock.fromJson),
      nominations: _list(j['nominations'], MarathonNomination.fromJson),
    );
  }
}

class MarathonCandidate {
  MarathonCandidate(this.artist, this.eligible, this.reason, this.artworkUrl);
  final MarathonArtistRef artist;
  final bool eligible;
  final String? reason, artworkUrl;
  factory MarathonCandidate.fromJson(Json j) => MarathonCandidate(
    _obj(j['artist']) != null
        ? MarathonArtistRef.fromJson(_obj(j['artist']))
        : MarathonArtistRef(_str(j['artist_key']) ?? '', _str(j['name']) ?? ''),
    j['eligible'] != false,
    _str(j['reason']),
    artworkSrc(_str(j['artwork_url'])),
  );
}

/// `{ accepted, reason }` answers (votes, nominations). The reason is shown as it is.
class WriteResult {
  WriteResult(this.accepted, this.reason);
  final bool accepted;
  final String? reason;
  factory WriteResult.fromJson(Json j) => WriteResult(_bool(j['accepted']) || _bool(j['counted']), _str(j['reason']));
}

double? numOf(dynamic v) => _num(v);
