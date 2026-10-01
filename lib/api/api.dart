import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/config.dart';

/// A non-2xx v3 response. Branch on [code], not the message.
class ApiError implements Exception {
  ApiError(this.status, this.code, this.message, [this.detail = const {}]);
  final int status;
  final String code;
  final String message;
  final Json detail;

  int? get retryAfterSeconds => detail['retry_after_seconds'] is num ? (detail['retry_after_seconds'] as num).toInt() : null;
  String? get reason => detail['reason'] is String ? detail['reason'] as String : null;

  @override
  String toString() => message;
}

const defaultStation = 'seoulfm';

/// Endpoints not scoped to a station (`STATIONLESS` in lib/api.ts).
final _stationless = RegExp(r'^/(stations|streams|keys|version|requests/[^/]+|tracks/[^/]+/(lyrics|rating)|tracks/hot|featured)(/|$)');

/// The v3 client (`api.*` in lib/api.ts). The tuned channel is appended as `?station=`
/// to every station-scoped endpoint, so charts, search and requests follow it.
class Api {
  Api._();
  static final Api instance = Api._();

  final http.Client _client = http.Client();
  String activeStation = defaultStation;

  Map<String, String> get _headers => {
    if (Config.apiKey.isNotEmpty) 'X-API-Key': Config.apiKey,
    'Accept': 'application/json',
    'User-Agent': 'SeoulFM-App/${AppBuild.version}',
  };

  Uri url(String endpoint, [Map<String, Object?>? params]) {
    final q = <String, String>{};
    params?.forEach((k, v) {
      if (v != null && v != '') q[k] = '$v';
    });
    if (!q.containsKey('station') && activeStation != defaultStation && !_stationless.hasMatch(endpoint)) {
      q['station'] = activeStation;
    }
    final u = Uri.parse('${Config.apiBase}$endpoint');
    return q.isEmpty ? u : u.replace(queryParameters: q);
  }

  Json _parse(http.Response res) {
    Object? body;
    try {
      body = res.body.isEmpty ? null : jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      throw ApiError(res.statusCode, 'invalid_response', 'API returned invalid JSON (${res.statusCode})');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final err = body is Map ? (body['error'] as Map?)?.cast<String, dynamic>() : null;
      throw ApiError(
        res.statusCode,
        (err?['code'] as String?) ?? 'http_error',
        (err?['message'] as String?) ?? 'API error: ${res.statusCode}',
        (err?['detail'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
    }
    return body is Map ? body.cast<String, dynamic>() : <String, dynamic>{};
  }

  Future<Json> get(String endpoint, [Map<String, Object?>? params]) async =>
      _parse(await _client.get(url(endpoint, params), headers: _headers).timeout(const Duration(seconds: 20)));

  Future<Json> post(String endpoint, Object body) async => _parse(
    await _client
        .post(url(endpoint), headers: {..._headers, 'Content-Type': 'application/json'}, body: jsonEncode(body))
        .timeout(const Duration(seconds: 20)),
  );

  String _e(String s) => Uri.encodeComponent(s);

  // ── Stations & streams ──────────────────────────────────────────────────
  Future<List<StationSummary>> stations() async =>
      ((await get('/stations'))['items'] as List? ?? []).map((e) => StationSummary.fromJson((e as Map).cast())).toList();
  Future<LosslessTier> losslessTier(String stream) async => LosslessTier.fromJson(await get('/streams/${_e(stream)}/lossless'));

  // ── Live ────────────────────────────────────────────────────────────────
  Future<NowPlaying> nowPlaying({String? station, int? at}) async =>
      NowPlaying.fromJson(await get('/now-playing', {'station': station, 'at': at}));
  Future<List<Track>> recent({int limit = 30, String? station}) async =>
      tracksOf(await get('/recent', {'limit': limit, 'station': station}));
  Future<List<Track>> upcoming({int limit = 12, String? station}) async =>
      tracksOf(await get('/upcoming', {'limit': limit, 'station': station}));
  Future<ListenerCount> listeners({String? station}) async => ListenerCount.fromJson(await get('/listeners', {'station': station}));
  Future<Json> heartbeat(Json body) => post('/listeners/heartbeat', body);

  // ── Charts ──────────────────────────────────────────────────────────────
  Future<List<Track>> weeklyChart({int limit = 40}) async => tracksOf(await get('/charts/weekly', {'limit': limit}));
  Future<List<Track>> trending({int limit = 30}) async => tracksOf(await get('/charts/trending', {'limit': limit}));
  Future<List<Track>> topRequested({int limit = 30, String period = 'week'}) async =>
      tracksOf(await get('/charts/top-requested', {'limit': limit, 'period': period}));
  Future<List<Track>> hotTracks({int limit = 30}) async => tracksOf(await get('/tracks/hot', {'limit': limit}));
  Future<List<ArtistSummary>> topArtists({int limit = 30, String period = 'week'}) async =>
      ((await get('/charts/top-artists', {'limit': limit, 'period': period}))['items'] as List? ?? [])
          .map((e) => ArtistSummary.fromJson((e as Map).cast()))
          .toList();

  // ── Tracks ──────────────────────────────────────────────────────────────
  Future<SearchResults> search(String q, {int limit = 20}) async =>
      SearchResults.fromJson(await get('/search', {'q': q, 'type': 'all', 'limit': limit}));
  Future<List<Track>> random({int limit = 24}) async => tracksOf(await get('/tracks/random', {'limit': limit}));
  Future<List<Track>> newTracks({int limit = 40, int? days}) async => tracksOf(await get('/tracks/new', {'limit': limit, 'days': days}));
  Future<TrackDetail> track(String id) async => TrackDetail.fromJson(await get('/tracks/${_e(id)}'));
  Future<Lyrics> lyrics(String id) async => Lyrics.fromJson(await get('/tracks/${_e(id)}/lyrics'));

  // ── Ratings ─────────────────────────────────────────────────────────────
  Future<RatingState> rating(String trackId, String listenerId) async =>
      RatingState.fromJson(await get('/tracks/${_e(trackId)}/rating', {'listener_id': listenerId}));
  Future<RatingState> rate(String trackId, Json body) async => RatingState.fromJson(await post('/tracks/${_e(trackId)}/rating', body));

  // ── Artists ─────────────────────────────────────────────────────────────
  Future<ArtistProfile> artist(String key) async => ArtistProfile.fromJson(await get('/artists/${_e(key)}'));

  // ── Requests ────────────────────────────────────────────────────────────
  Future<List<WallItem>> wall({int limit = 50}) async =>
      ((await get('/requests', {'limit': limit}))['items'] as List? ?? []).map((e) => WallItem.fromJson((e as Map).cast())).toList();
  Future<List<WallItem>> dedications({int limit = 20}) async =>
      ((await get('/dedications', {'limit': limit}))['items'] as List? ?? []).map((e) => WallItem.fromJson((e as Map).cast())).toList();
  Future<TrackAvailability> requestEta(String trackId) async =>
      TrackAvailability.fromJson(await get('/requests/eta', {'track_id': trackId}));
  Future<RequestSubmission> submitRequest(Json body) async => RequestSubmission.fromJson(await post('/requests', body));
  Future<RequestStatus> requestStatus(String id, String token) async =>
      RequestStatus.fromJson(await get('/requests/${_e(id)}', {'token': token}));

  // ── Marathon ────────────────────────────────────────────────────────────
  Future<MarathonState> marathon({String? station}) async => MarathonState.fromJson(await get('/marathon', {'station': station}));
  Future<List<MarathonCandidate>> marathonArtists(String q) async =>
      ((await get('/marathon/artists', {'q': q, 'limit': 25}))['items'] as List? ?? [])
          .map((e) => MarathonCandidate.fromJson((e as Map).cast()))
          .toList();
  Future<WriteResult> marathonNominate(Json body) async => WriteResult.fromJson(await post('/marathon/nominations', body));
  Future<WriteResult> marathonVote(String nominationId, Json body) async =>
      WriteResult.fromJson(await post('/marathon/nominations/${_e(nominationId)}/votes', body));

  // ── SSE (keyless) ───────────────────────────────────────────────────────
  Uri stationEvents(String station, {int recentLimit = 30, int upcomingLimit = 12}) =>
      url('/events', {'station': station == defaultStation ? null : station, 'recent_limit': recentLimit, 'upcoming_limit': upcomingLimit});
  Uri requestEvents(String id, String token) => url('/requests/${_e(id)}/events', {'token': token});
}

final api = Api.instance;
