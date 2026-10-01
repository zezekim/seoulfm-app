import 'package:flutter_test/flutter_test.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/data/channels.dart';
import 'package:seoulfm/state/runtime_config.dart';
import 'package:seoulfm/ui/screens/home_screen.dart';

void main() {
  group('artworkSrc', () {
    test('moves the artwork CDN to the site copy', () {
      expect(artworkSrc('https://cdn-albumart.kpopradio.net/ab/cd.webp'), 'https://seoul.fm/api/art/ab/cd.webp');
    });
    test('makes site-relative paths absolute', () {
      expect(artworkSrc('/featured/xdi.webp'), 'https://seoul.fm/featured/xdi.webp');
    });
    test('keeps other URLs and drops empty ones', () {
      expect(artworkSrc('https://example.com/a.jpg'), 'https://example.com/a.jpg');
      expect(artworkSrc(''), isNull);
      expect(artworkSrc(null), isNull);
    });
  });

  group('NowPlaying', () {
    test('prefers the stream clock for the start', () {
      final np = NowPlaying.fromJson({
        'station': {'key': 'seoulfm', 'name': 'SeoulFM'},
        'on_air': true,
        'current': {
          'track_id': 'u1',
          'title': '봄날',
          'artist': 'BTS',
          'has_lyrics': true,
          'duration_ms': 274000,
          'artwork_url': 'https://cdn-albumart.kpopradio.net/x.webp',
        },
        'started_at_epoch': 1000,
        'started_at_epoch_ms': 1000500,
        'stream_started_at_epoch_ms': 1002000,
        'ends_at_epoch': 1274,
      });
      expect(np.startMs, 1002000);
      expect(np.current!.title, '봄날');
      expect(np.current!.hasLyrics, isTrue);
      expect(np.current!.artworkUrl, 'https://seoul.fm/api/art/x.webp');
    });
    test('falls back to station time, and to seconds', () {
      final np = NowPlaying.fromJson({
        'station': {'key': 'hifi'},
        'current': null,
        'started_at_epoch': 5,
      });
      expect(np.startMs, 5000);
      expect(np.current, isNull);
    });
  });

  test('Track.id falls back to the legacy id', () {
    expect(Track.fromJson({'track_id': null, 'legacy_song_id': 42}).id, '42');
  });

  group('Channel.build', () {
    test('keeps registry order and hides non-public extras', () {
      final list = Channel.build([
        StationSummary(key: 'ost', name: 'SeoulFM OST'),
        StationSummary(key: 'seoulfm', name: 'SeoulFM Pop!', accentColor: '#112233'),
        StationSummary(key: 'internal', name: 'Rig'),
        StationSummary(key: 'zzz', name: 'Late', isPublic: true, sortOrder: 99),
      ]);
      expect(list.first.key, 'seoulfm');
      expect(list.first.stream, 'public');
      expect(list.first.color.toARGB32(), 0xFF112233);
      expect(list.any((c) => c.key == 'internal'), isFalse);
      expect(list.last.key, 'zzz');
      expect(list.length, channelRegistry.length + 1);
    });
    test('builds manifests, never segment URLs', () {
      final hifi = Channel.build(null).firstWhere((c) => c.key == 'hifi');
      expect(hifi.manifest, 'https://api.seoul.fm/v3/streams/hifi/manifest.m3u8');
      expect(hifi.losslessManifest, contains('bitrate=lossless&accept_data_usage=true'));
      expect(hifi.lossless, isTrue);
    });
  });

  group('RuntimeConfig.parse', () {
    test('a body without maintenance is a failure', () {
      expect(RuntimeConfig.parse({'announcement': {}}), isNull);
      expect(RuntimeConfig.parse('nope'), isNull);
    });
    test('reads delays and ignores out-of-range ones', () {
      final c = RuntimeConfig.parse({
        'maintenance': {'enabled': false},
        'lyrics': {
          'delay_ms': 0,
          'station_delay_ms': {'hifi': 20000, 'bad': 999999},
        },
        'announcement': {'enabled': true, 'text': ' Hi ', 'level': 'weird'},
      })!;
      expect(c.delayFor('seoulfm'), 0);
      expect(c.delayFor('hifi'), 20000);
      expect(c.delayFor('bad'), 0);
      expect(c.announcement, 'Hi');
      expect(c.announcementLevel, 'info');
    });
    test('defaults when lyrics are missing', () {
      expect(RuntimeConfig.parse({'maintenance': {}})!.delayMs, RuntimeConfig.defaultDelayMs);
    });
  });

  test('spreadByArtist keeps the same artist three apart when it can', () {
    Track t(String a) => Track(artist: a, title: a);
    final out = spreadByArtist([t('A'), t('A'), t('A'), t('B'), t('C'), t('D'), t('E'), t('F'), t('G')]);
    expect(out.length, 9);
    for (var i = 0; i < out.length; i++) {
      for (var j = i + 1; j < out.length && j <= i + 3; j++) {
        if (out[i].artist == 'A') expect(out[j].artist, isNot('A'), reason: 'positions $i and $j');
      }
    }
  });
}
