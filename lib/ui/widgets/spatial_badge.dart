import 'package:flutter/material.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/widgets/common.dart';

/// The name of SeoulFM's processing, as the badge prints it (a name, not translated).
const spatialAudioName = '3D BS2B Audio';

/// "3D BS2B Audio" on the player, the way Apple Music shows Dolby Atmos: a small frosted tag
/// between the times. Tap it to read what it means.
class SpatialAudioBadge extends StatelessWidget {
  const SpatialAudioBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: spatialAudioName,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => showSpatialAudioInfo(context),
        child: Padding(
          // A comfortable target around a small tag.
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Container(
            padding: const EdgeInsets.fromLTRB(6, 3, 7, 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.spatial, size: 11, color: Colors.white.withValues(alpha: 0.85)),
                const SizedBox(width: 4),
                Text(
                  spatialAudioName,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// What 3D BS2B Audio is, in a short sheet.
Future<void> showSpatialAudioInfo(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  showDragHandle: true,
  builder: (sheet) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: sheet.sfm.text.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: Icon(AppIcons.spatial, size: 28, color: sheet.sfm.text),
          ),
          const SizedBox(height: 14),
          const Text(spatialAudioName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
          const SizedBox(height: 8),
          Text(
            sheet.l.spatialAudioBody,
            textAlign: TextAlign.center,
            style: TextStyle(color: sheet.sfm.muted, height: 1.45),
          ),
        ],
      ),
    ),
  ),
);
