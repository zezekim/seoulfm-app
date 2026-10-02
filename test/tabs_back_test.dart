import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seoulfm/ui/root_shell.dart';

/// Back in the tabbed shell, as Android sends it (with predictive back, the system only asks the
/// app when the app said it handles back: `setFrameworkHandlesBack`).
void main() {
  final navigators = List.generate(2, (_) => GlobalKey<NavigatorState>());
  late List<Object?> handlesBack;
  late int exits;

  Future<void> pumpShell(WidgetTester tester, ValueNotifier<int> tab) async {
    handlesBack = [];
    exits = 0;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemNavigator.setFrameworkHandlesBack') handlesBack.add(call.arguments);
      if (call.method == 'SystemNavigator.pop') exits++;
      return null;
    });
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<int>(
          valueListenable: tab,
          builder: (_, index, _) => TabsBackScope(
            index: index,
            navigators: navigators,
            onHome: () => tab.value = 0,
            builder: (track) => IndexedStack(
              index: index,
              children: [
                for (var i = 0; i < navigators.length; i++)
                  track(
                    i,
                    Navigator(
                      key: navigators[i],
                      onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => Text('tab $i')),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> push(WidgetTester tester, int tab, String name, {bool canPop = true}) async {
    navigators[tab].currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => PopScope(canPop: canPop, child: Text(name)),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  testWidgets('Home at its root leaves the app; a page on Home pops first', (tester) async {
    final tab = ValueNotifier(0);
    await pumpShell(tester, tab);
    expect(handlesBack.last, false);

    await push(tester, 0, 'page');
    expect(handlesBack.last, true);
    await back(tester);
    expect(find.text('page'), findsNothing);
    expect(handlesBack.last, false);
    expect(exits, 0);

    await back(tester);
    expect(exits, 1);
  });

  testWidgets('another tab pops its pages, then goes Home, then leaves', (tester) async {
    final tab = ValueNotifier(0);
    await pumpShell(tester, tab);
    tab.value = 1;
    await tester.pumpAndSettle();
    expect(handlesBack.last, true);

    await push(tester, 1, 'one');
    await push(tester, 1, 'two');
    await back(tester);
    expect(find.text('two'), findsNothing);
    expect(find.text('one'), findsOneWidget);
    await back(tester);
    expect(find.text('one'), findsNothing);
    expect(tab.value, 1);

    await back(tester);
    expect(tab.value, 0);
    expect(handlesBack.last, false);
    expect(exits, 0);

    await back(tester);
    expect(exits, 1);
  });

  testWidgets("a hidden tab's pages don't keep Home from leaving", (tester) async {
    final tab = ValueNotifier(1);
    await pumpShell(tester, tab);
    await push(tester, 1, 'one');
    tab.value = 0;
    await tester.pumpAndSettle();
    expect(handlesBack.last, false);
    await back(tester);
    expect(exits, 1);
  });

  testWidgets("a page's own PopScope still holds back", (tester) async {
    final tab = ValueNotifier(0);
    await pumpShell(tester, tab);
    await push(tester, 0, 'form', canPop: false);
    expect(handlesBack.last, true);
    await back(tester);
    expect(find.text('form'), findsOneWidget);
    expect(exits, 0);
  });
}
