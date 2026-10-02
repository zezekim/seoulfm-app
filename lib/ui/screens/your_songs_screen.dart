import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/state/saved_songs.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/request_sheet.dart';
import 'package:seoulfm/ui/widgets/save_button.dart';

/// Whether [t] can be asked for (the request sheet needs an id).
bool _requestable(Track t) => t.requestable != false && t.id != null;

/// The songs the listener saved, newest first: request one, open it, or swipe it away (with an
/// undo). A random pick from the requestable ones is a tap away.
class YourSongsScreen extends StatelessWidget {
  const YourSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SavedSongs>();
    final songs = store.songs;
    final c = context.sfm;
    final l = context.l;
    final requestable = songs.map((s) => s.track).where(_requestable).toList();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          largeTitleBar(context, l.yourSongs),
          if (songs.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: EmptyState(icon: AppIcons.saved, title: l.yourSongsEmptyTitle, body: l.yourSongsEmptyBody),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.songsCount(songs.length), style: TextStyle(color: c.muted, fontSize: 13)),
                    if (requestable.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      // A surprise from the list: a random requestable one, straight to the request sheet.
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: c.solid,
                          foregroundColor: c.solidFg,
                          minimumSize: const Size.fromHeight(48),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          showRequestSheet(context, requestable[Random().nextInt(requestable.length)]);
                        },
                        icon: const Icon(AppIcons.shuffle, size: 20),
                        label: Text(l.requestFromYourSongs, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SliverList.builder(
              itemCount: songs.length,
              itemBuilder: (context, i) => _SavedRow(song: songs[i]),
            ),
          ],
          // Clear of the floating player and the tab bar.
          SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 24)),
        ],
      ),
    );
  }
}

/// A saved song: swipe it from the end edge (right to left in English) to remove it.
class _SavedRow extends StatelessWidget {
  const _SavedRow({required this.song});
  final SavedSong song;

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    final t = song.track;
    const red = Color(0xFFE5484D);
    return Dismissible(
      key: ValueKey('saved-${SavedSongs.keyOf(t)}-${song.savedAt.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {DismissDirection.endToStart: 0.3},
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        toggleSaved(context, t);
      },
      background: Container(
        color: red,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                context.l.removeFromYourSongs,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(AppIcons.delete, color: Colors.white, size: 22),
          ],
        ),
      ),
      child: TrackRow(
        track: t,
        onTap: t.id == null ? () => showTrackActions(context, t) : () => Nav.openSong(t),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: context.l.request,
              icon: Icon(AppIcons.request, color: c.muted),
              onPressed: _requestable(t) ? () => showRequestSheet(context, t) : null,
            ),
            IconButton(
              tooltip: context.l.moreOptions,
              icon: Icon(AppIcons.more, color: c.muted),
              onPressed: () => showTrackActions(context, t),
            ),
          ],
        ),
      ),
    );
  }
}
