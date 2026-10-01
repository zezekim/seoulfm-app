import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';
import 'package:seoulfm/ui/widgets/request_sheet.dart';

import 'helpers.dart';

/// The captcha in the request sheet issues a token in the app's web view, so Send turns on.
/// Sends nothing: a real request would play live for everyone.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('captcha issues a token', (t) async {
    expect(Config.captchaEnabled, isTrue, reason: 'builds must carry the Turnstile site key');
    await launch(binding, inAppShots: false);
    await wait(t, 8);
    // Not what's on air (that can't be requested): a random song from the library.
    final track = (await api.random(limit: 24)).firstWhere((x) => x.requestable != false && x.id != null);
    showRequestSheet(t.element(find.byType(MiniPlayer)), track);
    final send = find.widgetWithText(FilledButton, 'Send request');
    var ready = false;
    for (var i = 0; i < 40 && !ready; i++) {
      await wait(t, 1);
      ready = send.evaluate().isNotEmpty && t.widget<FilledButton>(send).onPressed != null;
    }
    debugPrint('CAPTCHA ready=$ready failed=${find.textContaining('verify').evaluate().isNotEmpty}');
    expect(ready, isTrue);
  });
}
