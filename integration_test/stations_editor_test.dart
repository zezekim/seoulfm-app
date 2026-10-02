import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';

import 'helpers.dart';

/// Your stations can be edited after the welcome: Edit opens the editor, the minus removes,
/// the plus adds, and Home follows.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('edit your stations', (t) async {
    await launch(binding, inAppShots: false);
    await wait(t, 10);
    final app = t.element(find.byType(MiniPlayer)).read<AppState>();
    app.setFavourites(['dance', 'ballad', 'hiphop']);
    await wait(t, 2);
    debugPrint('SHOT e1-home');
    await wait(t, 4);
    await t.tap(find.widgetWithText(TextButton, 'Edit'));
    await wait(t, 2);
    debugPrint('SHOT e2-editor');
    await wait(t, 4);
    await t.tap(find.byTooltip('Remove from Your stations').first);
    await wait(t, 1);
    await t.tap(find.byTooltip('Add to Your stations').first);
    await wait(t, 1);
    debugPrint('EDITOR favourites=${app.favourites.value}');
    expect(app.favourites.value.length, 3);
    expect(app.favourites.value.contains('dance'), isFalse);
    debugPrint('SHOT e3-edited');
    await wait(t, 4);
    await t.tap(find.text('Done'));
    await wait(t, 2);
    debugPrint('SHOT e4-home');
    await wait(t, 4);
  });
}
