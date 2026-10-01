import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/state/cover_colors.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/request_sheet.dart';

/// An album, as Apple Music shows one: the cover over a wash of its colour, the title, artist
/// and year, then its songs, each one tap from a request. The artist's profile already carries
/// the tracks, so nothing more is loaded.
class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key, required this.album, required this.artist});
  final AlbumWithTracks album;
  final String artist;

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    final l = context.l;
    final tint = context.watch<CoverColors>().of(album.artworkUrl);
    final top = MediaQuery.paddingOf(context).top;
    final details = [
      if (album.year != null) '${album.year}',
      if (album.tracks.isNotEmpty) l.songsCount(album.tracks.length),
    ].join(' · ');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, surfaceTintColor: Colors.transparent),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AnimatedContainer(
              duration: Motion.slow,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [(tint ?? c.surface).withValues(alpha: 0.55), c.bg],
                ),
              ),
              padding: EdgeInsets.fromLTRB(24, top + kToolbarHeight, 24, 20),
              child: Column(
                children: [
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      boxShadow: [BoxShadow(color: Color(0x80000000), blurRadius: 30, offset: Offset(0, 12))],
                    ),
                    child: Artwork(album.artworkUrl, size: 240, radius: Radii.md),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    album.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artist,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, color: c.text, fontWeight: FontWeight.w600),
                  ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(details, style: TextStyle(color: c.muted, fontSize: 13)),
                  ],
                ],
              ),
            ),
          ),
          SliverList.builder(
            itemCount: album.tracks.length,
            itemBuilder: (context, i) {
              final t = album.tracks[i];
              return TrackRow(
                requestable: true,
                track: t,
                onTap: () => Nav.openSong(t),
                trailing: IconButton(
                  tooltip: l.request,
                  icon: Icon(AppIcons.request, color: c.muted),
                  onPressed: t.requestable == false || t.id == null ? null : () => showRequestSheet(context, t),
                ),
              );
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 32)),
        ],
      ),
    );
  }
}
