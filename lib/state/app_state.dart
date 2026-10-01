import 'package:flutter/material.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/data/channels.dart';
import 'package:seoulfm/platform/carplay_bridge.dart';
import 'package:seoulfm/platform/home_widgets.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/state/cover_colors.dart';
import 'package:seoulfm/state/now_playing_controller.dart';
import 'package:seoulfm/state/ratings_controller.dart';
import 'package:seoulfm/state/request_tracker.dart';
import 'package:seoulfm/state/runtime_config.dart';
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
  late final RatingsController ratings = RatingsController(listeningSince: radio.listeningSince, station: () => channels.active.key);
  final requests = RequestTracker();
  final covers = CoverColors();
  final support = SupportStore();
  late final CarPlayBridge carPlay = CarPlayBridge(onTune: (key) => tuneIn(key, play: true, fromCar: true));

  final ValueNotifier<LosslessPrompt?> losslessPrompt = ValueNotifier(null);
  ThemeMode themeMode = ThemeMode.dark;
  String? _tunedKey;
  String? _heardTrackId;

  /// Native HLS players start ~12 s behind live (`EXT-X-START:TIME-OFFSET=-12`) and can't
  /// report their program date, so while playing the listener is at least that far behind;
  /// the dashboard's `lyrics.delay_ms` (per station) wins when it says more.
  static const _playerOffsetMs = 12000;
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

    runtime.start();
    channels.addListener(_onChannels);
    channels.start();
    nowPlaying.addListener(_onHeard);
    stations.addListener(_syncCar);
    radio.wantPlaying.addListener(_syncCar);
    radio.wantPlaying.addListener(_syncWidgets);
    radio.wantPlaying.addListener(_syncStationsPolling);
    ratings.start();
    carPlay.start();
    WidgetsBinding.instance.addObserver(this);
    _onChannels();
    _syncStationsPolling();
  }

  bool _foreground = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncStationsPolling();
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
  void _syncWidgets() => HomeWidgets.update(channel: channels.active, track: nowPlaying.track, playing: radio.wantPlaying.value);

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
