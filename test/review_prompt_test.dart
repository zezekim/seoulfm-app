import 'package:flutter_test/flutter_test.dart';
import 'package:seoulfm/platform/request_notifications.dart';
import 'package:seoulfm/state/review_prompt.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('shouldAskForReview', () {
    final installed = DateTime(2026, 10, 1, 9);
    bool ask({
      ReviewMoment moment = ReviewMoment.ownRequestPlayed,
      DateTime? now,
      String? askedVersion,
      DateTime? lastErrorAt,
      bool screenClear = true,
      int listeningDays = 0,
      bool listenedEnoughToday = false,
    }) => shouldAskForReview(
      moment: moment,
      now: now ?? DateTime(2026, 10, 4, 9),
      installedAt: installed,
      version: '3.0.0',
      askedVersion: askedVersion,
      lastErrorAt: lastErrorAt,
      screenClear: screenClear,
      listeningDays: listeningDays,
      listenedEnoughToday: listenedEnoughToday,
    );

    test('asks after hearing an own request once installed long enough', () => expect(ask(), isTrue));

    test('never in the first two days', () {
      expect(ask(now: DateTime(2026, 10, 3, 8, 59)), isFalse);
      expect(ask(now: DateTime(2026, 10, 3, 9)), isTrue);
    });

    test('once per version', () {
      expect(ask(askedVersion: '3.0.0'), isFalse);
      expect(ask(askedVersion: '2.9.0'), isTrue);
    });

    test('not right after an error', () {
      expect(ask(lastErrorAt: DateTime(2026, 10, 4, 8, 55)), isFalse);
      expect(ask(lastErrorAt: DateTime(2026, 10, 4, 8, 45)), isTrue);
    });

    test('not over a sheet or the welcome', () => expect(ask(screenClear: false), isFalse));

    test('listening day: the third day with enough listening', () {
      const m = ReviewMoment.listeningDay;
      expect(ask(moment: m, listeningDays: 2, listenedEnoughToday: true), isFalse);
      expect(ask(moment: m, listeningDays: 3, listenedEnoughToday: false), isFalse);
      expect(ask(moment: m, listeningDays: 3, listenedEnoughToday: true), isTrue);
    });
  });

  group('ReviewPrompt', () {
    late DateTime now;
    late int requests;

    Future<ReviewPrompt> make({bool available = true}) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      requests = 0;
      return ReviewPrompt(
        prefs,
        version: '3.0.0',
        clock: () => now,
        request: () async {
          requests++;
          return available;
        },
      )..screenClear = () => true;
    }

    test('counts listening days and asks on the third, once per version', () async {
      now = DateTime(2026, 10, 1, 20);
      final r = await make();
      r.start();
      for (final day in [1, 2, 3]) {
        now = DateTime(2026, 10, day, 20);
        r.addListening(const Duration(minutes: 9));
        expect(await r.maybeAsk(ReviewMoment.listeningDay), isFalse, reason: 'day $day under 10 min');
        r.addListening(const Duration(minutes: 1));
        // Day 3 at 20:00 is exactly two days after install: just allowed.
        final asked = await r.maybeAsk(ReviewMoment.listeningDay);
        expect(asked, day == 3, reason: 'day $day');
      }
      expect(r.listeningDays, ['2026-10-01', '2026-10-02', '2026-10-03']);
      expect(requests, 1);
      // Once per version, whatever the moment.
      now = DateTime(2026, 10, 9, 20);
      expect(await r.maybeAsk(ReviewMoment.ownRequestPlayed), isFalse);
      expect(requests, 1);
    });

    test('listening resets each day', () async {
      now = DateTime(2026, 10, 1, 23, 55);
      final r = await make();
      r.addListening(const Duration(minutes: 5));
      now = DateTime(2026, 10, 2, 0, 5);
      expect(r.listenedToday, Duration.zero);
      r.addListening(const Duration(minutes: 5));
      expect(r.listenedToday, const Duration(minutes: 5));
      expect(r.listeningDays, isEmpty);
    });

    test('not right after an error', () async {
      now = DateTime(2026, 10, 1);
      final r = await make();
      r.start();
      now = DateTime(2026, 10, 5, 12);
      r.noteError();
      now = DateTime(2026, 10, 5, 12, 5);
      expect(await r.maybeAsk(ReviewMoment.ownRequestPlayed), isFalse);
      now = DateTime(2026, 10, 5, 12, 11);
      expect(await r.maybeAsk(ReviewMoment.ownRequestPlayed), isTrue);
    });

    test('an unavailable store is not remembered as asked', () async {
      now = DateTime(2026, 10, 1);
      final r = await make(available: false);
      r.start();
      now = DateTime(2026, 10, 5);
      expect(await r.maybeAsk(ReviewMoment.ownRequestPlayed), isFalse);
      expect(await r.maybeAsk(ReviewMoment.ownRequestPlayed), isFalse);
      expect(requests, 2);
    });
  });

  test('request moments', () {
    expect(requestMomentOf('queued'), isNull);
    expect(requestMomentOf('scheduled'), RequestMoment.comingUp);
    expect(requestMomentOf('playing'), RequestMoment.onAir);
    expect(requestMomentOf('played'), RequestMoment.onAir);
    expect(requestMomentOf('expired'), isNull);
  });
}
