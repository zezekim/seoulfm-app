import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:seoulfm/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

/// Starts the app past the welcome (unless [welcome]), ready for screenshots on either platform.
Future<void> launch(IntegrationTestWidgetsFlutterBinding binding, {bool welcome = false}) async {
  final prefs = await SharedPreferences.getInstance();
  if (welcome) {
    await prefs.remove('seoulfm-onboarded');
    await prefs.remove('seoulfm-favourites');
  } else {
    await prefs.setBool('seoulfm-onboarded', true);
  }
  await prefs.setString('seoulfm-channel', 'seoulfm');
  app.main();
  // Android draws to a surface the screenshot can't read until it's converted; iOS needs nothing.
  if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
}

/// Pumps for [seconds] of real time (the app streams and polls; pumpAndSettle never settles).
Future<void> wait(WidgetTester t, num seconds) async {
  for (var i = 0; i < seconds * 4; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    await t.pump();
  }
}
