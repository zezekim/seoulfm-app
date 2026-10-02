import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:seoulfm/l10n/app_localizations.dart';
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

  /// How far behind the live edge the listener plays: the playlists' `HOLD-BACK` and
  /// `EXT-X-START` (24 s since 2026-10-01). The players honour them natively.
  static const liveOffset = Duration(seconds: 24);

  static const _loadConfiguration = AudioLoadConfiguration(
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
  );

  /// The player that is heard: everything that watches playback (the lock screen, buffering,
  /// stalls, recovery, beats) follows it, and ignores the players of a crossfade.
  ///
  /// Players share the app's one audio session: on Android, audio_session holds a single focus
  /// request (a second `play` finds it held and asks for nothing), and just_audio never
  /// abandons focus on stop or dispose; on iOS both players mix in the one active session.
  late AudioPlayer _player = _newPlayer();

  /// Every player is made alike (a crossfade plays two at once); each is watched until retired.
  AudioPlayer _newPlayer() {
    final p = AudioPlayer(audioLoadConfiguration: _loadConfiguration);
    _subs[p] = [
      p.playbackEventStream.listen((_) {
        if (p == _player) _broadcast();
      }, onError: (Object e, StackTrace _) => _onError(p, e)),
      p.playerStateStream.listen((s) {
        if (p == _player) _onState(s);
      }),
    ];
    return p;
  }

  final Map<AudioPlayer, List<StreamSubscription<Object?>>> _subs = {};

  /// Stops and releases a player that is no longer heard, after an optional fade.
  Future<void> _retire(AudioPlayer p, {Duration fade = Duration.zero}) async {
    final subs = _subs.remove(p);
    if (subs == null) return;
    if (fade > Duration.zero) await _ramp(p, 0, fade);
    for (final s in subs) {
      await s.cancel();
    }
    await p.dispose();
  }

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

  /// The listener's quality setting: null for Auto (the ladder above), or one of its rungs,
  /// held whatever the connection does. Kept on the device.
  final ValueNotifier<int?> quality = ValueNotifier(_storedQuality());
  static const _qualityKey = 'seoulfm-quality';

  static int? _storedQuality() {
    final q = Session.prefs.getInt(_qualityKey);
    return ladder.contains(q) ? q : null;
  }

  /// Sets [quality] (null for Auto). While AAC plays, it switches at once.
  Future<void> setQuality(int? kbps) async {
    if (kbps != null && !ladder.contains(kbps)) return;
    if (kbps == quality.value) return;
    quality.value = kbps;
    kbps == null ? await Session.prefs.remove(_qualityKey) : await Session.prefs.setInt(_qualityKey, kbps);
    _rung = 0;
    _steppedDownAt = null;
    _stalls.clear();
    if (!wantPlaying.value || losslessActive.value) return;
    await _load();
    if (_loaded && wantPlaying.value) await _player.play();
  }

  int get _kbps => quality.value ?? ladder[_rung];
  static const _fadeIn = Duration(milliseconds: 600);
  static const _fadeOut = Duration(milliseconds: 300);

  // ── Wiring (set by `AppScope`) ──────────────────────────────────────────
  List<Channel> Function() channels = () => const [];
  void Function(String key) onTune = (_) {};
  Map<String, NowPlaying> Function() stationsNowPlaying = () => const {};

  /// A car (Android Auto / Automotive) is browsing the stations: their covers and songs should
  /// be fetched even with no phone screen (`AppState` polls the stations meanwhile).
  void Function() onCarBrowse = () {};

  /// Tells a browsing car the stations' list changed (new covers, new songs).
  final _stationsChanged = BehaviorSubject<Map<String, dynamic>>.seeded(const {});
  void stationsUpdated() => _stationsChanged.add(const {});

  @override
  ValueStream<Map<String, dynamic>> subscribeToChildren(String parentMediaId) =>
      parentMediaId == _stationsFolder ? _stationsChanged : super.subscribeToChildren(parentMediaId);

  /// Artwork as the system media UIs can load it. Android Auto and Automotive only take
  /// content:// URIs the app serves (`ArtProvider`), never web links; iOS takes the link.
  static Uri? _systemArt(String? url) {
    if (url == null || url.isEmpty) return null;
    if (defaultTargetPlatform != TargetPlatform.android || !url.startsWith('https://')) return Uri.parse(url);
    return Uri(scheme: 'content', host: 'com.seoulfm.seoulfm.art', path: '/cover', queryParameters: {'u': url});
  }

  /// The listener's position in the heard song, ms (`NowPlayingController.positionMs`): the
  /// lock screen's progress and time left. The player's own clock is the stream's, not the song's.
  int? Function() songPositionMs = () => null;
  String? _publishedTrack;

  // ── State the UI listens to ─────────────────────────────────────────────
  /// The listener wants sound (play pressed and not paused since).
  final ValueNotifier<bool> wantPlaying = ValueNotifier(false);
  final ValueNotifier<bool> buffering = ValueNotifier(false);

  /// Lossless is what is on (HIFI after the notice was accepted).
  final ValueNotifier<bool> losslessActive = ValueNotifier(false);

  /// Lossless failed and the player fell back to AAC ("Retry FLAC").
  final ValueNotifier<bool> losslessFailed = ValueNotifier(false);

  /// The stream has failed to load several times running: the listener pressed play and hears
  /// nothing, so say so (the radio keeps retrying meanwhile; `retryNow` tries at once).
  final ValueNotifier<bool> streamFailing = ValueNotifier(false);
  static const _failingAfter = 3;

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

  /// Analytics names for the heartbeat's `player`. Fixed: the dashboard groups by them.
  static const _playerName = {TargetPlatform.iOS: 'flutter-ios', TargetPlatform.android: 'flutter-android'};

  /// The session has sent a beat (so the next fresh play starts a new one), and when it paused.
  bool _sessionBeaten = false;
  DateTime? _pausedAt;

  /// A pause longer than this, or a stop, ends the listening session.
  static const _sessionGap = Duration(minutes: 30);

  /// Interrupted by the system (a call, another app's audio): reported as paused.
  bool _interrupted = false;

  /// What the device is on (`net_type`), kept current by connectivity_plus.
  String? _netType;

  /// Whether the app is on screen (the heartbeat's `visibility`); set by `AppState`.
  bool appVisible = true;
  int _beatEvery = 30;
  DateTime? _startAt;
  int? _startupMs;
  int _rebuffers = 0;
  String? _loadedUrl;

  Channel? get channel => _channel;

  /// How much audio is buffered ahead of what is heard (diagnostics and tests).
  Duration get bufferAhead => _player.bufferedPosition - _player.position;

  /// Every player alive (heard, crossfading in or out) and the station it holds, for tests.
  @visibleForTesting
  List<({String? url, bool heard, bool playing, double volume})> get debugPlayers => [
    for (final p in _subs.keys)
      (
        url: (p.audioSource as UriAudioSource?)?.uri.toString(),
        heard: p == _player,
        playing: p.playing,
        volume: p.volume,
      ),
  ];

  /// Raw player clock, for diagnostics: position, buffered position, speed.
  String get debugClock => 'pos=${_player.position.inMilliseconds} buf=${_player.bufferedPosition.inMilliseconds} window=${_player.duration?.inMilliseconds}';

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    session.interruptionEventStream.listen((e) {
      if (e.begin && e.type != AudioInterruptionType.duck) {
        if (wantPlaying.value) {
          _interrupted = true;
          _cancelSwitch();
          _player.pause();
          _heartbeatOnChange(force: true);
        }
      } else if (!e.begin && e.type == AudioInterruptionType.pause && wantPlaying.value) {
        _interrupted = false;
        play();
      } else if (!e.begin) {
        _interrupted = false;
      }
    });
    _watchNetwork();
    session.becomingNoisyEventStream.listen((_) => pause());

    // Keep the playlist marked fresh while it plays.
    Timer.periodic(const Duration(seconds: 5), (_) {
      if (_player.playing) _freshAt = DateTime.now();
    });
    _broadcast();
  }

  /// The heard player's state.
  void _onState(PlayerState s) {
    final wasBuffering = buffering.value;
    buffering.value =
        wantPlaying.value && (s.processingState == ProcessingState.loading || s.processingState == ProcessingState.buffering);
    if (s.playing && s.processingState == ProcessingState.ready) {
      _attempt = 0;
      streamFailing.value = false;
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
  }

  void _onError(AudioPlayer p, Object e) {
    if (p == _incoming) {
      // The next station failed to load: the switch cuts over instead.
      final ready = _incomingReady;
      if (ready != null && !ready.isCompleted) ready.complete(false);
      return;
    }
    if (p != _player) return;
    // A preload failed: load afresh on play.
    if (!wantPlaying.value) _loaded = false;
    _recover('$e');
  }

  // ── Channels ────────────────────────────────────────────────────────────

  /// Tunes to [c]. While playing, crossfades to it (see [_crossfade]); while idle, only
  /// remembers it (and gets it ready, see [warmUp]).
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
    _cancelSwitch();
    if (wantPlaying.value && _audible && _loadedUrl == _url()) {
      // Back to the station still heard (skipped past and returned before the switch landed).
      unawaited(_fade(1, _fadeIn));
    } else if (wantPlaying.value && _audible) {
      _recoverTimer?.cancel();
      unawaited(_crossfade());
    } else if (wantPlaying.value) {
      // Nothing heard to fade from (loading, stalled, failing): load straight away.
      await _fade(0, _fadeOut);
      await _load();
      if (_loaded && wantPlaying.value) unawaited(_player.play());
      unawaited(_fade(1, _fadeIn));
    } else {
      _loaded = false;
      _warm = false;
      await _player.stop();
      warmUp();
    }
    _heartbeatOnChange(force: true);
  }

  bool get _audible => _loaded && _player.playing && _player.processingState == ProcessingState.ready;

  // ── Crossfade ───────────────────────────────────────────────────────────

  /// How long the next station may take to start before the switch cuts over instead.
  static const _switchWait = Duration(seconds: 8);
  static const _crossfadeFor = Duration(milliseconds: 1500);

  /// Skips in quick succession only load the last station.
  static const _switchSettle = Duration(milliseconds: 250);

  /// The next station, loading or playing silently until it is ready to fade in.
  AudioPlayer? _incoming;
  Completer<bool>? _incomingReady;

  /// The previous station, fading out under the new one.
  AudioPlayer? _outgoing;

  /// Bumped by every switch and anything that ends one (pause, stop, a reload): a switch
  /// whose number is no longer current stands down.
  int _switchGen = 0;
  bool _switching = false;

  /// Switches station like a radio DJ: the new station loads in a second player while the
  /// old one plays on, starts silently once it plays, and the two crossfade. Not ready within
  /// [_switchWait] (or failed): cut over as a plain reload, and recovery takes it from there.
  Future<void> _crossfade() async {
    final gen = ++_switchGen;
    _switching = true;
    await Future<void>.delayed(_switchSettle);
    if (gen != _switchGen) return;
    final url = _url();
    final lossless = url == _channel!.losslessManifest;
    final kbps = url == _channel!.variant(_kbps) ? _kbps : null;
    final started = DateTime.now();
    final next = _incoming = _newPlayer();
    final ready = _incomingReady = Completer<bool>();
    final sub = next.playerStateStream.listen((s) {
      if (s.playing && s.processingState == ProcessingState.ready && !ready.isCompleted) ready.complete(true);
    });
    unawaited(() async {
      try {
        await next.setVolume(0);
        await next.setAudioSource(HlsAudioSource(Uri.parse(url)), preload: true);
        if (gen == _switchGen) unawaited(next.play().catchError((Object _) {}));
      } catch (_) {
        if (!ready.isCompleted) ready.complete(false);
      }
    }());
    final ok = await ready.future.timeout(_switchWait, onTimeout: () => false);
    await sub.cancel();
    // Superseded, paused or reloaded meanwhile: whoever did that retired [next].
    if (gen != _switchGen) return;
    _incoming = null;
    _incomingReady = null;
    _switching = false;
    if (!ok) {
      _trail('switch not ready, cutting over');
      unawaited(_retire(next));
      await _fade(0, _fadeOut);
      if (gen != _switchGen || !wantPlaying.value) return;
      await _load();
      if (_loaded && wantPlaying.value) unawaited(_player.play());
      unawaited(_fade(1, _fadeIn));
      return;
    }
    // The new station plays: it becomes the radio, and the old one fades out under it.
    final now = DateTime.now();
    final old = _outgoing = _player;
    _player = next;
    _loaded = true;
    _warm = false;
    _loadedUrl = url;
    _loadedAt = started;
    _freshAt = now;
    losslessActive.value = lossless;
    aacKbps.value = kbps;
    _startAt = null;
    _startupMs = now.difference(started).inMilliseconds;
    debugPrint('radio: crossfading after ${_startupMs}ms');
    _onState(next.playerState);
    const steps = 15;
    final from = old.volume;
    for (var i = 1; i <= steps; i++) {
      // Superseded or paused mid-fade: that settles both players.
      if (gen != _switchGen) return;
      final t = i / steps;
      // Equal power: the sum sounds as loud as either station alone.
      await Future.wait([old.setVolume(from * cos(t * pi / 2)), next.setVolume(sin(t * pi / 2))]);
      await Future<void>.delayed(_crossfadeFor ~/ steps);
    }
    if (_outgoing == old) {
      _outgoing = null;
      await _retire(old);
    }
  }

  /// Ends any switch in progress: the next station is dropped, the old one faded out.
  void _cancelSwitch() {
    _switchGen++;
    _switching = false;
    final ready = _incomingReady;
    if (ready != null && !ready.isCompleted) ready.complete(false);
    _incomingReady = null;
    final incoming = _incoming, outgoing = _outgoing;
    _incoming = _outgoing = null;
    if (incoming != null) unawaited(_retire(incoming));
    if (outgoing != null) unawaited(_retire(outgoing, fade: _fadeOut));
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
    return c.variant(_kbps);
  }

  /// A stall while playing: two within a minute means this quality is too much for the
  /// connection, so reload a rung lower (quietly, without a fade).
  void _onStall() {
    // A switch is under way: the old station's stalls no longer matter.
    if (_switching) return;
    final now = DateTime.now();
    // The first seconds after a load settle the buffer; stalls there say nothing about the
    // connection (and were stepping the quality down on start-up).
    if (_loadedAt != null && now.difference(_loadedAt!) < _settle) return;
    _stalls
      ..add(now)
      ..removeWhere((t) => now.difference(t) > _stallWindow);
    if (_stalls.length < 2 || !_stepDown()) return;
    _stalls.clear();
    _trail('stalling, down to ${ladder[_rung]} kbps');
    unawaited(() async {
      await _load();
      if (_loaded && wantPlaying.value) await _player.play();
    }());
  }

  /// What the radio went through, in the log and as a breadcrumb on any crash report that follows
  /// (Sentry, when it is on): stalls, recoveries and cut-overs are what a report needs to explain.
  void _trail(String what) {
    debugPrint('radio: $what');
    Sentry.addBreadcrumb(Breadcrumb(category: 'radio', message: what, data: {'station': _channel?.key}));
  }

  /// One rung lower, if there is one (AAC on Auto only).
  bool _stepDown() {
    if (quality.value != null || losslessActive.value || _rung >= ladder.length - 1) return false;
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
    // A reload of the heard player wins over any switch in progress (it loads the latest station).
    _cancelSwitch();
    final url = _url();
    _loadedUrl = url;
    _loadedAt = DateTime.now();
    losslessActive.value = url == _channel!.losslessManifest;
    aacKbps.value = url == _channel!.variant(_kbps) ? _kbps : null;
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
    // A switch under way replaces the failing player, or cuts over if it can't.
    if (!wantPlaying.value || _channel == null || _switching) return;
    _trail('recover ($why)');
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
    if (_attempt >= _failingAfter) streamFailing.value = true;
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
    // Already crossfading to the tuned station (a station tapped while playing).
    if (wantPlaying.value && _switching) return;
    final fresh = _lastBeatState == 'stopped' ||
        (_pausedAt != null && DateTime.now().difference(_pausedAt!) > _sessionGap);
    if (_sessionBeaten && fresh) {
      Session.newListeningSession();
      _sessionBeaten = false;
      _rebuffers = 0;
    }
    _pausedAt = null;
    _interrupted = false;
    wantPlaying.value = true;
    final tapped = DateTime.now(), preloaded = _warm;
    _warm = false;
    _warmTimer?.cancel();
    _broadcast();
    // A preload under way is finished, not started over.
    final warming = _warming;
    if (warming != null) await warming;
    if (!wantPlaying.value) return;
    final stale = _freshAt == null || DateTime.now().difference(_freshAt!) > _freshFor;
    if (!_loaded || stale || _loadedUrl != _url()) {
      await _player.setVolume(0);
      await _load();
    } else if (preloaded) {
      // Startup counts from the tap, not from the preload.
      _startAt = tapped;
      await _player.setVolume(0);
    }
    if (!wantPlaying.value) return;
    unawaited(_player.play());
    unawaited(_fade(1, _fadeIn));
    _heartbeatOnChange(force: true);
    _watchStart();
  }

  /// A load can stall without an error (a weak connection, a playlist that never readies), and
  /// recovery only answers errors: if play hasn't really started within [_startDeadline],
  /// reload once, as a station change would.
  Timer? _startWatch;
  static const _startDeadline = Duration(seconds: 8);

  void _watchStart() {
    _startWatch?.cancel();
    _startWatch = Timer(_startDeadline, () {
      if (!wantPlaying.value || _switching || _interrupted) return;
      final s = _player.playerState;
      if (s.playing && s.processingState == ProcessingState.ready) return;
      _trail('start stalled (${s.processingState}), reloading');
      unawaited(() async {
        await _load();
        if (!_loaded || !wantPlaying.value) return;
        await _player.play();
        unawaited(_fade(1, _fadeIn));
      }());
    });
  }

  /// The listener's Retry on the "can't reach the stream" notice: try now, not at the next backoff.
  Future<void> retryNow() async {
    _recoverTimer?.cancel();
    _attempt = 0;
    streamFailing.value = false;
    if (!wantPlaying.value) return play();
    await _load();
    if (_loaded && wantPlaying.value) await _player.play();
  }

  @override
  Future<void> pause() async {
    wantPlaying.value = false;
    _startWatch?.cancel();
    _cancelSwitch();
    streamFailing.value = false;
    _pausedAt = DateTime.now();
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
    _startWatch?.cancel();
    _cancelSwitch();
    _warm = false;
    streamFailing.value = false;
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

  Future<void> _fade(double to, Duration over) => _ramp(_player, to, over);

  static Future<void> _ramp(AudioPlayer p, double to, Duration over) async {
    const steps = 10;
    final from = p.volume;
    for (var i = 1; i <= steps; i++) {
      await p.setVolume(from + (to - from) * i / steps);
      await Future<void>.delayed(over ~/ steps);
    }
  }

  // ── Instant play ────────────────────────────────────────────────────────

  /// Whether the player holds a preload the listener hasn't played.
  bool _warm = false;
  Future<void>? _warming;
  Timer? _warmTimer, _coolTimer;
  static const _warmSettle = Duration(milliseconds: 800);

  bool get _unmetered => _netType == 'wifi' || _netType == 'ethernet';

  /// Gets the tuned station ready while the app is open and the radio idle (at launch, back in
  /// the foreground, after tuning), so the first tap on play is heard at once. On Wi-Fi the
  /// player loads it paused; a preload is good for [_freshFor] (then play reloads to land
  /// near live anyway), so it is dropped after that rather than kept loading.
  void warmUp() {
    _warmTimer?.cancel();
    _warmTimer = Timer(_warmSettle, _warmNow);
  }

  Future<void> _warmNow() async {
    if (_channel == null || wantPlaying.value || !appVisible) return;
    // A preload of the station tuned before is still settling: try again after it.
    final warming = _warming;
    if (warming != null) return unawaited(warming.whenComplete(warmUp));
    // Audio only for the tuned station, and never on a metered connection (nothing is fetched
    // there: a playlist alone measured no faster start, as its server time is the cost).
    if (!_unmetered) return;
    // Only an idle player: a paused one stays as the listener left it (and on the lock screen).
    if (_player.processingState != ProcessingState.idle) return;
    _coolTimer?.cancel();
    _warm = true;
    final load = _warming = _load();
    await load;
    if (_warming == load) _warming = null;
    if (!_warm || wantPlaying.value) return;
    debugPrint('radio: preloaded ${_channel?.key}');
    _coolTimer = Timer(_freshFor, () {
      if (!_warm || wantPlaying.value) return;
      _warm = false;
      _loaded = false;
      _player.stop();
    });
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
        // A preload the listener hasn't played yet is not a paused radio (no notification, no card).
        processingState: _channel == null || (_warm && !wantPlaying.value) ? AudioProcessingState.idle : processing,
        playing: wantPlaying.value,
        // The system runs the clock on from here while playing; each event re-anchors it.
        updatePosition: Duration(milliseconds: songPositionMs() ?? 0),
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
    if (t == null) {
      _publishedTrack = null;
      return _publishIdleItem();
    }
    final art = t.artworkUrl ?? stationsNowPlaying()[c.key]?.current?.artworkUrl ?? c.live?.artworkUrl;
    mediaItem.add(
      MediaItem(
        id: c.key,
        title: t.displayTitle,
        artist: t.displayArtist,
        album: isolate('SeoulFM ${c.rawName}'),
        artUri: _systemArt(art),
        duration: t.durationMs == null ? null : Duration(milliseconds: t.durationMs!),
        extras: {'track_id': t.id},
      ),
    );
    // A new song restarts the lock screen's progress at the heard position.
    final key = '${c.key}/${t.id}/${t.durationMs}';
    if (key != _publishedTrack) {
      _publishedTrack = key;
      _broadcast();
    }
  }

  Uri? _stationArt(Channel c) => _systemArt(stationsNowPlaying()[c.key]?.current?.artworkUrl ?? c.live?.artworkUrl);

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
    onCarBrowse();
    final live = channels().where((c) => c.tunable).toList();
    switch (parentMediaId) {
      case AudioService.browsableRootId:
        return [MediaItem(id: _stationsFolder, title: lookupAppLocalizations(AppLanguage.locale).stationsFolder, playable: false)];
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

  /// Swiped away from recents (Android). A paused radio stops, and says so, so the session
  /// ends now rather than timing out on the dashboard.
  @override
  Future<void> onTaskRemoved() async {
    if (!wantPlaying.value) await stop();
  }

  /// The app is going away (process detached): tell the dashboard the session is over.
  Future<void> finalBeat() => _beat(state: 'stopped');

  void _watchNetwork() {
    String? name(List<ConnectivityResult> r) {
      if (r.contains(ConnectivityResult.wifi)) return 'wifi';
      if (r.contains(ConnectivityResult.ethernet)) return 'ethernet';
      if (r.contains(ConnectivityResult.mobile)) return 'cellular';
      if (r.contains(ConnectivityResult.bluetooth)) return 'bluetooth';
      if (r.contains(ConnectivityResult.none)) return 'none';
      return r.isEmpty ? null : 'other';
    }

    final c = Connectivity();
    void onNet(List<ConnectivityResult> r) {
      _netType = name(r);
      // Onto Wi-Fi: now the tuned station may be preloaded.
      if (_unmetered) warmUp();
    }

    c.checkConnectivity().then(onNet).catchError((_) {});
    c.onConnectivityChanged.listen(onNet, onError: (_) {});
  }

  // ── Listener heartbeat ──────────────────────────────────────────────────

  String get _beatState {
    if (_interrupted) return 'paused';
    if (wantPlaying.value) return _player.playing && !buffering.value ? 'playing' : 'buffering';
    return _warm || _player.processingState == ProcessingState.idle ? 'stopped' : 'paused';
  }

  DateTime? _lastBeatAt;

  void _heartbeatOnChange({bool force = false}) {
    final state = _beatState;
    // Nothing to report until the session has played (a tune-in at launch is not a listen).
    if (!_sessionBeaten && state != 'playing' && state != 'buffering') return;
    if (state == _lastBeatState) {
      if (!force) return;
      // The same state twice in a row (pause() and the player's own event): send it once.
      if (_lastBeatAt != null && DateTime.now().difference(_lastBeatAt!) < const Duration(seconds: 2)) return;
    }
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

  Future<void> _beat({String? state}) async {
    final c = _channel;
    if (c == null) return;
    _sessionBeaten = true;
    _lastBeatAt = DateTime.now();
    try {
      final body = {
        'session_id': Session.sessionId,
        'station': c.key,
        'state': state ?? _beatState,
        'player': _playerName[defaultTargetPlatform] ?? 'flutter-${defaultTargetPlatform.name.toLowerCase()}',
        'app_version': AppBuild.version,
        // The AAC rung playing (one variant, not the adaptive master); none for lossless.
        'bitrate_kbps': losslessActive.value ? null : aacKbps.value,
        'net_type': _netType,
        'startup_ms': _startupMs,
        'rebuffer_count': _rebuffers,
        'visibility': appVisible ? 'visible' : 'hidden',
        'volume': _player.volume.clamp(0, 1),
        'muted': false,
      };
      if (kDebugMode) debugPrint('radio: beat ${body['state']} ${body['bitrate_kbps']}kbps ${body['net_type']} ${body['visibility']} session=${(body['session_id'] as String).substring(0, 6)}');
      final ack = await api.heartbeat(body);
      final next = ack['next_heartbeat_seconds'];
      if (next is num && next >= 5 && next.toInt() != _beatEvery) {
        _beatEvery = next.toInt();
        _rearm();
      }
    } catch (_) {}
  }
}

