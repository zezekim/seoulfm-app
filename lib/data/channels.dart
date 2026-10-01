import 'package:flutter/material.dart';
import 'package:seoulfm/data/station_genres.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/data/app_language.dart';
import 'package:seoulfm/data/station_taglines.dart';

/// Presentation overrides on top of `GET /v3/stations` (lib/channels.ts). The line-up
/// comes from the API; this registry only holds names, taglines, colours, streams,
/// pre-announcements and display order. Keep it in step with the site.
class ChannelConfig {
  const ChannelConfig({
    required this.key,
    this.name,
    this.tagline,
    this.genre,
    this.slug,
    this.accent,
    this.stream,
    this.fallbackManifest,
    this.lossless = false,
    this.marathon = false,
    this.comingSoon = false,
  });
  final String key;
  final String? name, tagline, genre, slug, accent, stream, fallbackManifest;
  final bool lossless, marathon, comingSoon;
}

const channelRegistry = <ChannelConfig>[
  ChannelConfig(
    key: 'seoulfm',
    name: 'Pop!',
    tagline: 'The original. Today’s K-pop, 24/7, shaped by your requests.',
    genre: 'K-Pop',
    accent: '#ff3b5c',
    slug: 'pop',
    stream: 'public',
    fallbackManifest: '${Config.streamBase}/v2/stream/manifest',
  ),
  ChannelConfig(
    key: 'hifi',
    name: 'HIFI',
    tagline: 'Lossless FLAC, as the studio heard it. For the good headphones.',
    genre: 'Lossless · FLAC',
    accent: '#a78bfa',
    lossless: true,
  ),
  ChannelConfig(
    key: 'new',
    name: 'Fresh K-Pop!',
    tagline: 'K-pop released in the last 60 days. Hear it as it drops.',
    genre: 'New releases',
    accent: '#5b6cff',
    slug: 'new-releases',
  ),
  ChannelConfig(
    key: 'marathon',
    name: 'Marathon',
    tagline: 'One group, one full hour. Their best songs, back to back.',
    genre: 'One group · One hour',
    accent: '#e0457b',
    marathon: true,
  ),
  ChannelConfig(
    key: 'dance',
    name: 'Dance',
    tagline: 'Dance and electronic. Built for moving.',
    genre: 'Dance · Electronic',
    accent: '#22c7d6',
  ),
  ChannelConfig(
    key: '2010s',
    name: '2010s',
    tagline: 'The decade K-pop went global. 2010 through 2019, back to back.',
    genre: '2010 – 2019',
    accent: '#3c9df5',
  ),
  ChannelConfig(
    key: 'classics',
    name: 'Classics',
    tagline: 'First generation to golden era. The songs that built K-pop.',
    genre: '1990s – 2000s',
    accent: '#f5b73c',
  ),
  ChannelConfig(
    key: 'indie',
    name: 'Indie',
    tagline: 'Bands, bedroom pop and everything off the idol track.',
    genre: 'Indie',
    accent: '#9bbf3b',
  ),
  ChannelConfig(
    key: 'hiphop',
    name: 'HipHop',
    tagline: 'Korean hip-hop and rap, from the underground to the charts.',
    genre: 'Hip-Hop · Rap',
    accent: '#f4622a',
  ),
  ChannelConfig(key: 'rnb', name: 'R&B', tagline: 'Korean R&B and soul. Smooth, late and close.', genre: 'R&B · Soul', accent: '#c07a3e'),
  ChannelConfig(
    key: 'ballad',
    name: 'Ballad',
    tagline: 'The big voices and the slow songs. Ballads, all day.',
    genre: 'Ballad',
    accent: '#e889b5',
  ),
  ChannelConfig(
    key: 'ost',
    name: 'OST',
    tagline: 'The songs from the dramas. Every scene you remember.',
    genre: 'OST · K-Drama',
    accent: '#2fb38f',
  ),
];

const _fallbackAccent = Color(0xFFF4F4F5);

/// A channel as the UI sees it: presentation resolved, live station data attached.
class Channel {
  Channel({
    required this.key,
    required String name,
    required this.tagline,
    required this.genre,
    required this.color,
    required this.slug,
    required this.stream,
    this.fallbackManifest,
    required this.lossless,
    required this.marathon,
    required this.comingSoon,
    this.live,
  }) : rawName = name;

  final String key, rawName, tagline, slug, stream;

  /// The name as shown (isolated inside right-to-left text).
  String get name => isolate(rawName);

  /// The tagline in the app's language (the site's translations), else the registry's.
  String get localTagline => stationTaglines[AppLanguage.tag]?[key] ?? stationTaglines[AppLanguage.language]?[key] ?? tagline;

  /// The genre line in the app's language ("New releases", "Dance · Electronic"), else as configured.
  String? get localGenre => stationGenres[AppLanguage.tag]?[key] ?? stationGenres[AppLanguage.language]?[key] ?? genre;
  final String? genre, fallbackManifest;
  final Color color;
  final bool lossless, marathon, comingSoon;
  final StationSummary? live;

  bool get onAir => !comingSoon && (live?.onAir ?? true);
  bool get tunable => !comingSoon;

  /// `/v3/streams/{stream}/manifest.m3u8`. Never build segment URLs by hand.
  String get manifest => '${Config.apiBase}/streams/${Uri.encodeComponent(stream)}/manifest.m3u8';

  /// One AAC quality's media playlist (48, 128, 192 or 320 kbps). Playing one directly, not
  /// the master, keeps the player from starting on the first listed (lowest) quality and
  /// re-buffering on every quality switch: each has its own init segment.
  String variant(int kbps) => '$manifest?bitrate=$kbps';

  /// The FLAC media playlist (not the master: its relative variant URI drops the acknowledgement).
  String get losslessManifest =>
      '${Config.apiBase}/streams/${Uri.encodeComponent(stream)}/lossless/manifest.m3u8?bitrate=lossless&accept_data_usage=true';

  /// The station's page on the site, for sharing.
  String get webUrl => '${Config.siteUrl}/$slug/';

  static Channel _from(ChannelConfig? c, StationSummary? live) {
    final key = c?.key ?? live!.key;
    final comingSoon = (c?.comingSoon ?? false) && live == null;
    return Channel(
      key: key,
      name: c?.name ?? live?.shortName ?? live?.name ?? key,
      tagline: c?.tagline ?? live?.tagline ?? live?.description ?? '',
      genre: c?.genre ?? live?.genre,
      color: parseHex(live?.accentColor) ?? parseHex(c?.accent) ?? _fallbackAccent,
      slug: c?.slug ?? key,
      stream: c?.stream ?? key,
      fallbackManifest: c?.fallbackManifest,
      lossless: c?.lossless ?? false,
      marathon: c?.marathon ?? false,
      comingSoon: comingSoon,
      live: live,
    );
  }

  /// Registry entries in order, then every other station the API lists as `public`.
  static List<Channel> build(List<StationSummary>? stations) {
    final byKey = {for (final s in stations ?? const <StationSummary>[]) s.key: s};
    final registryKeys = channelRegistry.map((c) => c.key).toSet();
    final discovered = (stations ?? const <StationSummary>[]).where((s) => !registryKeys.contains(s.key) && s.isPublic).toList()
      ..sort((a, b) => a.sortOrder != b.sortOrder ? a.sortOrder - b.sortOrder : a.key.compareTo(b.key));
    return [for (final c in channelRegistry) _from(c, byKey[c.key]), for (final s in discovered) _from(null, s)];
  }
}
