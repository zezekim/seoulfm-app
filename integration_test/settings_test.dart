import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';

import 'helpers.dart';

/// More's settings: the quality picker (Auto by default, a fixed rate held and kept) and the
/// version line with the build and commit.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('quality and version', (t) async {
    await launch(binding);
    await wait(t, 10);
    final radio = t.element(find.byType(MiniPlayer)).read<RadioHandler>();
    await radio.setQuality(null);
    expect(radio.quality.value, isNull);

    await t.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('More')));
    await wait(t, 3);
    await t.scrollUntilVisible(find.text('Quality'), 200, scrollable: find.byType(Scrollable).first);
    await wait(t, 1);
    await t.tap(find.text('Quality'));
    await wait(t, 2);
    await binding.takeScreenshot('quality-sheet');
    await t.tap(find.text('High'));
    await wait(t, 2);
    expect(radio.quality.value, 192);
    expect(find.text('High'), findsOneWidget); // the row now names it

    // Playing holds the fixed rate.
    await radio.play();
    await wait(t, 10);
    debugPrint('QUALITY fixed=${radio.quality.value} playing=${radio.aacKbps.value}');
    expect(radio.aacKbps.value, 192);

    await radio.setQuality(null);
    await wait(t, 6);
    debugPrint('QUALITY auto playing=${radio.aacKbps.value}');
    expect(radio.aacKbps.value, RadioHandler.ladder.first);
    await radio.pause();

    final version = 'Version ${AppBuild.label}';
    debugPrint('VERSION $version');
    await t.scrollUntilVisible(find.text(version), 300, scrollable: find.byType(Scrollable).first);
    await wait(t, 1);
    await binding.takeScreenshot('version');
  });
}
