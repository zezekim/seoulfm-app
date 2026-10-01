import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/audio/radio_handler.dart';
import 'package:seoulfm/state/runtime_config.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/widgets/common.dart';

/// Notices from the control plane (maintenance, stream status, announcements) and,
/// with [lossless], the FLAC fallback warning.
class Notices extends StatelessWidget {
  const Notices({super.key, this.lossless = false});
  final bool lossless;

  @override
  Widget build(BuildContext context) {
    final cfg = context.watch<RuntimeConfigController>().config;
    final radio = context.read<RadioHandler>();
    final items = <Widget>[];
    // Operator text is plain text, rendered as is.
    if (cfg.maintenance && (cfg.maintenanceMessage ?? cfg.maintenanceTitle) != null) {
      items.add(
        _NoticeCard(
          text: cfg.maintenanceMessage ?? cfg.maintenanceTitle!,
          level: 'warning',
          title: cfg.maintenanceTitle,
        ),
      );
    }
    if (!cfg.streamAvailable || cfg.streamNotice != null) {
      items.add(_NoticeCard(text: cfg.streamNotice ?? context.l.offline, level: 'warning'));
    }
    if (cfg.announcement != null) items.add(_NoticeCard(text: cfg.announcement!, level: cfg.announcementLevel));
    return ValueListenableBuilder<bool>(
      valueListenable: radio.losslessFailed,
      builder: (_, failed, _) => Column(
        children: [
          ...items,
          if (lossless && failed)
            _NoticeCard(
              text: context.l.losslessFailed,
              level: 'warning',
              action: TextButton(onPressed: radio.retryLossless, child: Text(context.l.retryFlac)),
            ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.text, required this.level, this.title, this.action});
  final String text, level;
  final String? title;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      'success' => const Color(0xFF2FB38F),
      'warning' => const Color(0xFFF5B73C),
      'danger' => const Color(0xFFFF5A5F),
      _ => const Color(0xFF3C9DF5),
    };
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) Text(title!, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(text, style: const TextStyle(fontSize: 13, height: 1.35)),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
