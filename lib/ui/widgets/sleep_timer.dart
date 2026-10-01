import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/icons.dart';

const sleepChoices = [15, 30, 45, 60, 90];

/// Fades out and pauses after a while. Lives in the radio, so it works with the screen off.
Future<void> pickSleepTimer(BuildContext context) async {
  final radio = context.read<RadioHandler>();
  final minutes = await showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    useRootNavigator: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l.sleepTimer, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final m in sleepChoices) ListTile(title: Text(context.l.sleepMinutes(m)), onTap: () => Navigator.pop(context, m)),
          ListTile(title: Text(context.l.sleepOff), onTap: () => Navigator.pop(context, 0)),
        ],
      ),
    ),
  );
  if (minutes == null) return;
  radio.setSleepTimer(minutes == 0 ? null : Duration(minutes: minutes));
}

class SleepTimerButton extends StatefulWidget {
  const SleepTimerButton({super.key, this.onImage = false, this.iconOnly = false});
  final bool onImage;

  /// Just the moon (the player), lit while a timer runs; the label form is for settings.
  final bool iconOnly;
  @override
  State<SleepTimerButton> createState() => _SleepTimerButtonState();
}

class _SleepTimerButtonState extends State<SleepTimerButton> {
  late final Timer _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 20), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _tick.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radio = context.read<RadioHandler>();
    final color = widget.onImage ? Colors.white.withValues(alpha: 0.7) : context.sfm.muted;
    return ValueListenableBuilder<DateTime?>(
      valueListenable: radio.sleepAt,
      builder: (_, at, _) {
        final left = at?.difference(DateTime.now());
        if (widget.iconOnly) {
          final on = left != null;
          return IconButton(
            tooltip: on ? context.l.sleepStopsIn((left.inSeconds / 60).ceil()) : context.l.sleepTimer,
            onPressed: () => pickSleepTimer(context),
            icon: Icon(on ? AppIcons.sleepOn : AppIcons.sleep, size: 22, color: on ? Colors.white : color),
          );
        }
        return TextButton.icon(
          onPressed: () => pickSleepTimer(context),
          icon: Icon(AppIcons.sleep, size: 18, color: color),
          label: Text(
            left == null ? context.l.sleepTimer : context.l.sleepStopsIn((left.inSeconds / 60).ceil()),
            style: TextStyle(fontSize: 12, color: color),
          ),
        );
      },
    );
  }
}
