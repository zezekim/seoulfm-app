import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';
import 'package:seoulfm/ui/widgets/support_card.dart';

import 'helpers.dart';

/// Home, the player, Support and More in the language given by LOCALE (a language tag),
/// e.g. --dart-define=LOCALE=ar for right-to-left.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const tag = String.fromEnvironment('LOCALE', defaultValue: 'ar');

  testWidgets('languages', (t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('seoulfm-locale', tag);
    await launch(binding);
    await wait(t, 14);
    await binding.takeScreenshot('$tag-1-home');
    await t.drag(find.byType(CustomScrollView).first, const Offset(0, -620));
    await wait(t, 2);
    await binding.takeScreenshot('$tag-2-home-below');
    await t.tap(find.byType(MiniPlayer));
    await wait(t, 4);
    await binding.takeScreenshot('$tag-3-player');
    await t.dragFrom(const Offset(200, 300), const Offset(0, 1500));
    await wait(t, 3);
    await t.tap(find.byType(SupportCard).first);
    await wait(t, 4);
    await binding.takeScreenshot('$tag-4-support');
    await prefs.remove('seoulfm-locale');
  });
}
