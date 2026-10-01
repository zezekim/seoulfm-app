import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Where the sound goes, as Apple Music's player offers it: on iOS the system AirPlay picker,
/// on Android the system output switcher. A plain Flutter button: an embedded native view
/// would break the player's masks and blurs on iOS, so native code opens the picker instead.
class OutputDeviceButton extends StatelessWidget {
  const OutputDeviceButton({super.key, this.color = Colors.white});
  final Color color;

  static const _channel = MethodChannel('fm.seoul/output');

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();
    final ios = defaultTargetPlatform == TargetPlatform.iOS;
    return IconButton(
      tooltip: ios ? 'AirPlay' : MaterialLocalizations.of(context).showMenuTooltip,
      onPressed: () {
        HapticFeedback.selectionClick();
        _channel.invokeMethod<void>('pick').catchError((_) {});
      },
      icon: Icon(ios ? Icons.airplay_rounded : Icons.speaker_group_outlined, color: color.withValues(alpha: 0.9), size: 24),
    );
  }
}
