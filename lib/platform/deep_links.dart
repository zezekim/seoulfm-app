import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:seoulfm/data/channels.dart';

/// Where a link to seoul.fm (or `seoulfm://`) takes the listener in the app.
sealed class DeepLink {
  const DeepLink();
}

/// `/song/{id}/`: a catalog id (UUID) or a legacy numeric id.
final class SongLink extends DeepLink {
  const SongLink(this.id);
  final String id;
  @override
  bool operator ==(Object other) => other is SongLink && other.id == id;
  @override
  int get hashCode => id.hashCode;
  @override
  String toString() => 'SongLink($id)';
}

/// `/song/{artist-slug}/{title-slug}/`: the address the site links to, resolved by `/tracks/lookup`.
final class SongSlugLink extends DeepLink {
  const SongSlugLink(this.artist, this.title);
  final String artist, title;
  @override
  bool operator ==(Object other) => other is SongSlugLink && other.artist == artist && other.title == title;
  @override
  int get hashCode => Object.hash(artist, title);
  @override
  String toString() => 'SongSlugLink($artist, $title)';
}

/// `/artist/{key}/`.
final class ArtistLink extends DeepLink {
  const ArtistLink(this.key);
  final String key;
  @override
  bool operator ==(Object other) => other is ArtistLink && other.key == key;
  @override
  int get hashCode => key.hashCode;
  @override
  String toString() => 'ArtistLink($key)';
}

/// `/{station-slug}/` (`/pop/`, `/hifi/`), as the station's key.
final class StationLink extends DeepLink {
  const StationLink(this.key);
  final String key;
  @override
  bool operator ==(Object other) => other is StationLink && other.key == key;
  @override
  int get hashCode => key.hashCode;
  @override
  String toString() => 'StationLink($key)';
}

/// `/wall/`: the dedications wall.
final class WallLink extends DeepLink {
  const WallLink();
}

/// `/support/`.
final class SupportLink extends DeepLink {
  const SupportLink();
}

/// `/`: just the app.
final class HomeLink extends DeepLink {
  const HomeLink();
}

/// Any other page of the site, opened in the in-app browser.
final class WebLink extends DeepLink {
  const WebLink(this.url);
  final Uri url;
  @override
  bool operator ==(Object other) => other is WebLink && other.url == url;
  @override
  int get hashCode => url.hashCode;
  @override
  String toString() => 'WebLink($url)';
}

const _hosts = {'seoul.fm', 'www.seoul.fm'};

/// The site's language prefixes (`lib/locales.ts`); `/en/` only ever redirects to the bare path.
const _langs = {
  'en', 'kr', 'es', 'mx', 'pt', 'fr', 'de', 'it', 'pl', 'tr', 'ru', 'kz', 'ar', 'id', 'my', 'th', 'vn', 'jp', 'tw', //
  'cn',
};

/// Old station addresses the site still redirects (`middleware.ts`).
const _stationAliases = {'2010': '2010s'};

final _uuid = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
bool _isTrackId(String s) => RegExp(r'^\d+$').hasMatch(s) || _uuid.hasMatch(s);

/// Station page slugs (and keys, and the site's aliases) to station keys, for [parseDeepLink].
Map<String, String> stationSlugs(Iterable<Channel> channels) => {
  for (final c in channels) ...{c.key: c.key, c.slug: c.key},
  ..._stationAliases,
};

/// The site's address for [uri]: a `seoulfm://` link becomes the same page on seoul.fm.
Uri webUrl(Uri uri) {
  if (uri.scheme.toLowerCase() != 'seoulfm') return uri;
  final host = uri.host.toLowerCase();
  final segments = [if (host.isNotEmpty && !_hosts.contains(host)) uri.host, ...uri.pathSegments]
    ..removeWhere((s) => s.isEmpty);
  return Uri(
    scheme: 'https',
    host: 'seoul.fm',
    pathSegments: [...segments, ''],
    query: uri.query.isEmpty ? null : uri.query,
  );
}

/// What [uri] opens: null for a link that isn't ours (another host or scheme). The language
/// prefix, a trailing slash, `www.` and the query (share tracking) don't matter. [stations] maps
/// a station page's slug to its key (see [stationSlugs]); any other single-segment page is a [WebLink].
DeepLink? parseDeepLink(Uri uri, {Map<String, String> stations = const {}}) {
  final scheme = uri.scheme.toLowerCase();
  final host = uri.host.toLowerCase();
  List<String> segments;
  if (scheme == 'https' || scheme == 'http') {
    if (!_hosts.contains(host)) return null;
    segments = uri.pathSegments;
  } else if (scheme == 'seoulfm') {
    // `seoulfm://song/123` puts the first segment in the host; `seoulfm:///song/123` and
    // `seoulfm://seoul.fm/song/123` don't.
    segments = [if (host.isNotEmpty && !_hosts.contains(host)) host, ...uri.pathSegments];
  } else {
    return null;
  }
  segments = [for (final s in segments) s.trim()]..removeWhere((s) => s.isEmpty);
  if (segments.isNotEmpty && _langs.contains(segments.first.toLowerCase())) segments = segments.sublist(1);

  final web = WebLink(webUrl(uri));
  if (segments.isEmpty) return const HomeLink();

  final first = segments.first.toLowerCase();
  final rest = segments.sublist(1);
  final query = uri.queryParameters;
  switch (first) {
    case 'song':
      if (rest.length == 1 && _isTrackId(rest.first)) return SongLink(rest.first);
      if (rest.length == 2) return SongSlugLink(rest[0], rest[1]);
      // The site's old address, `/song/?id=X`.
      final id = query['id']?.trim() ?? '';
      if (rest.isEmpty && id.isNotEmpty) return SongLink(id);
      return web;
    case 'artist':
      if (rest.length == 1) return ArtistLink(rest.first);
      // `/artist/?name=X`: the API folds a name to the same key.
      final name = query['name']?.trim() ?? '';
      if (rest.isEmpty && name.isNotEmpty) return ArtistLink(name);
      return web;
    case 'wall' when rest.isEmpty:
      return const WallLink();
    case 'support' when rest.isEmpty:
      return const SupportLink();
  }
  final station = stations[first];
  if (station != null && rest.isEmpty) return StationLink(station);
  return web;
}

/// Links that open the app: the one it was launched with, then any that arrive while it runs.
/// They wait until the shell is ready to show them ([ready]), so a link opened on first launch
/// follows the welcome instead of landing under it.
class DeepLinks {
  DeepLinks._();
  static final instance = DeepLinks._();

  final _pending = <Uri>[];
  StreamSubscription<Uri>? _sub;
  void Function(Uri uri)? _open;

  /// Starts listening; links queue until [ready].
  void start() {
    if (_sub != null || kIsWeb) return;
    try {
      // The stream also delivers the link the app was launched with, once.
      _sub = AppLinks().uriLinkStream.listen(_receive, onError: (_) {});
    } catch (_) {
      // No plugin (tests).
    }
  }

  /// From now on, links go to [open], starting with any that came in before.
  void ready(void Function(Uri uri) open) {
    _open = open;
    final queued = List.of(_pending);
    _pending.clear();
    queued.forEach(open);
  }

  @visibleForTesting
  void receiveForTest(Uri uri) => _receive(uri);

  void _receive(Uri uri) {
    final open = _open;
    if (open == null) {
      _pending.add(uri);
    } else {
      open(uri);
    }
  }
}
