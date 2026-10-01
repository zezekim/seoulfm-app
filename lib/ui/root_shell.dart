import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/state/request_tracker.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/screens/charts_screen.dart';
import 'package:seoulfm/ui/screens/home_screen.dart';
import 'package:seoulfm/ui/screens/more_screen.dart';
import 'package:seoulfm/ui/screens/search_screen.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/lossless_sheet.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';

final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Four tabs, each with its own navigator, under the player bar; the bar opens the
/// full-screen player.
class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late final AppState _app = context.read<AppState>();

  static const _pages = <AppTab, Widget>{
    AppTab.home: HomeScreen(),
    AppTab.request: SearchScreen(),
    AppTab.charts: ChartsScreen(),
    AppTab.more: MoreScreen(),
  };

  @override
  void initState() {
    super.initState();
    _app.losslessPrompt.addListener(_onLosslessPrompt);
    _app.requests.addListener(_onRequestChange);
    Nav.tab.addListener(_onTab);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onLosslessPrompt());
  }

  @override
  void dispose() {
    _app.losslessPrompt.removeListener(_onLosslessPrompt);
    _app.requests.removeListener(_onRequestChange);
    Nav.tab.removeListener(_onTab);
    super.dispose();
  }

  void _onLosslessPrompt() {
    final p = _app.losslessPrompt.value;
    if (p != null && mounted) showLosslessSheet(context, _app, p);
  }

  void _onRequestChange() {
    final s = context.read<RequestTracker>().lastChange;
    if (s == null || !mounted) return;
    final l = context.l;
    final title = s.track.displayTitle;
    final text = switch (s.status) {
      'queued' => l.requestQueued(title),
      'scheduled' => l.requestScheduled(title),
      'played' || 'playing' => l.requestPlayed(title),
      'expired' || 'rejected' || 'cancelled' => s.statusReason ?? l.requestExpired(title),
      _ => null,
    };
    if (text == null) return;
    rootMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Artwork(s.track.artworkUrl, size: 32),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }

  void _onTab() => setState(() {});

  /// Tapping the selected tab again pops it to its root.
  void _select(int i) {
    final tab = AppTab.values[i];
    if (tab == Nav.tab.value) Nav.tabs[i].currentState?.popUntil((r) => r.isFirst);
    Nav.tab.value = tab;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    final l = context.l;
    final index = Nav.tab.value.index;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Nav.tabs[index].currentState;
        if (nav != null && nav.canPop()) {
          nav.pop();
        } else if (index != 0) {
          _select(0);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: index,
          children: [
            for (final tab in AppTab.values)
              Navigator(
                key: Nav.tabs[tab.index],
                onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => _pages[tab]!),
              ),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MiniPlayer(),
            NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: c.bg,
                indicatorColor: c.text.withValues(alpha: 0.08),
                surfaceTintColor: Colors.transparent,
                height: 62,
                labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: c.muted)),
              ),
              child: NavigationBar(
                selectedIndex: index,
                onDestinationSelected: _select,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home_rounded),
                    label: l.tabHome,
                  ),
                  NavigationDestination(icon: const Icon(Icons.queue_music_rounded), label: l.tabRequest),
                  NavigationDestination(icon: const Icon(Icons.bar_chart_rounded), label: l.tabCharts),
                  NavigationDestination(icon: const Icon(Icons.more_horiz_rounded), label: l.tabMore),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
