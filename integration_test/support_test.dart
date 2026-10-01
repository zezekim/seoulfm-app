import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('support', (t) async {
    await launch(binding);
    await wait(t, 12);
    await binding.takeScreenshot('s1-home');
    await t.drag(find.byType(CustomScrollView).first, const Offset(0, -620));
    await wait(t, 2);
    await binding.takeScreenshot('s2-home-card');
    await t.tap(find.text('Support').first);
    await wait(t, 6);
    await binding.takeScreenshot('s3-support');
    await t.drag(find.byType(CustomScrollView).last, const Offset(0, -700));
    await wait(t, 2);
    await binding.takeScreenshot('s4-support-below');
    await t.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('More')));
    await wait(t, 3);
    await binding.takeScreenshot('s5-more');
  });
}
