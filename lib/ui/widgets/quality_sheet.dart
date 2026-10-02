import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/l10n/app_localizations.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/widgets/common.dart';

/// The name of a quality setting: Auto (null) or a rung of [RadioHandler.ladder].
String qualityName(AppLocalizations l, int? kbps) => switch (kbps) {
  null => l.qualityAuto,
  320 => l.qualityVeryHigh,
  192 => l.qualityHigh,
  128 => l.qualityNormal,
  _ => l.qualityDataSaver,
};

/// Picks the streaming quality: Auto (the default) or a fixed AAC bitrate.
Future<void> pickQuality(BuildContext context) async {
  final radio = context.read<RadioHandler>();
  final current = radio.quality.value;
  final picked = await showModalBottomSheet<(int?,)>(
    context: context,
    showDragHandle: true,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) {
      final l = context.l;
      final c = context.sfm;
      Widget option(int? kbps) {
        final on = kbps == current;
        return ListTile(
          title: Text(qualityName(l, kbps), style: TextStyle(fontWeight: on ? FontWeight.w700 : FontWeight.w500)),
          subtitle: Text(
            kbps == null ? l.qualityAutoBody : 'AAC · $kbps kbps',
            style: TextStyle(color: c.muted, fontSize: 13),
          ),
          trailing: on ? Icon(AppIcons.check, color: Theme.of(context).colorScheme.secondary) : null,
          onTap: () => Navigator.pop(context, (kbps,)),
        );
      }

      // Scrolls when large text makes the five options taller than the screen.
      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.quality, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              option(null),
              for (final kbps in RadioHandler.ladder) option(kbps),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 12),
                child: Text(
                  '${l.qualityFixedBody} ${l.qualityLosslessNote}',
                  style: TextStyle(color: c.faint, fontSize: 12.5, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (picked != null) await radio.setQuality(picked.$1);
}
