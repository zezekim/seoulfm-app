import 'package:flutter/material.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/platform/deep_links.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/screens/wall_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens what a link to seoul.fm points at (see `parseDeepLink`). [context] is the shell's.
Future<void> openDeepLink(BuildContext context, AppState app, Uri uri) async {
  final link = parseDeepLink(uri, stations: stationSlugs(app.channels.channels));
  switch (link) {
    case null || HomeLink():
      return;
    case SongLink(:final id):
      await _openSong(() => api.track(id), uri);
    case SongSlugLink(:final artist, :final title):
      await _openSong(() => api.trackLookup(artist, title), uri);
    case ArtistLink(:final key):
      Nav.openArtist(key);
    case StationLink(:final key):
      await app.tuneIn(key, play: true);
      if (context.mounted) await Nav.showNowPlaying(context);
    case WallLink():
      Nav.push(const WallScreen());
    case SupportLink():
      // With support off there is no page to open: the link just opens the app.
      if (Config.supportEnabled) Nav.openSupport();
    case WebLink(:final url):
      await _openWeb(url);
  }
}

/// Loads the song first, so its page (and its share button) has the whole track; a song the
/// API can't find still has its page on the site.
Future<void> _openSong(Future<TrackDetail> Function() load, Uri uri) async {
  Track? track;
  try {
    track = (await load()).track;
  } catch (_) {}
  if (track?.id != null) {
    Nav.openSong(track!);
  } else {
    await _openWeb(webUrl(uri));
  }
}

Future<void> _openWeb(Uri url) async {
  try {
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  } catch (_) {}
}
