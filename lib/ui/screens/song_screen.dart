import 'package:flutter/material.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/share.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/request_sheet.dart';
import 'package:seoulfm/ui/icons.dart';

/// A song: cover, title and artist, request it live, its lyrics, songs like it.
class SongScreen extends StatelessWidget {
  const SongScreen({super.key, required this.track});
  final Track track;

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(tooltip: context.l.share, onPressed: () => shareSong(context, track), icon: const Icon(AppIcons.share)),
        ],
      ),
      body: Loader<TrackDetail>(
        load: () => api.track(track.id!),
        builder: (context, d) {
          final t = d.track;
          final meta = [t.album, t.releaseYear?.toString(), t.genre].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
          return ListView(
            padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 32),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
                child: AspectRatio(aspectRatio: 1, child: Artwork(t.artworkUrl ?? track.artworkUrl, radius: Radii.lg, iconSize: 48)),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.displayTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.4)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: t.artistKey == null ? null : () => Nav.openArtist(t.artistKey!, name: t.artist),
                      child: Text(
                        t.displayArtist,
                        style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (meta.isNotEmpty) ...[const SizedBox(height: 6), Text(meta, style: TextStyle(color: c.muted, fontSize: 13))],
                    if (t.playCount != null && t.playCount! > 0) ...[
                      const SizedBox(height: 2),
                      Text(context.l.plays(t.playCount!), style: TextStyle(color: c.faint, fontSize: 12)),
                    ],
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      onPressed: t.requestable == false ? null : () => showRequestSheet(context, t),
                      icon: const Icon(AppIcons.request),
                      label: Text(t.requestable == false ? context.l.notRequestable : context.l.requestTitle),
                    ),
                  ],
                ),
              ),
              if (t.hasLyrics || d.track.hasLyrics) _LyricsSection(trackId: t.id ?? track.id!),
              if (d.related.isNotEmpty) ...[
                SectionHeader(context.l.related),
                for (final r in d.related.take(10)) TrackRow(track: r, onTap: () => Nav.openSong(r)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _LyricsSection extends StatelessWidget {
  const _LyricsSection({required this.trackId});
  final String trackId;
  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return Loader<Lyrics>(
      load: () => api.lyrics(trackId),
      loading: const SizedBox.shrink(),
      builder: (context, l) {
        if (l.isEmpty) return const SizedBox.shrink();
        final text = l.plain ?? l.lines.map((x) => x.text).join('\n');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(context.l.lyrics, icon: AppIcons.lyrics),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.surface,
                border: Border.all(color: c.border),
                borderRadius: BorderRadius.circular(Radii.lg),
              ),
              child: SelectableText(text, style: const TextStyle(fontSize: 15, height: 1.7)),
            ),
          ],
        );
      },
    );
  }
}
