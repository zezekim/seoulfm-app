import 'dart:async';

import 'package:flutter/material.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/platform/request_notifications.dart';
import 'package:seoulfm/state/moderation.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/data/channels.dart';
import 'package:seoulfm/platform/attestation.dart';
import 'package:seoulfm/platform/carplay_bridge.dart';
import 'package:seoulfm/platform/home_widgets.dart';
import 'package:seoulfm/platform/intents_bridge.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/state/cover_colors.dart';
import 'package:seoulfm/state/now_playing_controller.dart';
import 'package:seoulfm/state/ratings_controller.dart';
import 'package:seoulfm/state/review_prompt.dart';
import 'package:seoulfm/state/request_tracker.dart';
import 'package:seoulfm/state/runtime_config.dart';
import 'package:seoulfm/state/saved_songs.dart';
import 'package:seoulfm/state/session.dart';
import 'package:seoulfm/state/stations_now_playing.dart';
import 'package:seoulfm/state/support_store.dart';

/// The pending lossless notice for a tune-in (the API requires it every time).
class LosslessPrompt {
  LosslessPrompt(this.channel, this.tier);
  final Channel channel;
  final LosslessTier tier;
}

/// Wires the controllers together, the way the site's providers do: the tuned channel
/// drives the live feed, the player and station scoping; the heard track drives the
/// lock screen, the car and the ratings.
class AppState extends ChangeNotifier with WidgetsBindingObserver {
  AppState(this.radio);

  final RadioHandler radio;
  final channels = ChannelController();
  final runtime = RuntimeConfigController();
  late final NowPlayingController nowPlaying = NowPlayingController(delayMs: _delayMs);
  final stations = StationsNowPlaying();
  late final RatingsController ratings = RatingsController(
    listeningSince: radio.listeningSince,
    station: () => channels.active.key,
  );
  final requests = RequestTracker();
  final covers = CoverColors();
  final support = SupportStore();
  final moderation = Moderation();
  late final ReviewPrompt review = ReviewPrompt(Session.prefs, version: AppBuild.version);
  final saved = SavedSongs();
  late final CarPlayBridge carPlay = CarPlayBridge(onTune: (key) => tuneIn(key, play: true, fromCar: true));

  /// Siri, Shortcuts and Control Center. Like the car, they can't answer the lossless notice
  /// for a station already on; a newly tuned one still offers it in the app.
  late final IntentsBridge intents = IntentsBridge(
    onPlay: (key) => tuneIn(key, play: true, fromCar: true),
    onResume: radio.play,
    onPause: radio.pause,
  );

  final ValueNotifier<LosslessPrompt?> losslessPrompt = ValueNotifier(null);
  ThemeMode themeMode = ThemeMode.dark;
  String? _tunedKey;
  String? _heardTrackId;

  /// The radio plays [RadioHandler.liveOffset] behind the live edge, and native players can't
  /// report their program date, so while playing the listener is at least that far behind;
  /// the dashboard's `lyrics.delay_ms` (per station) wins when it says more.
  static final _playerOffsetMs = RadioHandler.liveOffset.inMilliseconds;
  int _delayMs(String station) {
    final configured = runtime.config.delayFor(station);
    return radio.wantPlaying.value ? (configured > _playerOffsetMs ? configured : _playerOffsetMs) : configured;
  }

  /// The listener's stations, picked on the welcome screen (Home shows them first).
  final ValueNotifier<List<String>> favourites = ValueNotifier(const []);

  /// Whether the welcome has been seen (it shows once, on first launch).
  bool get onboarded => Session.prefs.getBool('seoulfm-onboarded') ?? false;

  void setFavourites(List<String> keys) {
    favourites.value = List.unmodifiable(keys);
    Session.prefs.setStringList('seoulfm-favourites', keys);
  }

  /// The language the listener picked in Settings; null follows the system.
  Locale? locale;

  void setLocale(Locale? l) {
    locale = l;
    if (l == null) {
      Session.prefs.remove('seoulfm-locale');
    } else {
      Session.prefs.setString('seoulfm-locale', l.toLanguageTag());
    }
    notifyListeners();
  }

  void finishOnboarding() => Session.prefs.setBool('seoulfm-onboarded', true);

  void start() {
    favourites.value = Session.prefs.getStringList('seoulfm-favourites') ?? const [];
    final tag = Session.prefs.getString('seoulfm-locale');
    if (tag != null) {
      final parts = tag.split('-');
      locale = parts.length == 1
          ? Locale(parts[0])
          : parts[1].length == 4
          ? Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1])
          : Locale(parts[0], parts[1]);
    }
    themeMode = switch (Session.prefs.getString('seoulfm-theme')) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
    radio.channels = () => channels.channels;
    radio.onTune = (key) => tuneIn(key, fromCar: true);
    radio.stationsNowPlaying = () => stations.byStation;
    radio.songPositionMs = nowPlaying.positionMs;

    // Writes carry a device proof once the dashboard turns attestation on; each config poll
    // keeps the API's policy and the device's key fresh.
    final attestation = Attestation.instance..enabled = () => runtime.config.attestation;
    api.attestor = attestation;
    runtime.addListener(attestation.warmUp);
    runtime.start();
    // The last line-up and songs paint the first frame; both refresh straight after.
    stations.restore();
    channels.addListener(_onChannels);
    channels.start();
    nowPlaying.addListener(_onHeard);
    stations.addListener(_syncCar);
    radio.wantPlaying.addListener(_syncCar);
    radio.wantPlaying.addListener(_syncWidgets);
    radio.wantPlaying.addListener(_syncStationsPolling);
    requests.current.addListener(_syncRequest);
    ratings.start();
    carPlay.start();
    intents.start();
    WidgetsBinding.instance.addObserver(this);
    requests.addListener(_onRequestChange);
    unawaited(RequestNotifications.init());
    review.start();
    radio.streamFailing.addListener(_onPlaybackTrouble);
    radio.losslessFailed.addListener(_onPlaybackTrouble);
    Timer.periodic(const Duration(minutes: 1), (_) => _countListening());
    _onChannels();
    _syncStationsPolling();
  }

  // On screen from the start, unless the system woke the app with no screen (Android media
  // resumption after a reboot, Android Auto, a Quick Settings tap): then it waits to be shown.
  bool _foreground = switch (WidgetsBinding.instance.lifecycleState) {
    null || AppLifecycleState.resumed || AppLifecycleState.inactive => true,
    _ => false,
  };

  /// Whether the app is on screen (resumed).
  bool get foreground => _foreground;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    radio.appVisible = _foreground;
    // Back on screen: get the tuned station ready for a tap on play.
    if (_foreground) radio.warmUp();
    _syncStationsPolling();
    // The app is being torn down: end the listening session on the dashboard now.
    if (state == AppLifecycleState.detached) radio.finalBeat();
  }

  /// The listener's requests: a notification for the moments that matter while the app is out
  /// of sight, and a rating prompt soon after they hear one of theirs with the app open.
  void _onRequestChange() {
    final s = requests.lastChange;
    if (s == null) return;
    final moment = RequestNotifications.onChange(s, background: !_foreground);
    if (moment == RequestMoment.onAir && _foreground) {
      // Once the toast has had its moment and the song has started.
      Timer(const Duration(seconds: 8), () {
        if (_foreground) review.maybeAsk(ReviewMoment.ownRequestPlayed);
      });
    }
  }

  void _onPlaybackTrouble() {
    if (radio.streamFailing.value || radio.losslessFailed.value) review.noteError();
  }

  DateTime _lastListeningTick = DateTime.now();

  /// Counts listening time (sound actually playing, in the background too) toward the rating
  /// prompt's listening days, and asks on a qualifying day while the listener is in the app.
  void _countListening() {
    final now = DateTime.now();
    final elapsed = now.difference(_lastListeningTick);
    _lastListeningTick = now;
    final hearing = radio.wantPlaying.value && radio.listeningSince.value != null && !radio.buffering.value;
    if (!hearing) return;
    // A suspended timer (the app asleep) doesn't count as listening.
    review.addListening(elapsed > const Duration(seconds: 90) ? const Duration(minutes: 1) : elapsed);
    if (_foreground && !radio.streamFailing.value) review.maybeAsk(ReviewMoment.listeningDay);
  }

  /// Other stations are polled while the app is on screen, or while it plays (the car lists them).
  void _syncStationsPolling() => stations.setActive(_foreground || radio.wantPlaying.value);

  void _onChannels() {
    final active = channels.active;
    stations.setStations(channels.tunable.map((c) => c.key).toList());
    if (active.key != _tunedKey) {
      _tunedKey = active.key;
      nowPlaying.tune(active.key);
      radio.setChannel(active);
      _offerLossless(active);
    }
    _syncCar();
    notifyListeners();
  }

  void _onHeard() {
    final t = nowPlaying.track;
    _syncWidgets();
    radio.updateTrack(channels.active, t);
    if (t?.id != _heardTrackId) {
      _heardTrackId = t?.id;
      ratings.load(t?.id);
    }
  }

  /// The home-screen widgets follow the station, the heard song and the play state.
  void _syncWidgets() =>
      HomeWidgets.update(channel: channels.active, track: nowPlaying.track, playing: radio.wantPlaying.value);

  /// The listener's request on its way, for the Live Activity's countdown. The ETA comes in
  /// minutes from each update; pinned to a clock time, and moved only when the minutes change,
  /// so the countdown doesn't jump back on every update.
  String? _etaFor;
  DateTime? _etaAt;

  void _syncRequest() {
    final s = requests.current.value;
    final minutes = s?.eta.etaMinutes;
    if (s == null || minutes == null) {
      _etaFor = null;
      _etaAt = null;
    } else if ('${s.requestId}/$minutes' != _etaFor) {
      _etaFor = '${s.requestId}/$minutes';
      _etaAt = DateTime.now().add(Duration(minutes: minutes));
    }
    HomeWidgets.request(title: s?.track.displayTitle, at: _etaAt, playing: s?.status == 'playing');
  }

  void _syncCar() => carPlay.update(
    channels: channels.channels,
    activeKey: channels.active.key,
    playing: radio.wantPlaying.value,
    nowPlaying: stations.byStation,
  );

  /// Selects a channel and, with [play], starts it. A lossless channel asks first (on the
  /// phone; the car always gets AAC, since nobody can read a data notice while driving).
  Future<void> tuneIn(String key, {bool play = false, bool fromCar = false}) async {
    final c = channels.byKey(key);
    if (c == null || !c.tunable) return;
    if (c.key != channels.active.key) {
      channels.select(key);
    } else if (!fromCar) {
      _offerLossless(c);
    }
    if (play) await radio.play();
  }

  Future<void> _offerLossless(Channel c) async {
    if (!c.lossless) return;
    try {
      final tier = await api.losslessTier(c.stream);
      if (tier.available && channels.active.key == c.key) losslessPrompt.value = LosslessPrompt(c, tier);
    } catch (_) {}
  }

  void answerLossless(bool accept) {
    final p = losslessPrompt.value;
    losslessPrompt.value = null;
    if (p == null || channels.active.key != p.channel.key) return;
    radio.setChannel(p.channel, lossless: accept);
  }

  void setTheme(ThemeMode m) {
    themeMode = m;
    Session.prefs.setString('seoulfm-theme', m.name);
    notifyListeners();
  }

  /// The accent: the tuned channel's colour.
  Color get accent => channels.active.color;
}
