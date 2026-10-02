import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/data/app_language.dart';
import 'package:seoulfm/data/channels.dart';
import 'package:seoulfm/l10n/app_localizations.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/state/cover_colors.dart';
import 'package:seoulfm/state/now_playing_controller.dart';
import 'package:seoulfm/state/saved_songs.dart';
import 'package:seoulfm/state/session.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/widgets/cover_image.dart';
import 'package:seoulfm/ui/widgets/turnstile.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The languages every golden is taken in: English, Korean (Hangul), Arabic (right to left),
/// Thai (stacked marks, tall lines), Japanese (kana and kanji) and German (long words).
const goldenLocales = [Locale('en'), Locale('ko'), Locale('ar'), Locale('th'), Locale('ja'), Locale('de')];

/// An iPhone 14/15-sized screen. Drawn at 1x: layout is in logical pixels, so overflow,
/// clipping and direction show the same at any density, and the images stay a few kB each.
const phoneSize = Size(390, 844);
const phoneRatio = 1.0;

/// The two text sizes checked: the default, and 200% (the largest the layouts promise to hold;
/// checked for overflow only, no image).
const textScales = [1.0, 2.0];

// ── Fake data ─────────────────────────────────────────────────────────────

String coverUrl(int i) => 'https://test.invalid/cover/$i.jpg';

/// Songs with the shapes that break layouts: a long English title, Hangul, a long artist list.
final tracks = [
  Track(
    trackId: 't1',
    title: 'Supernova',
    artist: 'aespa',
    artworkUrl: coverUrl(0),
    durationMs: 178000,
    requestable: true,
  ),
  Track(trackId: 't2', title: '밤양갱 (Bam Yang Gang)', artist: '비비 (BIBI)', artworkUrl: coverUrl(1), durationMs: 145000),
  Track(
    trackId: 't3',
    title: 'Ditto (250 Remix) [Extended Version for the Radio Edit]',
    artist: 'NewJeans',
    artworkUrl: coverUrl(2),
    durationMs: 240000,
  ),
  Track(trackId: 't4', title: 'APT.', artist: 'ROSÉ & Bruno Mars', artworkUrl: coverUrl(3), durationMs: 170000),
  Track(
    trackId: 't5',
    title: 'Love wins all',
    artist: 'IU, a featured guest, and a very long list of other artists',
    artworkUrl: coverUrl(4),
    durationMs: 271000,
  ),
  Track(title: 'Magnetic', artist: 'ILLIT', durationMs: 160000), // no cover, no id (live feed)
];

/// Five covers: diagonal two-colour gradients, made once (they need the engine, so real async).
final _covers = <String, ui.Image>{};
const _coverColors = [
  (Color(0xFF7B2FF7), Color(0xFFF107A3)),
  (Color(0xFF0F9B8E), Color(0xFFF7D046)),
  (Color(0xFF1F4E79), Color(0xFF8EC5FC)),
  (Color(0xFFE53935), Color(0xFF111111)),
  (Color(0xFFFFB199), Color(0xFFFF0844)),
];

Future<void> makeCovers() async {
  if (_covers.isNotEmpty) return;
  for (var i = 0; i < _coverColors.length; i++) {
    final recorder = ui.PictureRecorder();
    const side = 128.0;
    final (a, b) = _coverColors[i];
    Canvas(recorder)
      ..drawRect(
        const Rect.fromLTWH(0, 0, side, side),
        Paint()..shader = ui.Gradient.linear(Offset.zero, const Offset(side, side), [a, b]),
      )
      ..drawCircle(const Offset(side * 0.62, side * 0.4), side * 0.22, Paint()..color = const Color(0x55FFFFFF));
    _covers[coverUrl(i)] = await recorder.endRecording().toImage(side.toInt(), side.toInt());
  }
  coverProvider = (url) => _FakeCover(url);
}

/// A cover from memory, available on the first frame (no fade, no network).
@immutable
class _FakeCover extends ImageProvider<_FakeCover> {
  const _FakeCover(this.url);
  final String url;

  @override
  Future<_FakeCover> obtainKey(ImageConfiguration configuration) => SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(_FakeCover key, ImageDecoderCallback decode) {
    final image = _covers[url];
    if (image == null) {
      return OneFrameImageStreamCompleter(Future.error(StateError('no test cover for $url')));
    }
    return OneFrameImageStreamCompleter(SynchronousFuture(ImageInfo(image: image.clone())));
  }

  @override
  bool operator ==(Object other) => other is _FakeCover && other.url == url;

  @override
  int get hashCode => url.hashCode;
}

/// The song heard right now, 1:23 in; no stream, no events.
class FakeNowPlaying extends NowPlayingController {
  FakeNowPlaying(this._track) : super(delayMs: (_) => 0);
  final Track? _track;
  @override
  Track? get track => _track;
  @override
  int? positionMs() => _track == null ? null : 83000;
}

/// The line-up from the registry, tuned to the first station; nothing polled.
class FakeChannels extends ChannelController {
  @override
  Channel get active => channels.first;
}

/// Cover tints without reading pixels: what [CoverColors] would settle on, fixed.
class FakeCoverColors extends CoverColors {
  @override
  Color? of(String? url) => url == null ? null : const Color(0xFF6A2C91);
}

/// The player's state as the bars read it; nothing plays.
class FakeRadio extends Fake implements RadioHandler {
  @override
  final wantPlaying = ValueNotifier(true);
  @override
  final buffering = ValueNotifier(false);
  @override
  final losslessActive = ValueNotifier(false);
  @override
  final ValueNotifier<int?> quality = ValueNotifier(null);
  @override
  Future<void> toggle() async {}
  @override
  Future<void> setQuality(int? kbps) async => quality.value = kbps;
}

/// Shared preferences in memory, the API answered locally, the captcha drawn as a placeholder.
Future<void> setUpFakes() async {
  SharedPreferences.setMockInitialValues({});
  try {
    await Session.init();
  } catch (_) {
    // Already set up by an earlier group (Session's fields are late final).
  }
  await makeCovers();
  api.client = MockClient((req) async {
    if (req.url.path.endsWith('/requests/eta')) {
      return http.Response(
        jsonEncode({
          'requestable': true,
          'state': 'available',
          'eta': {'eta_minutes': 12, 'position': 3},
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    return http.Response('{"error":{"code":"not_found","message":"Not in the test API"}}', 404);
  });
  Turnstile.standIn = (context) => Container(
    height: 65,
    decoration: BoxDecoration(
      color: context.sfm.surface2,
      border: Border.all(color: context.sfm.border),
      borderRadius: BorderRadius.circular(Radii.md),
    ),
  );
}

// ── The app around a widget ───────────────────────────────────────────────

/// Sizes the test screen as a phone; undone at the end of the test.
void usePhone(WidgetTester tester) {
  tester.view.physicalSize = phoneSize * phoneRatio;
  tester.view.devicePixelRatio = phoneRatio;
  addTearDown(tester.view.reset);
}

/// [home] in the app's dark theme, in [locale] at [scale], with the providers the bars and
/// sheets read (real controllers where they hold no I/O, fakes where they would).
Widget goldenApp({
  required Locale locale,
  required double scale,
  required Widget home,
  Track? playing,
  SavedSongs? saved,
}) {
  final radio = FakeRadio();
  return MultiProvider(
    providers: [
      Provider<RadioHandler>.value(value: radio),
      ChangeNotifierProvider<NowPlayingController>(create: (_) => FakeNowPlaying(playing)),
      ChangeNotifierProvider<ChannelController>(create: (_) => FakeChannels()),
      ChangeNotifierProvider<CoverColors>(create: (_) => FakeCoverColors()),
      ChangeNotifierProvider<SavedSongs>(create: (_) => saved ?? SavedSongs()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      theme: buildTheme(Brightness.dark, const Color(0xFFFF3B5C)),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        AppLanguage.set(Localizations.localeOf(context), Directionality.of(context));
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            // A notched phone: the status bar and the home indicator.
            padding: const EdgeInsets.only(top: 47, bottom: 34),
            viewPadding: const EdgeInsets.only(top: 47, bottom: 34),
          ),
          child: child!,
        );
      },
      home: home,
    ),
  );
}

/// What is behind the floating bars: covers and colour, so the glass has something to blur.
class Scenery extends StatelessWidget {
  const Scenery({super.key});
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF09090B), Color(0xFF3B1E54), Color(0xFF0F3D3E)],
        ),
      ),
      child: Wrap(
        children: [
          for (var i = 0; i < 40; i++)
            Padding(
              padding: const EdgeInsets.all(6),
              child: Image(image: coverProvider(coverUrl(i % 5)), width: 84, height: 84),
            ),
        ],
      ),
    );
  }
}

/// The AppLocalizations for [locale], for expected strings.
AppLocalizations l10n(Locale locale) => lookupAppLocalizations(locale);

/// Lets entrances finish. The bars tick every second and the on-air bars loop, so the tree
/// never settles: a fixed time keeps the frames identical from run to run.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

String goldenName(String subject, Locale locale) => 'images/$subject.${locale.toLanguageTag()}.png';
