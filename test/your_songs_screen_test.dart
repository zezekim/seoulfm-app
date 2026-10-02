import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/l10n/app_localizations.dart';
import 'package:seoulfm/state/now_playing_controller.dart';
import 'package:seoulfm/state/saved_songs.dart';
import 'package:seoulfm/state/session.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/screens/your_songs_screen.dart';
import 'package:seoulfm/ui/widgets/save_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(SavedSongs store, Widget home, {Locale locale = const Locale('en'), double scale = 1, bool dark = true}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: store),
        ChangeNotifierProvider(create: (_) => NowPlayingController(delayMs: (_) => 0)),
      ],
      child: MaterialApp(
        locale: locale,
        theme: buildTheme(dark ? Brightness.dark : Brightness.light, const Color(0xFFFF4F9A)),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: home,
      ),
    );

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Session.init();
  });

  setUp(() => Session.prefs.remove(SavedSongs.prefsKey));

  SavedSongs filled() => SavedSongs()
    ..save(Track(trackId: 'a', title: 'Supernova', artist: 'aespa', requestable: true))
    ..save(Track(title: 'A live song with a long title that will not fit', artist: 'Someone'))
    ..save(Track(trackId: 'c', title: 'Not requestable', artist: 'X', requestable: false));

  testWidgets('the empty list explains how to save', (tester) async {
    await tester.pumpWidget(_app(SavedSongs(), const YourSongsScreen()));
    expect(find.text('Keep the songs you love'), findsOneWidget);
    expect(find.text('Request one of them'), findsNothing);
  });

  for (final (locale, scale, dark) in [
    (const Locale('en'), 1.0, true),
    (const Locale('ar'), 2.0, false),
    (const Locale('ko'), 2.0, true),
  ]) {
    testWidgets('the list lays out in $locale at ${scale}x, ${dark ? 'dark' : 'light'}', (tester) async {
      await tester.pumpWidget(_app(filled(), const YourSongsScreen(), locale: locale, scale: scale, dark: dark));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Supernova'), findsOneWidget);
    });
  }

  testWidgets('swiping a song away removes it, and Undo brings it back', (tester) async {
    final store = filled();
    await tester.pumpWidget(_app(store, const YourSongsScreen()));
    expect(find.text('3 songs'), findsOneWidget);
    await tester.drag(find.text('Supernova'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(store.length, 2);
    expect(find.text('Removed from Your songs'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(store.songs.last.track.id, 'a');
  });

  testWidgets('the heart is a toggle to screen readers', (tester) async {
    final store = SavedSongs();
    final t = Track(trackId: 'z', title: 'Z', artist: 'Y');
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        store,
        Scaffold(
          body: Center(child: SaveButton(track: t)),
        ),
      ),
    );
    final heart = find.bySemanticsLabel('Favourite');
    expect(tester.getSemantics(heart), isSemantics(hasToggledState: true, isToggled: false, isButton: true));
    await tester.tap(find.byType(SaveButton));
    await tester.pumpAndSettle();
    expect(store.isSaved(t), isTrue);
    expect(tester.getSemantics(heart), isSemantics(hasToggledState: true, isToggled: true));
    expect(find.text('Saved to Your songs'), findsOneWidget);
    semantics.dispose();
  });
}
