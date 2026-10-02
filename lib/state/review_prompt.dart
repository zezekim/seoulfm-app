import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The good moments to ask for a store rating.
enum ReviewMoment {
  /// The listener just heard their own request play, with the app open.
  ownRequestPlayed,

  /// A listening day: at least [ReviewPrompt.dayMinimum] today, and the third such day or later.
  listeningDay,
}

/// Whether to ask for a rating now. Pure, so the rules are tested on their own.
bool shouldAskForReview({
  required ReviewMoment moment,
  required DateTime now,
  required DateTime installedAt,
  required String version,
  required String? askedVersion,
  required DateTime? lastErrorAt,
  required bool screenClear,
  required int listeningDays,
  required bool listenedEnoughToday,
}) {
  // Once per app version; the OS rate-limits on top of that.
  if (askedVersion == version) return false;
  // Not in the first days: the listener hasn't made up their mind yet.
  if (now.difference(installedAt) < ReviewPrompt.installQuiet) return false;
  // Not right after something went wrong.
  if (lastErrorAt != null && now.difference(lastErrorAt) < ReviewPrompt.errorQuiet) return false;
  // Not over a sheet or the welcome.
  if (!screenClear) return false;
  return switch (moment) {
    ReviewMoment.ownRequestPlayed => true,
    ReviewMoment.listeningDay => listenedEnoughToday && listeningDays >= ReviewPrompt.daysNeeded,
  };
}

/// Asks for an App Store / Play rating at a good moment (see [ReviewMoment]), keeping the
/// accounting it needs in preferences: when the app was first seen, how long the listener has
/// listened today, and on how many days they listened long enough.
class ReviewPrompt {
  ReviewPrompt(this._prefs, {required this.version, DateTime Function()? clock, Future<bool> Function()? request})
    : _clock = clock ?? DateTime.now,
      _request = request ?? _storeReview;

  final SharedPreferences _prefs;
  final DateTime Function() _clock;
  final Future<bool> Function() _request;

  /// The installed version (`AppBuild.version`): the prompt shows at most once per version.
  final String version;

  static const installQuiet = Duration(days: 2);
  static const errorQuiet = Duration(minutes: 10);
  static const dayMinimum = Duration(minutes: 10);
  static const daysNeeded = 3;

  static const _installedKey = 'seoulfm-review-installed';
  static const _dayKey = 'seoulfm-review-day';
  static const _daySecondsKey = 'seoulfm-review-day-seconds';
  static const _daysKey = 'seoulfm-review-days';
  static const _askedKey = 'seoulfm-review-asked';

  /// Whether nothing is over the app (no sheet, no welcome); set by the shell.
  bool Function() screenClear = () => false;

  DateTime? _lastErrorAt;
  bool _asking = false;

  /// Notes when the app was first seen (upgrades count from their first launch with this).
  void start() {
    if (_prefs.getInt(_installedKey) == null) _prefs.setInt(_installedKey, _clock().millisecondsSinceEpoch);
  }

  DateTime get installedAt =>
      DateTime.fromMillisecondsSinceEpoch(_prefs.getInt(_installedKey) ?? _clock().millisecondsSinceEpoch);

  static String _day(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

  /// Days (local dates) on which the listener reached [dayMinimum].
  List<String> get listeningDays => _prefs.getStringList(_daysKey) ?? const [];

  Duration get listenedToday => _prefs.getString(_dayKey) == _day(_clock())
      ? Duration(seconds: _prefs.getInt(_daySecondsKey) ?? 0)
      : Duration.zero;

  /// Adds [d] of listening to today; the day counts once it reaches [dayMinimum].
  void addListening(Duration d) {
    final today = _day(_clock());
    final total = listenedToday + d;
    _prefs.setString(_dayKey, today);
    _prefs.setInt(_daySecondsKey, total.inSeconds);
    final days = listeningDays;
    if (total >= dayMinimum && !days.contains(today)) {
      // The last few are all the rule needs.
      _prefs.setStringList(_daysKey, [...days, today].reversed.take(daysNeeded).toList().reversed.toList());
    }
  }

  /// Something went wrong (the stream failing, say): no prompt for a while.
  void noteError() => _lastErrorAt = _clock();

  bool shouldAsk(ReviewMoment moment) => shouldAskForReview(
    moment: moment,
    now: _clock(),
    installedAt: installedAt,
    version: version,
    askedVersion: _prefs.getString(_askedKey),
    lastErrorAt: _lastErrorAt,
    screenClear: screenClear(),
    listeningDays: listeningDays.length,
    listenedEnoughToday: listeningDays.contains(_day(_clock())),
  );

  /// Asks if [moment] is a good one. Returns whether the system was asked (it may still show
  /// nothing: it has its own limits, and there is no falling back to the store page).
  Future<bool> maybeAsk(ReviewMoment moment) async {
    if (_asking || !shouldAsk(moment)) return false;
    _asking = true;
    try {
      if (!await _request()) return false;
      await _prefs.setString(_askedKey, version);
      return true;
    } catch (e) {
      debugPrint('review: $e');
      return false;
    } finally {
      _asking = false;
    }
  }

  static Future<bool> _storeReview() async {
    final review = InAppReview.instance;
    if (!await review.isAvailable()) return false;
    await review.requestReview();
    return true;
  }
}
