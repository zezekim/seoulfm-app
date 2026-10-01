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
import 'package:seoulfm/ui/screens/wall_screen.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/lossless_sheet.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';

final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Five tabs, each with its own navigator, over the player bar (the mobile site's shell).
class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  late final AppState _app = context.read<AppState>();

  static const _pages = <Widget>[HomeScreen(), SearchScreen(), ChartsScreen(), WallScreen(), MoreScreen()];

  @override
  void initState() {
    super.initState();
    _app.losslessPrompt.addListener(_onLosslessPrompt);
    _app.requests.addListener(_onRequestChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onLosslessPrompt());
  }

  @override
  void dispose() {
    _app.losslessPrompt.removeListener(_onLosslessPrompt);
    _app.requests.removeListener(_onRequestChange);
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

  void _select(int i) {
    if (i == _index) {
      Nav.tabs[i].currentState?.popUntil((r) => r.isFirst);
    }
    setState(() => _index = Nav.current = i);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    final l = context.l;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Nav.tabs[_index].currentState;
        if (nav != null && nav.canPop()) {
          nav.pop();
        } else if (_index != 0) {
          _select(0);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            for (var i = 0; i < _pages.length; i++)
              Navigator(
                key: Nav.tabs[i],
                onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => _pages[i]),
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
                selectedIndex: _index,
                onDestinationSelected: _select,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home_rounded),
                    label: l.tabHome,
                  ),
                  NavigationDestination(icon: const Icon(Icons.search_rounded), label: l.tabSearch),
                  NavigationDestination(icon: const Icon(Icons.bar_chart_rounded), label: l.tabCharts),
                  NavigationDestination(
                    icon: const Icon(Icons.favorite_border_rounded),
                    selectedIcon: const Icon(Icons.favorite_rounded),
                    label: l.tabWall,
                  ),
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
