import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:seoulfm/ui/root_shell.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';

import 'helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> tab(WidgetTester t, String name) async {
    await t.tap(find.descendant(of: find.byType(GlassTabBar), matching: find.text(name)));
    await wait(t, 4);
  }

  Future<void> pass(WidgetTester t, String theme) async {
    await tab(t, 'Home');
    await t.drag(find.byType(CustomScrollView).first, const Offset(0, 3000));
    await wait(t, 2);
    await binding.takeScreenshot('$theme-1-home');
    await t.drag(find.byType(CustomScrollView).first, const Offset(0, -700));
    await wait(t, 2);
    await binding.takeScreenshot('$theme-2-tiles');
    await tab(t, 'Charts');
    await binding.takeScreenshot('$theme-3-charts');
    await tab(t, 'Request');
    await binding.takeScreenshot('$theme-4-request');
    await tab(t, 'More');
    await binding.takeScreenshot('$theme-5-more');
    await t.tap(find.byType(MiniPlayer));
    await wait(t, 4);
    await binding.takeScreenshot('$theme-6-player');
    await t.dragFrom(const Offset(200, 600), const Offset(0, -560));
    await wait(t, 3);
    await binding.takeScreenshot('$theme-7-player-below');
    await t.dragFrom(const Offset(200, 300), const Offset(0, 1500));
    await wait(t, 3);
  }

  testWidgets('look', (t) async {
    await launch(binding);
    await wait(t, 15);
    await t.tap(find.descendant(of: find.byType(MiniPlayer), matching: find.byIcon(AppIcons.play)));
    await wait(t, 8);
    await pass(t, 'dark');
    await tab(t, 'More');
    await t.tap(find.text('Light'));
    await wait(t, 2);
    await pass(t, 'light');
    await tab(t, 'More');
    await t.tap(find.text('Dark'));
    await wait(t, 1);
  });
}
