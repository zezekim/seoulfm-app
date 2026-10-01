import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:seoulfm/ui/root_shell.dart';

import 'helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('welcome', (t) async {
    await launch(binding, welcome: true);
    await wait(t, 12);
    await binding.takeScreenshot('w1-intro');
    await t.tap(find.text('Continue'));
    await wait(t, 3);
    await t.tap(find.text('Dance'));
    await wait(t, 1);
    await t.tap(find.text('Indie'));
    await wait(t, 2);
    await binding.takeScreenshot('w2-pick');
    await t.tap(find.text('Continue'));
    await wait(t, 3);
    await binding.takeScreenshot('w3-requests');
    await t.tap(find.text('Start listening'));
    await wait(t, 10);
    await binding.takeScreenshot('w4-home');
    await t.tap(find.descendant(of: find.byType(GlassTabBar), matching: find.text('Request')));
    await wait(t, 2);
    await t.enterText(find.byType(TextField), 'zzqxjv');
    await wait(t, 5);
    await binding.takeScreenshot('w5-noresults');
  });
}
