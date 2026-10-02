import 'package:flutter/material.dart';
import 'package:seoulfm/ui/widgets/glass.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/data/app_language.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/screens/album_screen.dart';
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
    final share = GlassIconButton(
      icon: AppIcons.share,
      tooltip: context.l.share,
      onPressed: () =>
          SharePlus.instance.share(ShareParams(text: '${name ?? ''}\n${shareLink(artistUrl(artistKey), 'artist')}')),
    );
    // Apple Music's artist photo: most of the first screen.
    final heroHeight = (MediaQuery.sizeOf(context).height * 0.52).clamp(340.0, 520.0);

    /// Apple Music's artist header: the photo full bleed under round glass buttons, the name big
    /// over its foot, stretching on pull and collapsing into a bar with the name as it scrolls.
    SliverAppBar header(String title, String? subtitle, String? fallbackArt) => SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: heroHeight,
      backgroundColor: c.bg,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsetsDirectional.only(start: 12),
        child: GlassIconButton(
          icon: AppIcons.back,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      actions: [share, const SizedBox(width: 8)],
      flexibleSpace: LayoutBuilder(
        builder: (context, box) {
          // Fades the bar's title in once the photo has mostly scrolled away.
          final top = MediaQuery.paddingOf(context).top;
          final collapsed = ((heroHeight + top - box.maxHeight) / (heroHeight - kToolbarHeight)).clamp(0.0, 1.0);
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
                Artwork(fallbackArt, radius: 0, fullResolution: true),
                Artwork(photo, radius: 0, fullResolution: true),
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
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Glass(
                            radius: 10,
                            blur: 14,
                            shadow: false,
                            tint: const Color(0xFF2A2A2E),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text(
                                subtitle,
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.2,
                          height: 1.05,
                          color: Colors.white,
                        ),
                      ),
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
              '${context.l.plays(p.artist.playCount)} · ${context.l.songsCount(p.artist.trackCount)}',
              p.artist.artworkUrl,
            ),
            SliverList.list(
              children: [
                if (_latest(p.albums) case final latest?)
                  _LatestRelease(album: latest, artist: p.artist.name.isEmpty ? (name ?? '') : p.artist.name),
                if (p.topTracks.isNotEmpty) ...[
                  SectionHeader(context.l.topTracks),
                  for (final t in p.topTracks.take(10))
                    TrackRow(
                      requestable: true,
                      track: t,
                      onTap: () => Nav.openSong(t),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: context.l.request,
                            icon: Icon(AppIcons.request, color: c.muted),
                            onPressed: t.requestable == false ? null : () => showRequestSheet(context, t),
                          ),
                          IconButton(
                            tooltip: context.l.moreOptions,
                            icon: Icon(AppIcons.more, color: c.muted),
                            onPressed: () => showTrackActions(context, t),
                          ),
                        ],
                      ),
                    ),
                ],
                if (p.albums.isNotEmpty) ...[
                  SectionHeader(context.l.albums),
                  SizedBox(
                    // The cover plus two lines of text, which grow with the system text size.
                    height: 146 + MediaQuery.textScalerOf(context).scale(44),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: p.albums.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (_, i) {
                        final a = p.albums[i];
                        return Pressable(
                          onTap: () => Nav.push(
                            AlbumScreen(album: a, artist: p.artist.name.isEmpty ? (name ?? '') : p.artist.name),
                          ),
                          semanticLabel: a.title,
                          child: SizedBox(
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

/// The newest album with a year, for the "latest release" card.
AlbumWithTracks? _latest(List<AlbumWithTracks> albums) {
  final dated = albums.where((a) => a.year != null).toList()..sort((a, b) => b.year!.compareTo(a.year!));
  return dated.isEmpty ? null : dated.first;
}

/// The artist's newest release, Apple Music's card under the photo: cover, year, title.
class _LatestRelease extends StatelessWidget {
  const _LatestRelease({required this.album, required this.artist});
  final AlbumWithTracks album;
  final String artist;

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return Pressable(
      semanticLabel: album.title,
      onTap: () => Nav.push(AlbumScreen(album: album, artist: artist)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Row(
          children: [
            Artwork(album.artworkUrl, size: 110, radius: Radii.sm),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${album.year}',
                    style: TextStyle(
                      color: c.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: tracking(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    album.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.25),
                  ),
                  if (album.tracks.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(context.l.songsCount(album.tracks.length), style: TextStyle(color: c.muted, fontSize: 13)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
