import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/platform/accessibility_prefs.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/state/request_tracker.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/screens/charts_screen.dart';
import 'package:seoulfm/ui/screens/home_screen.dart';
import 'package:seoulfm/ui/screens/more_screen.dart';
import 'package:seoulfm/ui/screens/search_screen.dart';
import 'package:seoulfm/ui/screens/welcome_screen.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/glass.dart';
import 'package:seoulfm/ui/widgets/lossless_sheet.dart';
import 'package:seoulfm/ui/widgets/mini_player.dart';
import 'package:seoulfm/ui/widgets/request_pill.dart';
import 'package:seoulfm/ui/icons.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showWelcomeIfNeeded(context);
      _onLosslessPrompt();
    });
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
    HapticFeedback.selectionClick();
    if (tab == Nav.tab.value) Nav.tabs[i].currentState?.popUntil((r) => r.isFirst);
    Nav.tab.value = tab;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final index = Nav.tab.value.index;
    final shell = PopScope(
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
        // The pages run under the floating player and the glass tab bar.
        extendBody: true,
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
            const RequestPill(),
            const MiniPlayer(),
            GlassTabBar(
              selected: index,
              onSelect: _select,
              items: [
                (AppIcons.home, l.tabHome),
                (AppIcons.request, l.tabRequest),
                (AppIcons.charts, l.tabCharts),
                (AppIcons.more, l.tabMore),
              ],
            ),
          ],
        ),
      ),
    );
    // While the player rises, the app sinks back behind it into a dimmed card (Apple Music).
    final corner = MediaQuery.paddingOf(context).top > 30 ? 48.0 : 16.0;
    // Reduce Motion: no sinking, only the veil dims as the player fades in over it.
    final still = context.reduceMotion;
    // The same widgets whether or not the player is up (or motion is reduced), so the tabs keep
    // their state; at rest they cost nothing (no scale, no clip, a clear veil).
    return ValueListenableBuilder<Animation<double>?>(
      valueListenable: Nav.playerPresentation,
      child: shell,
      builder: (_, presentation, shell) => AnimatedBuilder(
        animation: presentation ?? kAlwaysDismissedAnimation,
        child: shell,
        builder: (_, shell) {
          final v = Curves.easeOutCubic.transform(presentation?.value ?? 0);
          final sink = still ? 0.0 : v;
          return ColoredBox(
            color: Colors.black,
            child: Transform.scale(
              scale: 1 - 0.07 * sink,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(corner * sink),
                clipBehavior: sink == 0 ? Clip.none : Clip.antiAlias,
                child: Stack(
                  children: [
                    shell!,
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ColoredBox(color: Colors.black.withValues(alpha: 0.4 * v)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The tab bar as iOS 26 floats it: a glass capsule over the content, with a lens of brighter
/// glass that slides to the selected tab.
class GlassTabBar extends StatelessWidget {
  const GlassTabBar({super.key, required this.selected, required this.onSelect, required this.items});
  final int selected;
  final ValueChanged<int> onSelect;
  final List<(IconData, String)> items;

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final scale = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);
    final height = 34 + scale.scale(11 * 1.3) + 12;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 6, 14, bottom > 0 ? bottom - 6 : 10),
      child: Glass(
        radius: height / 2,
        child: SizedBox(
          height: height,
          child: LayoutBuilder(
            builder: (context, box) {
              final w = (box.maxWidth - 8) / items.length;
              return Stack(
                children: [
                  // The lens behind the selected tab.
                  // Reduce Motion: a short move with no overshoot.
                  AnimatedPositionedDirectional(
                    duration: Duration(milliseconds: context.reduceMotion ? 150 : 380),
                    curve: context.reduceMotion ? Curves.easeOut : Curves.easeOutBack,
                    start: 4 + w * selected,
                    top: 4,
                    bottom: 4,
                    width: w,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: c.text.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(height / 2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        for (var i = 0; i < items.length; i++)
                          Expanded(
                            child: Semantics(
                              button: true,
                              selected: i == selected,
                              label: items[i].$2,
                              excludeSemantics: true,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => onSelect(i),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(items[i].$1, size: 24, color: i == selected ? c.text : c.muted),
                                    const SizedBox(height: 2),
                                    Text(
                                      items[i].$2,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textScaler: scale,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        height: 1.3,
                                        fontWeight: i == selected ? FontWeight.w700 : FontWeight.w500,
                                        color: i == selected ? c.text : c.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
