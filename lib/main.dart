import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/data/app_language.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/l10n/app_localizations.dart';
import 'package:seoulfm/platform/deep_links.dart';
import 'package:seoulfm/platform/screenshots.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/state/session.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/root_shell.dart';
import 'package:seoulfm/ui/widgets/launch_curtain.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBuild.load();
  // Crash and error reports go to Sentry when a DSN is configured; otherwise straight to the app.
  if (Config.sentryDsn.isEmpty) return _start();
  await SentryFlutter.init((o) {
    o.dsn = Config.sentryDsn;
    o.release = 'seoulfm@${AppBuild.version}+${AppBuild.number}';
    if (Config.gitCommit.isNotEmpty) o.dist = Config.gitCommit;
    o.environment = kReleaseMode ? 'production' : 'development';
    o.tracesSampleRate = 0.1;
    // Listeners are anonymous: no IPs, no request bodies, no screenshots.
    o.sendDefaultPii = false;
  }, appRunner: _start);
}

Future<void> _start() async {
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
  DeepLinks.instance.start();
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
        ChangeNotifierProvider.value(value: app.covers),
        ChangeNotifierProvider.value(value: app.moderation),
        Provider.value(value: app.radio),
      ],
      child: MaterialApp(
        title: 'SeoulFM',
        debugShowCheckedModeBanner: false,
        themeMode: app.themeMode,
        locale: app.locale,
        theme: buildTheme(Brightness.light, app.accent),
        darkTheme: buildTheme(Brightness.dark, app.accent),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        scaffoldMessengerKey: rootMessengerKey,
        // Follow the system text size, within what the layouts hold.
        builder: (context, child) => MediaQuery.withClampedTextScaling(
          minScaleFactor: 0.9,
          maxScaleFactor: 2.0,
          child: Builder(
            builder: (context) {
              // Text built outside the tree (taglines on the lock screen and in the car) and
              // script-aware typography follow the language the app resolved to.
              AppLanguage.set(Localizations.localeOf(context), Directionality.of(context));
              return LaunchCurtain(child: child!);
            },
          ),
        ),
        home: const RootShell(),
      ),
    );
  }
}
