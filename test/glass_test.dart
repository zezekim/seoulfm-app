import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seoulfm/platform/accessibility_prefs.dart';
import 'package:seoulfm/ui/widgets/glass.dart';

Widget _glass(MediaQueryData media) => MaterialApp(
  home: MediaQuery(
    data: media,
    child: const Scaffold(
      body: Center(child: Glass(child: SizedBox(width: 200, height: 60))),
    ),
  ),
);

void main() {
  tearDown(() => AccessibilityPrefs.reduceTransparency.value = false);

  testWidgets('glass blurs what is behind it by default', (tester) async {
    await tester.pumpWidget(_glass(const MediaQueryData()));
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('glass is a solid pane with high contrast', (tester) async {
    await tester.pumpWidget(_glass(const MediaQueryData(highContrast: true)));
    expect(find.byType(Glass), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('glass turns solid when Reduce Transparency is switched on', (tester) async {
    await tester.pumpWidget(AccessibilityScope(child: _glass(const MediaQueryData())));
    expect(find.byType(BackdropFilter), findsOneWidget);
    AccessibilityPrefs.reduceTransparency.value = true;
    await tester.pump();
    expect(find.byType(BackdropFilter), findsNothing);
  });
}
