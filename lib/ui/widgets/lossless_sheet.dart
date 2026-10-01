import 'package:flutter/material.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/icons.dart';

/// The API's data-usage notice for the lossless tier (`LosslessNotice`). Shown on every
/// tune-in; the answer is never stored. Closing it without answering keeps standard quality.
Future<void> showLosslessSheet(BuildContext context, AppState app, LosslessPrompt p) async {
  final accepted = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final c = context.sfm;
      final english = Localizations.localeOf(context).languageCode == 'en';
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(AppIcons.quality, color: p.channel.color),
                  const SizedBox(width: 10),
                  Text(context.l.losslessTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              // The API's own notice text is English only; other languages show their own.
              Text(
                english && p.tier.notice.isNotEmpty ? p.tier.notice : context.l.losslessFallbackNotice,
                style: TextStyle(color: c.muted, height: 1.45),
              ),
              const SizedBox(height: 12),
              if (p.tier.mbPerHour > 0) Text(context.l.losslessUses(p.tier.mbPerHour), style: const TextStyle(fontWeight: FontWeight.w600)),
              if (p.tier.defaultMbPerHour != null)
                Text(context.l.losslessUsesAac(p.tier.defaultMbPerHour!), style: TextStyle(color: c.muted, fontSize: 13)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: p.channel.color, foregroundColor: readableOn(p.channel.color)),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(context.l.losslessAccept),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l.losslessDecline)),
              ),
            ],
          ),
        ),
      );
    },
  );
  app.answerLossless(accepted ?? false);
}
