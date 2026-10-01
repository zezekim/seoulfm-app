import 'package:flutter/material.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/share.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/request_sheet.dart';
import 'package:seoulfm/ui/icons.dart';
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
    final share = IconButton(
      tooltip: context.l.share,
      onPressed: () =>
          SharePlus.instance.share(ShareParams(text: '${name ?? ''}\n${shareLink(artistUrl(artistKey), 'artist')}')),
      icon: const Icon(AppIcons.share),
    );

    /// Spotify's artist header: the photo full width, stretching on pull, collapsing into a bar
    /// with the name as the page scrolls.
    SliverAppBar header(String title, String? subtitle, String? fallbackArt) => SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 340,
      backgroundColor: c.bg,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
      actions: [share],
      flexibleSpace: LayoutBuilder(
        builder: (context, box) {
          // Fades the bar's title in once the photo has mostly scrolled away.
          final top = MediaQuery.paddingOf(context).top;
          final collapsed = ((340 + top - box.maxHeight) / (340 - kToolbarHeight)).clamp(0.0, 1.0);
          return FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground],
            centerTitle: false,
            titlePadding: const EdgeInsetsDirectional.only(start: 56, bottom: 16, end: 56),
            title: Opacity(
              opacity: collapsed > 0.8 ? (collapsed - 0.8) * 5 : 0,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: c.text, fontSize: 17),
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Artwork(fallbackArt, radius: 0),
                Artwork(photo, radius: 0),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withValues(alpha: 0.35), Colors.transparent, c.bg],
                      stops: const [0, 0.45, 1],
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: 20,
                  end: 20,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.2,
                          height: 1.05,
                        ),
                      ),
                      if (subtitle != null) Text(subtitle, style: TextStyle(color: c.muted, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return Scaffold(
      body: Loader<ArtistProfile>(
        load: () => api.artist(artistKey),
        frame: (context, child) => CustomScrollView(
          slivers: [
            header(name ?? '', null, null),
            SliverToBoxAdapter(child: child),
          ],
        ),
        builder: (context, p) => CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            header(
              p.artist.name.isEmpty ? (name ?? '') : p.artist.name,
              '${context.l.plays(p.artist.playCount)} · ${p.artist.trackCount} ${context.l.songs.toLowerCase()}',
              p.artist.artworkUrl,
            ),
            SliverList.list(
              children: [
                if (p.topTracks.isNotEmpty) ...[
                  SectionHeader(context.l.topTracks),
                  for (final t in p.topTracks.take(10))
                    TrackRow(
                      requestable: true,
                      track: t,
                      onTap: () => Nav.openSong(t),
                      trailing: IconButton(
                        tooltip: context.l.request,
                        icon: Icon(AppIcons.request, color: c.muted),
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
              ],
            ),
            SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 32)),
          ],
        ),
      ),
    );
  }
}
