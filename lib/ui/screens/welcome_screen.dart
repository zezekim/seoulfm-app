import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/data/app_language.dart';
import 'package:seoulfm/data/channels.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/state/cover_colors.dart';
import 'package:seoulfm/state/stations_now_playing.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/widgets/common.dart';

/// Shows the welcome once, on first launch.
Future<void> showWelcomeIfNeeded(BuildContext context) async {
  final app = context.read<AppState>();
  if (app.onboarded) return;
  await Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: true,
      transitionDuration: Motion.slow,
      pageBuilder: (_, _, _) => const WelcomeScreen(),
      transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
    ),
  );
}

/// The first run, in three pages: what SeoulFM is, pick your stations, and requests. The last
/// page starts the first station picked.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pages = PageController();
  final _picked = <String>[];
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.selectionClick();
    _pages.nextPage(duration: Motion.slow, curve: Motion.inOut);
  }

  void _finish({bool play = true}) {
    final app = context.read<AppState>();
    app.setFavourites(_picked);
    app.finishOnboarding();
    if (play && _picked.isNotEmpty) app.tuneIn(_picked.first, play: true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final accent = context.watch<ChannelController>().active.color;
    final buttonLabel = switch (_page) {
      0 => context.l.continueLabel,
      1 => context.l.continueLabel,
      _ => context.l.startListening,
    };
    return Theme(
      data: buildTheme(Brightness.dark, accent),
      child: Scaffold(
        backgroundColor: const Color(0xFF09090B),
        body: Stack(
          children: [
            // A soft glow in the station colour behind everything.
            PositionedDirectional(
              top: -160,
              start: -80,
              end: -80,
              height: 520,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(colors: [accent.withValues(alpha: 0.45), Colors.transparent]),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: pad.top, bottom: pad.bottom + 16),
              child: Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => _finish(play: false),
                      child: Text(context.l.skip, style: const TextStyle(color: Colors.white70)),
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pages,
                      onPageChanged: (p) => setState(() => _page = p),
                      children: [
                        const _Intro(),
                        _Pick(picked: _picked, onChanged: () => setState(() {})),
                        const _Requests(),
                      ],
                    ),
                  ),
                  _Dots(page: _page, count: 3),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    // 54 pt tall at least, taller if large text needs it.
                    child: FilledButton(
                      onPressed: _page < 2 ? _next : _finish,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF09090B),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(buttonLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.page, required this.count});
  final int page, count;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var i = 0; i < count; i++)
        AnimatedContainer(
          duration: Motion.base,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == page ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: i == page ? 0.95 : 0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
    ],
  );
}

class _Page extends StatelessWidget {
  const _Page({required this.top, required this.title, required this.body});
  final Widget top;
  final String title, body;
  static const _titleStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
    height: 1.1,
    color: Colors.white,
  );
  static const _bodyStyle = TextStyle(fontSize: 16, height: 1.45, color: Color(0xB3FFFFFF));

  /// The least the art shrinks to before the page scrolls instead.
  static const _minArt = 120.0;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: LayoutBuilder(
      builder: (context, box) {
        // The art takes what the words leave, scaled down on a small phone or at large text;
        // when even that leaves too little, the page scrolls with the art at its smallest.
        final base = DefaultTextStyle.of(context).style;
        double measure(String text, TextStyle style) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: base.merge(style)),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout(maxWidth: box.maxWidth);
          final height = painter.height;
          painter.dispose();
          return height;
        }
        final words = measure(title, _titleStyle) + 12 + measure(body, _bodyStyle) + 28;
        final fits = box.maxHeight - words >= _minArt;
        final column = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fits)
              Expanded(
                child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: top)),
              )
            else
              SizedBox(
                height: _minArt,
                width: double.infinity,
                child: FittedBox(fit: BoxFit.scaleDown, child: top),
              ),
            Text(title, style: _titleStyle),
            const SizedBox(height: 12),
            Text(body, style: _bodyStyle),
            const SizedBox(height: 28),
          ],
        );
        return fits ? column : SingleChildScrollView(child: column);
      },
    ),
  );
}

/// Page 1: the wordmark over a fan of what the stations play now.
class _Intro extends StatelessWidget {
  const _Intro();
  @override
  Widget build(BuildContext context) {
    final covers = context
        .watch<StationsNowPlaying>()
        .byStation
        .values
        .map((n) => n.current?.artworkUrl)
        .whereType<String>()
        .take(5)
        .toList();
    return _Page(
      top: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 170,
            width: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (var i = 0; i < covers.length; i++)
                  Transform.translate(
                    offset: Offset((i - (covers.length - 1) / 2) * 52, (i - (covers.length - 1) / 2).abs() * 10),
                    child: Transform.rotate(
                      angle: (i - (covers.length - 1) / 2) * 0.12,
                      child: Container(
                        decoration: const BoxDecoration(
                          boxShadow: [BoxShadow(color: Color(0x88000000), blurRadius: 20, offset: Offset(0, 8))],
                        ),
                        child: Artwork(covers[i], size: 120, radius: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'seoul',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(
                  text: 'fm',
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ],
            ),
            style: TextStyle(color: Colors.white, fontSize: 30, letterSpacing: -1),
          ),
        ],
      ),
      title: context.l.welcomeTitle,
      body: context.l.welcomeBody,
    );
  }
}

/// Page 2: the stations as tiles in their cover colours; tap to pick, in order.
class _Pick extends StatelessWidget {
  const _Pick({required this.picked, required this.onChanged});
  final List<String> picked;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final channels = context.watch<ChannelController>().tunable;
    final playing = context.watch<StationsNowPlaying>().byStation;
    final covers = context.watch<CoverColors>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              context.l.pickStationsTitle,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.8, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8, 6, 8, 16),
            child: Text(context.l.pickStationsBody, style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.6,
              ),
              itemCount: channels.length,
              itemBuilder: (_, i) {
                final ch = channels[i];
                final on = picked.contains(ch.key);
                final art = playing[ch.key]?.current?.artworkUrl;
                final fill = forWhiteText(covers.of(art) ?? ch.color);
                return _PickTile(
                  channel: ch,
                  fill: fill,
                  art: art,
                  selected: on,
                  onTap: () {
                    on ? picked.remove(ch.key) : picked.add(ch.key);
                    onChanged();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PickTile extends StatelessWidget {
  const _PickTile({required this.channel, required this.fill, required this.art, required this.selected, required this.onTap});
  final Channel channel;
  final Color fill;
  final String? art;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: isolate('SeoulFM ${channel.rawName}'),
    child: Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.base,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: selected ? Colors.white : Colors.transparent, width: 2.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (art != null)
              PositionedDirectional(
                end: -10,
                bottom: -8,
                child: Transform.rotate(angle: 0.4, child: Artwork(art, size: 60, radius: 6)),
              ),
            PositionedDirectional(
              start: 12,
              top: 10,
              end: 30,
              child: Text(
                channel.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
            PositionedDirectional(
              top: 8,
              end: 8,
              child: AnimatedScale(
                scale: selected ? 1 : 0,
                duration: Motion.base,
                curve: Curves.easeOutBack,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(AppIcons.check, size: 14, color: fill),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Page 3: requests, shown as what a listener sees when theirs is up.
class _Requests extends StatelessWidget {
  const _Requests();
  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    return _Page(
      top: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [accent, Color.lerp(accent, Colors.black, 0.5)!]),
          boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.5), blurRadius: 50)],
        ),
        child: Icon(AppIcons.request, size: 64, color: readableOn(accent)),
      ),
      title: context.l.requestsTitle,
      body: context.l.requestsBody,
    );
  }
}
