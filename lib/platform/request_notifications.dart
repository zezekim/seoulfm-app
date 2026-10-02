import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/data/app_language.dart';
import 'package:seoulfm/l10n/app_localizations.dart';
import 'package:seoulfm/state/session.dart';

/// The moments of a request worth a notification while the app is out of sight.
enum RequestMoment { comingUp, onAir }

/// Which moment [status] is, if any: queued and the final misses stay in the app.
RequestMoment? requestMomentOf(String status) => switch (status) {
  'scheduled' => RequestMoment.comingUp,
  'playing' || 'played' => RequestMoment.onAir,
  _ => null,
};

/// Local notifications for the listener's own requests, shown while the app is in the
/// background (`AppState`): once when one is coming up, once when it is on air. They come
/// from the request's live status stream, so only while the app is running (see README).
class RequestNotifications {
  RequestNotifications._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static Future<bool>? _ready;

  /// Each request's moments already seen or notified (`requestId:moment`), so each shows once.
  static final Set<String> _shown = {};

  /// Bumped when the listener taps a notification; the shell opens the player.
  static final ValueNotifier<int> opened = ValueNotifier(0);

  static const _askedKey = 'seoulfm-notify-asked';

  static bool get _supported =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android);

  /// Sets the plugin up without asking for anything (the ask comes after the first request).
  /// A tap that launched the app counts as a tap.
  static Future<bool> init() => _ready ??= _init();

  static Future<bool> _init() async {
    if (!_supported) return false;
    try {
      final ok = await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_seoulfm'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestSoundPermission: false,
            requestBadgePermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (_) => opened.value++,
      );
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) opened.value++;
      return ok ?? false;
    } catch (e) {
      debugPrint('notifications: $e');
      return false;
    }
  }

  /// Asks for permission once, after the listener's first accepted request: the moment the
  /// notifications mean something. Never at launch.
  static Future<void> askOnce() async {
    if (!_supported || (Session.prefs.getBool(_askedKey) ?? false)) return;
    await Session.prefs.setBool(_askedKey, true);
    if (!await init()) return;
    try {
      await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        sound: true,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('notifications: $e');
    }
  }

  /// A status change of one of the listener's requests. Returns the moment when [s] is the first
  /// of its kind for the request, and notifies it when the app is in the [background].
  static RequestMoment? onChange(RequestStatus s, {required bool background}) {
    final moment = requestMomentOf(s.status);
    // Seen in the app counts too: no notification later for what the listener already saw.
    if (moment == null || !_shown.add('${s.requestId}:${moment.name}')) return null;
    if (background) unawaited(_show(s, moment));
    return moment;
  }

  static Future<void> _show(RequestStatus s, RequestMoment moment) async {
    if (!await init()) return;
    final l = _strings();
    final title = s.track.displayTitle;
    final artist = s.track.displayArtist;
    final eta = s.eta;
    final (heading, body) = switch (moment) {
      RequestMoment.comingUp => (
        l.requestScheduled(title),
        eta.position == 1 || (eta.etaMinutes != null && eta.etaMinutes! <= 1)
            ? l.etaSoon
            : eta.etaMinutes != null
            ? l.etaMinutes(eta.etaMinutes!)
            : artist,
      ),
      RequestMoment.onAir => (l.requestPlayed(title), artist),
    };
    try {
      await _plugin.show(
        // One per request: on air replaces coming up.
        id: s.requestId.hashCode & 0x7fffffff,
        title: heading,
        body: body.isEmpty ? null : body,
        payload: 'player',
        notificationDetails: NotificationDetails(
          // High: it's about a song playing now or in a few minutes, so it may pop up.
          android: AndroidNotificationDetails(
            'com.seoulfm.seoulfm.requests',
            l.requestNotificationChannel,
            channelDescription: l.requestNotificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.status,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('notifications: $e');
    }
  }

  static AppLocalizations _strings() {
    try {
      return lookupAppLocalizations(AppLanguage.locale);
    } catch (_) {
      return lookupAppLocalizations(const Locale('en'));
    }
  }
}
