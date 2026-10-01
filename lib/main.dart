import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/l10n/app_localizations.dart';
import 'package:seoulfm/platform/screenshots.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/state/session.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/root_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Session.init();

  // The radio lives in the audio service: it outlives every screen, plays in the
  // background, and answers the lock screen, CarPlay and Android Auto (which can start
  // the app with no screen at all, so nothing here may depend on the UI).
  final radio = await AudioService.init<RadioHandler>(
    builder: RadioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.seoulfm.seoulfm.playback',
      androidNotificationChannelName: 'SeoulFM playback',
      androidNotificationIcon: 'drawable/ic_stat_seoulfm',
      androidStopForegroundOnPause: true,
      androidBrowsableRootExtras: {
        // Android Auto: show the stations as a grid of artwork.
        'android.media.browse.CONTENT_STYLE_SUPPORTED': true,
        'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 2,
        'android.media.browse.CONTENT_STYLE_PLAYABLE_HINT': 2,
      },
    ),
  );

  final app = AppState(radio)..start();
  Screenshots.start();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(ChangeNotifierProvider.value(value: app, child: const SeoulFmApp()));
}

class SeoulFmApp extends StatelessWidget {
  const SeoulFmApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: app.channels),
        ChangeNotifierProvider.value(value: app.nowPlaying),
        ChangeNotifierProvider.value(value: app.stations),
        ChangeNotifierProvider.value(value: app.ratings),
        ChangeNotifierProvider.value(value: app.runtime),
        ChangeNotifierProvider.value(value: app.requests),
        Provider.value(value: app.radio),
      ],
      child: MaterialApp(
        title: 'SeoulFM',
        debugShowCheckedModeBanner: false,
        themeMode: app.themeMode,
        theme: buildTheme(Brightness.light, app.accent),
        darkTheme: buildTheme(Brightness.dark, app.accent),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        scaffoldMessengerKey: rootMessengerKey,
        home: const RootShell(),
      ),
    );
  }
}
