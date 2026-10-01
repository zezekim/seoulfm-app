import 'package:flutter_test/flutter_test.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/state/moderation.dart';
import 'package:seoulfm/state/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Session.init();
  });

  setUp(() => Moderation().showAll());

  test('hiding a name hides every dedication from it, whatever the case or spacing', () {
    final m = Moderation()..hideName('Minji');
    expect(m.hides(const Dedication(name: ' minji ', message: 'hi')), isTrue);
    expect(m.hides(const Dedication(name: 'Hanni')), isFalse);
    expect(m.hides(const Dedication(message: 'no name')), isFalse);
    expect(m.hides(null), isFalse);
  });

  test('a reported entry is hidden on its own', () {
    final m = Moderation()..hideEntry('e1');
    expect(m.hides(const Dedication(name: 'A'), entryId: 'e1'), isTrue);
    expect(m.hides(const Dedication(name: 'A'), entryId: 'e2'), isFalse);
  });

  test('it is kept across launches, and Show hidden clears it', () {
    Moderation()
      ..hideName('Minji')
      ..hideEntry('e1');
    final later = Moderation();
    expect(later.hidesAny, isTrue);
    expect(later.hides(const Dedication(name: 'minji')), isTrue);
    later.showAll();
    expect(Moderation().hidesAny, isFalse);
  });

  test('only the latest 200 reported entries are kept', () {
    final m = Moderation();
    for (var i = 0; i < 205; i++) {
      m.hideEntry('e$i');
    }
    final later = Moderation();
    expect(later.hides(const Dedication(name: 'x'), entryId: 'e0'), isFalse);
    expect(later.hides(const Dedication(name: 'x'), entryId: 'e204'), isTrue);
  });
}
