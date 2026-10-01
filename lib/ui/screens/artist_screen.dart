import 'package:flutter/material.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/share.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/request_sheet.dart';
import 'package:share_plus/share_plus.dart';

/// An artist: their photo (the site keeps it), top songs to request, albums.
class ArtistScreen extends StatelessWidget {
  const ArtistScreen({super.key, required this.artistKey, this.name});
  final String artistKey;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    final photo = '${Config.siteUrl}/api/artist-image/${Uri.encodeComponent(artistKey)}/';
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: context.l.share,
            onPressed: () => SharePlus.instance.share(ShareParams(text: '${name ?? ''}\n${shareLink(artistUrl(artistKey), 'artist')}')),
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: Loader<ArtistProfile>(
        load: () => api.artist(artistKey),
        builder: (context, p) => ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 320,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Artwork(p.artist.artworkUrl, radius: 0),
                  Artwork(photo, radius: 0),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent, c.bg],
                        stops: const [0, 0.45, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.artist.name.isEmpty ? (name ?? '') : p.artist.name,
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.6),
                        ),
                        Text(
                          '${context.l.plays(p.artist.playCount)} · ${p.artist.trackCount} ${context.l.songs.toLowerCase()}',
                          style: TextStyle(color: c.muted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (p.topTracks.isNotEmpty) ...[
              SectionHeader(context.l.topTracks),
              for (final t in p.topTracks.take(10))
                TrackRow(
                  track: t,
                  onTap: () => Nav.openSong(t),
                  trailing: IconButton(
                    tooltip: context.l.request,
                    icon: Icon(Icons.queue_music_rounded, color: c.muted),
                    onPressed: t.requestable == false ? null : () => showRequestSheet(context, t),
                  ),
                ),
            ],
            if (p.albums.isNotEmpty) ...[
              SectionHeader(context.l.albums),
              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: p.albums.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final a = p.albums[i];
                    return SizedBox(
                      width: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Artwork(a.artworkUrl, size: 140, radius: Radii.md),
                          const SizedBox(height: 6),
                          Text(
                            a.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          if (a.year != null) Text('${a.year}', style: TextStyle(color: c.muted, fontSize: 12)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
