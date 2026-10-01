import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/state/channel_controller.dart';

/// The launch hand-off: the native launch screen (the wordmark on near-black) continues here as
/// the first Flutter frame, then grows a touch and fades away once the stations are in (or
/// after 1.5 s), so opening the app is one movement rather than a cut.
class LaunchCurtain extends StatefulWidget {
  const LaunchCurtain({super.key, required this.child});
  final Widget child;
  @override
  State<LaunchCurtain> createState() => _LaunchCurtainState();
}

class _LaunchCurtainState extends State<LaunchCurtain> with SingleTickerProviderStateMixin {
  late final AnimationController _out = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
  late final ChannelController _channels = context.read<ChannelController>();
  Timer? _cap;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    _channels.addListener(_maybeGo);
    _cap = Timer(const Duration(milliseconds: 1500), _go);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeGo());
  }

  void _maybeGo() {
    if (_channels.loaded) _go();
  }

  void _go() {
    if (_out.isAnimating || _out.isCompleted) return;
    _cap?.cancel();
    _out.forward().whenComplete(() {
      if (mounted) setState(() => _gone = true);
    });
  }

  @override
  void dispose() {
    _channels.removeListener(_maybeGo);
    _cap?.cancel();
    _out.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gone) return widget.child;
    return Stack(
      children: [
        widget.child,
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _out,
            builder: (_, _) {
              final t = Curves.easeInCubic.transform(_out.value);
              return Opacity(
                opacity: 1 - t,
                child: ColoredBox(
                  color: const Color(0xFF0A0A0B),
                  child: Center(
                    // The native splash's wordmark: 62% of a 256 pt square.
                    child: Transform.scale(
                      scale: 1 + 0.12 * t,
                      child: Image.asset('assets/icon/splash.png', width: 256, height: 256),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
