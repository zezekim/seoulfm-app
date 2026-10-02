import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/data/app_language.dart';
import 'package:seoulfm/data/channels.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/state/stations_now_playing.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/widgets/common.dart';

/// Edits "Your stations", as Apple Music edits pinned items: the picked ones on top in their
/// order (drag the handle to reorder, the minus to remove), the rest below with a plus to add.
/// Every change is kept at once; Done just closes.
Future<void> showStationsEditor(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.85,
    maxChildSize: 0.95,
    builder: (context, scroll) => _StationsEditor(scroll: scroll),
  ),
);

class _StationsEditor extends StatelessWidget {
  const _StationsEditor({required this.scroll});
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final c = context.sfm;
    final l = context.l;
    return ValueListenableBuilder<List<String>>(
      valueListenable: app.favourites,
      builder: (context, keys, _) {
        final all = context.watch<ChannelController>().tunable;
        final picked = [for (final k in keys) ...all.where((ch) => ch.key == k)];
        final rest = all.where((ch) => !keys.contains(ch.key)).toList();

        void set(List<String> next) {
          HapticFeedback.selectionClick();
          app.setFavourites(next);
        }

        return ListView(
          controller: scroll,
          padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 16),
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l.yourStations, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l.done, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
              child: Text(l.pickStationsBody, style: TextStyle(color: c.muted, fontSize: 13.5)),
            ),
            if (picked.isNotEmpty)
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: picked.length,
                onReorderItem: (from, to) {
                  final next = [for (final ch in picked) ch.key];
                  next.insert(to, next.removeAt(from));
                  set(next);
                },
                itemBuilder: (context, i) {
                  final ch = picked[i];
                  return _Row(
                    key: ValueKey(ch.key),
                    channel: ch,
                    leading: IconButton(
                      tooltip: l.removeFromYourStations,
                      onPressed: () => set([
                        for (final k in keys)
                          if (k != ch.key) k,
                      ]),
                      icon: const Icon(AppIcons.remove, color: Color(0xFFFF5A5F)),
                    ),
                    trailing: ReorderableDragStartListener(
                      index: i,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(AppIcons.drag, color: c.muted),
                      ),
                    ),
                  );
                },
              ),
            if (rest.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 6),
                child: Text(
                  l.moreStations,
                  style: TextStyle(
                    color: c.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: tracking(0.4),
                  ),
                ),
              ),
              for (final ch in rest)
                _Row(
                  key: ValueKey('add-${ch.key}'),
                  channel: ch,
                  leading: IconButton(
                    tooltip: l.addToYourStations,
                    onPressed: () => set([...keys, ch.key]),
                    icon: const Icon(AppIcons.addCircle, color: Color(0xFF2FB38F)),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

/// A station in the editor: its control, the cover of what it plays, its name and tagline.
class _Row extends StatelessWidget {
  const _Row({super.key, required this.channel, required this.leading, this.trailing});
  final Channel channel;
  final Widget leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    final art = context.watch<StationsNowPlaying>().byStation[channel.key]?.current?.artworkUrl;
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 6, end: 6),
        child: Row(
          children: [
            leading,
            Artwork(art, size: 44, radius: Radii.sm),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isolate('SeoulFM ${channel.rawName}'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    Text(
                      channel.localTagline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: c.muted, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
