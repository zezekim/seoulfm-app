import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:seoulfm/data/app_language.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/data/channels.dart';
import 'package:seoulfm/state/session.dart';

/// The radio (the app's `PlayerEngine`): one player for the whole app, living in the
/// audio service so it outlives every screen, keeps playing in the background, and
/// answers the lock screen, Bluetooth, CarPlay's Now Playing and Android Auto.
///
/// * Loads `/v3/streams/{stream}/manifest.m3u8`; the main channel falls back to the
///   Worker manifest. Segment tokens expire: recovery always reloads the manifest.
/// * A player whose playlist went stale (paused or idle over [_freshFor]) is reloaded on
///   play, so the listener always lands near live.
/// * Volume is ramped on play, pause and channel switches: the audio never clicks.
/// * Sends `/v3/listeners/heartbeat` while playing.
class RadioHandler extends BaseAudioHandler {
  RadioHandler() {
    _init();
  }

  /// How far behind the live edge the listener plays: the playlist's `EXT-X-START` (and its
  /// `HOLD-BACK`, once the server sends one). The players honour it natively.
  static const liveOffset = Duration(seconds: 12);

  final AudioPlayer _player = AudioPlayer(
    audioLoadConfiguration: const AudioLoadConfiguration(
      androidLoadControl: AndroidLoadControl(
        minBufferDuration: Duration(seconds: 20),
        maxBufferDuration: Duration(seconds: 50),
        // Play once a segment is in hand; after a stall, wait for two.
        bufferForPlaybackDuration: Duration(milliseconds: 3000),
        bufferForPlaybackAfterRebufferDuration: Duration(seconds: 8),
      ),
      // ExoPlayer otherwise speeds up (up to 3%) toward the live edge, where it has nothing
      // buffered and every late segment is a stall. Hold real time; after a stall, back off.
      androidLivePlaybackSpeedControl: AndroidLivePlaybackSpeedControl(
        fallbackMinPlaybackSpeed: 1.0,
        fallbackMaxPlaybackSpeed: 1.0,
        targetLiveOffsetIncrementOnRebuffer: Duration(seconds: 4),
      ),
      darwinLoadControl: DarwinLoadControl(preferredForwardBufferDuration: Duration(seconds: 30)),
    ),
  );

  static const _freshFor = Duration(seconds: 15);

  /// AAC qualities, best first. Playback starts at the top and steps down a rung when the
  /// connection can't keep up (two stalls within [_stallWindow], or a failed load); after
  /// [_retryUpAfter] at a lower rung, the next tune-in tries the top again.
  static const ladder = [320, 192, 128, 48];
  static const _stallWindow = Duration(seconds: 60);
  static const _retryUpAfter = Duration(minutes: 5);
  static const _settle = Duration(seconds: 20);
  DateTime? _loadedAt;
  int _rung = 0;
  DateTime? _steppedDownAt;
  final List<DateTime> _stalls = [];

  /// The AAC quality playing, in kbps (null while lossless or on the fallback manifest).
  final ValueNotifier<int?> aacKbps = ValueNotifier(null);
  static const _fadeIn = Duration(milliseconds: 600);
  static const _fadeOut = Duration(milliseconds: 300);

  // ── Wiring (set by `AppScope`) ──────────────────────────────────────────
  List<Channel> Function() channels = () => const [];
  void Function(String key) onTune = (_) {};
  Map<String, NowPlaying> Function() stationsNowPlaying = () => const {};

  // ── State the UI listens to ─────────────────────────────────────────────
  /// The listener wants sound (play pressed and not paused since).
  final ValueNotifier<bool> wantPlaying = ValueNotifier(false);
  final ValueNotifier<bool> buffering = ValueNotifier(false);

  /// Lossless is what is on (HIFI after the notice was accepted).
  final ValueNotifier<bool> losslessActive = ValueNotifier(false);

  /// Lossless failed and the player fell back to AAC ("Retry FLAC").
  final ValueNotifier<bool> losslessFailed = ValueNotifier(false);

  /// When uninterrupted playing on this station began (ratings open after 25 s).
  final ValueNotifier<DateTime?> listeningSince = ValueNotifier(null);
  final ValueNotifier<DateTime?> sleepAt = ValueNotifier(null);

  Channel? _channel;
  bool _losslessWanted = false;
  bool _loaded = false;
  DateTime? _freshAt;
  int _attempt = 0;
  bool _useFallback = false;
  Timer? _recoverTimer, _beatTimer, _sleepTimer;
  String? _lastBeatState;
  int _beatEvery = 30;
  DateTime? _startAt;
  int? _startupMs;
  int _rebuffers = 0;
  String? _loadedUrl;

  Channel? get channel => _channel;

  /// How much audio is buffered ahead of what is heard (diagnostics and tests).
  Duration get bufferAhead => _player.bufferedPosition - _player.position;

  /// Raw player clock, for diagnostics: position, buffered position, speed.
  String get debugClock => 'pos=${_player.position.inMilliseconds} buf=${_player.bufferedPosition.inMilliseconds} window=${_player.duration?.inMilliseconds}';

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    session.interruptionEventStream.listen((e) {
      if (e.begin && e.type != AudioInterruptionType.duck) {
        if (wantPlaying.value) _player.pause();
      } else if (!e.begin && e.type == AudioInterruptionType.pause && wantPlaying.value) {
        play();
      }
    });
    session.becomingNoisyEventStream.listen((_) => pause());

    _player.playbackEventStream.listen((_) => _broadcast(), onError: (Object e, StackTrace _) => _recover('$e'));
    _player.playerStateStream.listen((s) {
      final wasBuffering = buffering.value;
      buffering.value =
          wantPlaying.value && (s.processingState == ProcessingState.loading || s.processingState == ProcessingState.buffering);
      if (s.playing && s.processingState == ProcessingState.ready) {
        _attempt = 0;
        _freshAt = DateTime.now();
        listeningSince.value ??= DateTime.now();
        if (_startAt != null) {
          _startupMs = DateTime.now().difference(_startAt!).inMilliseconds;
          _startAt = null;
        }
      } else if (buffering.value && !wasBuffering && _startAt == null) {
        _rebuffers++;
        _onStall();
      }
      if (s.processingState == ProcessingState.completed && wantPlaying.value) _recover('completed');
      _broadcast();
      _heartbeatOnChange();
    });
    // Keep the playlist marked fresh while it plays.
    Timer.periodic(const Duration(seconds: 5), (_) {
      if (_player.playing) _freshAt = DateTime.now();
    });
    _broadcast();
  }

  // ── Channels ────────────────────────────────────────────────────────────

  /// Tunes to [c]. While playing, switches with a short dip and keeps playing; while idle,
  /// only remembers it (and drops a stale player).
  Future<void> setChannel(Channel c, {bool lossless = false}) async {
    final same = _channel?.key == c.key && _losslessWanted == lossless;
    _channel = c;
    _losslessWanted = lossless && c.lossless;
    losslessFailed.value = false;
    _useFallback = false;
    if (same) return;
    _maybeStepUp();
    _stalls.clear();
    listeningSince.value = null;
    _publishIdleItem();
    if (wantPlaying.value) {
      await _fade(0, _fadeOut);
      await _load();
      await _player.play();
      unawaited(_fade(1, _fadeIn));
    } else {
      _loaded = false;
      await _player.stop();
    }
    _heartbeatOnChange(force: true);
  }

  /// Retry the lossless tier after a fallback.
  Future<void> retryLossless() async {
    losslessFailed.value = false;
    _losslessWanted = true;
    if (wantPlaying.value) {
      await _load();
      await _player.play();
    } else {
      _loaded = false;
    }
  }

  String _url() {
    final c = _channel!;
    if (_losslessWanted && !losslessFailed.value) return c.losslessManifest;
    if (_useFallback && c.fallbackManifest != null) return c.fallbackManifest!;
    return c.variant(ladder[_rung]);
  }

  /// A stall while playing: two within a minute means this quality is too much for the
  /// connection, so reload a rung lower (quietly, without a fade).
  void _onStall() {
    final now = DateTime.now();
    // The first seconds after a load settle the buffer; stalls there say nothing about the
    // connection (and were stepping the quality down on start-up).
    if (_loadedAt != null && now.difference(_loadedAt!) < _settle) return;
    _stalls
      ..add(now)
      ..removeWhere((t) => now.difference(t) > _stallWindow);
    if (_stalls.length < 2 || !_stepDown()) return;
    _stalls.clear();
    debugPrint('radio: stalling, down to ${ladder[_rung]} kbps');
    unawaited(() async {
      await _load();
      if (_loaded && wantPlaying.value) await _player.play();
    }());
  }

  /// One rung lower, if there is one (AAC only).
  bool _stepDown() {
    if (losslessActive.value || _rung >= ladder.length - 1) return false;
    _rung++;
    _steppedDownAt = DateTime.now();
    return true;
  }

  /// A new tune-in after a while at a lower rung tries the best quality again.
  void _maybeStepUp() {
    if (_rung > 0 && _steppedDownAt != null && DateTime.now().difference(_steppedDownAt!) > _retryUpAfter) {
      _rung = 0;
      _steppedDownAt = null;
    }
  }

  Future<void> _load() async {
    if (_channel == null) return;
    final url = _url();
    _loadedUrl = url;
    _loadedAt = DateTime.now();
    losslessActive.value = url == _channel!.losslessManifest;
    aacKbps.value = url == _channel!.variant(ladder[_rung]) ? ladder[_rung] : null;
    _startAt = DateTime.now();
    try {
      await _player.setAudioSource(HlsAudioSource(Uri.parse(url)), preload: true);
      _loaded = true;
      _freshAt = DateTime.now();
    } catch (e) {
      _loaded = false;
      if (_loadedUrl == url) _recover('$e');
    }
  }

  /// Stream errors, expired segment tokens (403), a playlist that ended: reload the
  /// manifest with backoff. Lossless falls back to AAC; the main channel alternates
  /// with its Worker manifest. Never retry a segment URL.
  void _recover(String why) {
    if (!wantPlaying.value || _channel == null) return;
    debugPrint('radio: recover ($why)');
    if (losslessActive.value) {
      losslessFailed.value = true;
      losslessActive.value = false;
    } else if (_attempt > 0 && !_stepDown() && _channel!.fallbackManifest != null) {
      // The first error just reloads (an expired token, say); repeated ones step down a
      // rung, and with none left, alternate with the Worker manifest.
      _useFallback = !_useFallback;
    }
    _recoverTimer?.cancel();
    final wait = Duration(milliseconds: min(30000, 1000 * pow(2, _attempt).toInt()));
    _attempt++;
    _recoverTimer = Timer(wait, () async {
      if (!wantPlaying.value) return;
      await _load();
      if (_loaded) await _player.play();
    });
  }

  // ── Transport ───────────────────────────────────────────────────────────

  @override
  Future<void> play() async {
    if (_channel == null) {
      final list = channels();
      if (list.isEmpty) return;
      _channel = list.first;
    }
    wantPlaying.value = true;
    _broadcast();
    final stale = _freshAt == null || DateTime.now().difference(_freshAt!) > _freshFor;
    if (!_loaded || stale || _loadedUrl != _url()) {
      await _player.setVolume(0);
      await _load();
    }
    if (!wantPlaying.value) return;
    unawaited(_player.play());
    unawaited(_fade(1, _fadeIn));
    _heartbeatOnChange(force: true);
  }

  @override
  Future<void> pause() async {
    wantPlaying.value = false;
    listeningSince.value = null;
    _recoverTimer?.cancel();
    await _fade(0, _fadeOut);
    await _player.pause();
    _broadcast();
    _heartbeatOnChange(force: true);
  }

  @override
  Future<void> stop() async {
    wantPlaying.value = false;
    listeningSince.value = null;
    _recoverTimer?.cancel();
    await _player.stop();
    _loaded = false;
    _broadcast();
    _heartbeatOnChange(force: true);
    await super.stop();
  }

  Future<void> toggle() => wantPlaying.value ? pause() : play();

  /// Steering-wheel and headset skip buttons change station.
  @override
  Future<void> skipToNext() => _step(1);
  @override
  Future<void> skipToPrevious() => _step(-1);

  Future<void> _step(int d) async {
    final list = channels().where((c) => c.tunable).toList();
    if (list.isEmpty) return;
    final i = list.indexWhere((c) => c.key == _channel?.key);
    onTune(list[(i + d) % list.length].key);
  }

  Future<void> _fade(double to, Duration over) async {
    const steps = 10;
    final from = _player.volume;
    for (var i = 1; i <= steps; i++) {
      await _player.setVolume(from + (to - from) * i / steps);
      await Future<void>.delayed(over ~/ steps);
    }
  }

  // ── Sleep timer ─────────────────────────────────────────────────────────

  void setSleepTimer(Duration? after) {
    _sleepTimer?.cancel();
    if (after == null) {
      sleepAt.value = null;
      return;
    }
    sleepAt.value = DateTime.now().add(after);
    _sleepTimer = Timer(after, () async {
      sleepAt.value = null;
      await _fade(0, const Duration(seconds: 8));
      await pause();
    });
  }

  // ── What the system shows ───────────────────────────────────────────────

  void _broadcast() {
    final s = _player.playerState;
    final processing = switch (s.processingState) {
      ProcessingState.idle => wantPlaying.value ? AudioProcessingState.loading : AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.buffering,
    };
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          wantPlaying.value ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.playFromMediaId, MediaAction.playFromSearch},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: _channel == null ? AudioProcessingState.idle : processing,
        playing: wantPlaying.value,
      ),
    );
  }

  void _publishIdleItem() {
    final c = _channel;
    if (c == null) return;
    mediaItem.add(
      MediaItem(
        id: c.key,
        title: isolate('SeoulFM ${c.rawName}'),
        artist: c.localTagline,
        album: isolate('SeoulFM ${c.rawName}'),
        artUri: _stationArt(c),
      ),
    );
  }

  /// The heard track on the tuned channel (from `NowPlayingController`).
  void updateTrack(Channel c, Track? t) {
    if (_channel?.key != c.key) return;
    if (t == null) return _publishIdleItem();
    final art = t.artworkUrl ?? _stationArt(c)?.toString();
    mediaItem.add(
      MediaItem(
        id: c.key,
        title: t.displayTitle,
        artist: t.displayArtist,
        album: isolate('SeoulFM ${c.rawName}'),
        artUri: art == null ? null : Uri.parse(art),
        extras: {'track_id': t.id},
      ),
    );
  }

  Uri? _stationArt(Channel c) {
    final art = stationsNowPlaying()[c.key]?.current?.artworkUrl ?? c.live?.artworkUrl;
    return art == null ? null : Uri.parse(art);
  }

  // ── Android Auto / Automotive browse tree ───────────────────────────────

  static const _stationsFolder = 'stations';

  MediaItem _stationItem(Channel c) {
    final np = stationsNowPlaying()[c.key]?.current;
    return MediaItem(
      id: c.key,
      title: c.name,
      displayTitle: isolate('SeoulFM ${c.rawName}'),
      displaySubtitle: np != null ? '${np.displayTitle} · ${np.displayArtist}' : c.localTagline,
      artist: np?.displayArtist,
      album: c.genre,
      artUri: _stationArt(c),
      playable: true,
    );
  }

  @override
  Future<List<MediaItem>> getChildren(String parentMediaId, [Map<String, dynamic>? options]) async {
    final live = channels().where((c) => c.tunable).toList();
    switch (parentMediaId) {
      case AudioService.browsableRootId:
        return [const MediaItem(id: _stationsFolder, title: 'Stations', playable: false)];
      case AudioService.recentRootId:
        return [if (_channel != null) _stationItem(_channel!)];
      case _stationsFolder:
        return live.map(_stationItem).toList();
      default:
        return const [];
    }
  }

  @override
  Future<MediaItem?> getMediaItem(String mediaId) async {
    for (final c in channels()) {
      if (c.key == mediaId) return _stationItem(c);
    }
    return null;
  }

  @override
  Future<void> playFromMediaId(String mediaId, [Map<String, dynamic>? extras]) async {
    if (channels().any((c) => c.key == mediaId && c.tunable)) {
      onTune(mediaId);
      await play();
    }
  }

  /// "Hey Google, play SeoulFM Ballad": matches a station name, else plays the current one.
  @override
  Future<void> playFromSearch(String query, [Map<String, dynamic>? extras]) async {
    final q = query.toLowerCase().replaceAll('seoulfm', '').replaceAll('seoul fm', '').trim();
    if (q.isNotEmpty) {
      for (final c in channels().where((c) => c.tunable)) {
        if (c.name.toLowerCase().contains(q) ||
            q.contains(c.name.toLowerCase()) ||
            (c.genre ?? '').toLowerCase().contains(q)) {
          onTune(c.key);
          break;
        }
      }
    }
    await play();
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'tune' && extras?['key'] is String) return playFromMediaId(extras!['key'] as String);
  }

  @override
  Future<void> onTaskRemoved() async {
    if (!wantPlaying.value) await stop();
  }

  // ── Listener heartbeat ──────────────────────────────────────────────────

  String get _beatState {
    if (wantPlaying.value) return _player.playing && !buffering.value ? 'playing' : 'buffering';
    return _player.processingState == ProcessingState.idle ? 'stopped' : 'paused';
  }

  void _heartbeatOnChange({bool force = false}) {
    final state = _beatState;
    if (!force && state == _lastBeatState) return;
    _lastBeatState = state;
    _beat();
    _rearm();
  }

  void _rearm() {
    _beatTimer?.cancel();
    if (_lastBeatState == 'playing' || _lastBeatState == 'buffering') {
      _beatTimer = Timer.periodic(Duration(seconds: _beatEvery), (_) => _beat());
    }
  }

  Future<void> _beat() async {
    final c = _channel;
    if (c == null) return;
    try {
      final ack = await api.heartbeat({
        'session_id': Session.sessionId,
        'station': c.key,
        'state': _beatState,
        'player': kIsWeb ? 'flutter-web' : 'flutter-${defaultTargetPlatform.name.toLowerCase()}',
        'app_version': Config.appVersion,
        // AAC rung unknown on the native players; the API keeps the last non-null value.
        'bitrate_kbps': null,
        'startup_ms': _startupMs,
        'rebuffer_count': _rebuffers,
        'visibility': 'visible',
        'volume': _player.volume.clamp(0, 1),
        'muted': false,
      });
      final next = ack['next_heartbeat_seconds'];
      if (next is num && next >= 5 && next.toInt() != _beatEvery) {
        _beatEvery = next.toInt();
        _rearm();
      }
    } catch (_) {}
  }
}
