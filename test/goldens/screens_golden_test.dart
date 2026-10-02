@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/state/saved_songs.dart';
import 'package:seoulfm/state/session.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/root_shell.dart';
import 'package:seoulfm/ui/screens/your_songs_screen.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';
import 'package:seoulfm/ui/widgets/player_progress.dart';
import 'package:seoulfm/ui/widgets/quality_sheet.dart';
import 'package:seoulfm/ui/widgets/request_sheet.dart';
import 'package:seoulfm/ui/widgets/spatial_badge.dart';

import 'harness.dart';

/// Screen snapshots of the bars, rows and sheets in every golden language, plus a layout pass at
/// 200% text. Any overflow or exception fails the test on every platform; the images are
/// compared on macOS (docs/golden-tests.md). `flutter test --update-goldens test/goldens` redraws them.
void main() {
  setUpAll(setUpFakes);

  /// One case per language and text size: the image at 1.0, the layout alone at 2.0.
  void golden(
    String subject,
    Widget Function() build, {
    Finder Function()? capture,
    Track? playing,
    SavedSongs Function()? saved,
    Future<void> Function(WidgetTester tester, Locale locale, double scale)? check,
  }) {
    group(subject, () {
      for (final locale in goldenLocales) {
        for (final scale in textScales) {
          testWidgets('${locale.toLanguageTag()} at ${scale}x', (tester) async {
            usePhone(tester);
            await tester.pumpWidget(
              goldenApp(locale: locale, scale: scale, home: build(), playing: playing, saved: saved?.call()),
            );
            await settle(tester);
            expect(tester.takeException(), isNull, reason: '$subject in $locale at ${scale}x');
            await check?.call(tester, locale, scale);
            if (scale == 1.0) {
              await expectLater(
                capture?.call() ?? find.byType(MaterialApp),
                matchesGoldenFile(goldenName(subject, locale)),
              );
            }
          });
        }
      }
    });
  }

  golden(
    'tab_bar',
    () => const _Bars(child: _TabBar()),
    capture: () => find.byKey(_Bars.stage),
    check: (tester, locale, scale) async {
      final l = l10n(locale);
      // Home leads: on the left in left-to-right languages, on the right in Arabic.
      final home = tester.getCenter(find.text(l.tabHome)).dx;
      final more = tester.getCenter(find.text(l.tabMore)).dx;
      expect(home < more, locale.languageCode != 'ar', reason: 'tab order follows the text direction');
      if (scale == 1.0) expect(_truncated(tester, find.byType(GlassTabBar)), isEmpty, reason: 'tab labels fit');
    },
  );

  golden(
    'player_bar',
    () => const _Bars(child: MiniPlayer()),
    capture: () => find.byKey(_Bars.stage),
    playing: tracks[2],
    check: (tester, locale, scale) async {
      // The cover sits at the leading edge.
      final cover = tester.getCenter(find.byType(Artwork)).dx;
      final play = tester.getCenter(find.byIcon(AppIcons.pause)).dx;
      expect(cover < play, locale.languageCode != 'ar');
    },
  );

  golden(
    'track_list',
    () => Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(top: 47),
        children: [
          for (final t in tracks) TrackRow(track: t, requestable: true, trailing: Text(fmtDuration(t.durationMs))),
        ],
      ),
    ),
    playing: tracks[0],
  );

  golden(
    'spatial_progress',
    () => const _PlayerProgressStage(),
    capture: () => find.byKey(_PlayerProgressStage.stage),
    playing: tracks[0],
    check: (tester, locale, scale) async {
      expect(find.text(spatialAudioName), findsOneWidget);
      // Elapsed time at the leading edge, the remaining time at the trailing one.
      final elapsed = tester.getCenter(find.text('1:23')).dx;
      final left = tester.getCenter(find.textContaining('−1:35')).dx;
      expect(elapsed < left, locale.languageCode != 'ar');
    },
  );

  golden(
    'your_songs',
    () => const YourSongsScreen(),
    saved: () {
      Session.prefs.remove(SavedSongs.prefsKey);
      final s = SavedSongs();
      for (final t in tracks.reversed) {
        s.save(t);
      }
      return s;
    },
  );

  golden('quality_sheet', () => _Opener(pickQuality));

  golden(
    'request_sheet',
    () => _Opener((context) => showRequestSheet(context, tracks[0])),
    check: (tester, locale, scale) async {
      // The form, waiting for the captcha (its web view is a placeholder in tests).
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text(l10n(locale).sendRequest), findsOneWidget);
    },
  );
}

/// Texts in [within] cut short by their line limit (an ellipsis where a word should be).
List<String> _truncated(WidgetTester tester, Finder within) => [
  for (final p in tester.renderObjectList<RenderParagraph>(
    find.descendant(of: within, matching: find.byType(RichText)),
  ))
    if (p.didExceedMaxLines) p.text.toPlainText(),
];

/// The bottom of a screen as the shell lays it out: the floating bars over the content.
class _Bars extends StatelessWidget {
  const _Bars({required this.child});
  final Widget child;
  static const stage = Key('stage');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          // Covers behind the glass, in the image with it (a backdrop blur only sees its layer).
          RepaintBoundary(
            key: stage,
            child: Stack(
              children: [
                const Positioned.fill(child: Scenery()),
                Column(mainAxisSize: MainAxisSize.min, children: [const SizedBox(height: 24), child]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar();
  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return GlassTabBar(
      selected: 1,
      onSelect: (_) {},
      items: [
        (AppIcons.home, l.tabHome),
        (AppIcons.request, l.tabRequest),
        (AppIcons.charts, l.tabCharts),
        (AppIcons.more, l.tabMore),
      ],
    );
  }
}

/// The full player's progress row, with the 3D BS2B badge between the times, on a cover tint.
class _PlayerProgressStage extends StatelessWidget {
  const _PlayerProgressStage();
  static const stage = Key('stage');

  @override
  Widget build(BuildContext context) {
    // In a column, as the player stacks it (the row takes its own height, not the screen's).
    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RepaintBoundary(
            key: stage,
            child: ColoredBox(
              color: Color(0xFF4A1F66),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: PlayerProgress(center: SpatialAudioBadge()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A blank page that opens a sheet over itself, as the app's buttons do.
class _Opener extends StatefulWidget {
  const _Opener(this.open);
  final Future<void> Function(BuildContext context) open;
  @override
  State<_Opener> createState() => _OpenerState();
}

class _OpenerState extends State<_Opener> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.open(context));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ListView(
      padding: const EdgeInsets.only(top: 47),
      children: [for (final t in tracks) TrackRow(track: t)],
    ),
  );
}
