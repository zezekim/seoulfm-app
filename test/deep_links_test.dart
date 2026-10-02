import 'package:flutter_test/flutter_test.dart';
import 'package:seoulfm/data/channels.dart';
import 'package:seoulfm/platform/deep_links.dart';

void main() {
  final stations = stationSlugs(Channel.build(null));
  DeepLink? parse(String url) => parseDeepLink(Uri.parse(url), stations: stations);

  const uuid = '3f2c9a1e-4b7d-4e2a-9c1f-0a1b2c3d4e5f';

  // Every pattern, on both hosts, bare and under a language prefix, with and without the
  // trailing slash, with the share tracking appended.
  void expectAll(String path, DeepLink expected) {
    for (final host in ['seoul.fm', 'www.seoul.fm']) {
      for (final lang in ['', '/kr', '/jp', '/en', '/es']) {
        for (final slash in ['/', '']) {
          for (final query in ['', '?utm_source=app&utm_medium=share&utm_campaign=song']) {
            final url = 'https://$host$lang$path$slash$query';
            expect(parse(url), expected, reason: url);
          }
        }
      }
    }
  }

  group('site links', () {
    test('song by id', () {
      expectAll('/song/$uuid', const SongLink(uuid));
      expectAll('/song/12345', const SongLink('12345'));
    });

    test('song by slugs', () {
      expectAll('/song/bts/spring-day', const SongSlugLink('bts', 'spring-day'));
    });

    test('artist', () {
      expectAll('/artist/newjeans', const ArtistLink('newjeans'));
      expect(parse('https://seoul.fm/artist/g-dragon%20x/'), const ArtistLink('g-dragon x'));
    });

    test('stations by slug, key and alias', () {
      expectAll('/pop', const StationLink('seoulfm'));
      expectAll('/hifi', const StationLink('hifi'));
      expectAll('/new-releases', const StationLink('new'));
      expectAll('/2010s', const StationLink('2010s'));
      expectAll('/seoulfm', const StationLink('seoulfm'));
      expectAll('/2010', const StationLink('2010s'));
    });

    test('wall and support', () {
      expectAll('/wall', const WallLink());
      expectAll('/support', const SupportLink());
    });

    test('home', () {
      expect(parse('https://seoul.fm'), const HomeLink());
      expect(parse('https://seoul.fm/'), const HomeLink());
      expect(parse('https://www.seoul.fm/?utm_source=app'), const HomeLink());
      expect(parse('https://seoul.fm/kr/'), const HomeLink());
      expect(parse('https://seoul.fm/jp'), const HomeLink());
    });

    test('legacy query addresses', () {
      expect(parse('https://seoul.fm/song/?id=42'), const SongLink('42'));
      expect(parse('https://seoul.fm/kr/song?id=$uuid'), const SongLink(uuid));
      expect(parse('https://seoul.fm/artist/?name=IU'), const ArtistLink('IU'));
    });

    test('other pages open on the site', () {
      for (final url in [
        'https://seoul.fm/faq/',
        'https://seoul.fm/kr/charts/?utm_source=x',
        'https://www.seoul.fm/song/not-an-id/',
        'https://seoul.fm/song/',
        'https://seoul.fm/song/a/b/c/',
        'https://seoul.fm/artist/',
        'https://seoul.fm/artist/a/b/',
        'https://seoul.fm/wall/extra/',
        'https://seoul.fm/marathon/vote/bts/',
        'https://seoul.fm/no-such-station/',
      ]) {
        expect(parse(url), WebLink(Uri.parse(url)), reason: url);
      }
    });

    test('http and an upper-case host still count', () {
      expect(parse('http://seoul.fm/wall/'), const WallLink());
      expect(parse('https://WWW.Seoul.FM/support/'), const SupportLink());
    });

    test('other hosts and schemes are not ours', () {
      expect(parse('https://example.com/song/12345/'), isNull);
      expect(parse('https://api.seoul.fm/song/12345/'), isNull);
      expect(parse('mailto:hi@seoul.fm'), isNull);
    });

    test('without the station list, a station page opens on the site', () {
      final url = Uri.parse('https://seoul.fm/pop/');
      expect(parseDeepLink(url), WebLink(url));
    });
  });

  group('seoulfm scheme', () {
    test('first segment in the host', () {
      expect(parse('seoulfm://song/12345'), const SongLink('12345'));
      expect(parse('seoulfm://song/12345/'), const SongLink('12345'));
      expect(parse('seoulfm://song/bts/spring-day'), const SongSlugLink('bts', 'spring-day'));
      expect(parse('seoulfm://artist/iu'), const ArtistLink('iu'));
      expect(parse('seoulfm://pop'), const StationLink('seoulfm'));
      expect(parse('seoulfm://wall'), const WallLink());
      expect(parse('seoulfm://support/'), const SupportLink());
      expect(parse('seoulfm://kr/artist/iu/?utm_source=app'), const ArtistLink('iu'));
    });

    test('path-only and host forms', () {
      expect(parse('seoulfm:///song/12345/'), const SongLink('12345'));
      expect(parse('seoulfm://seoul.fm/hifi/'), const StationLink('hifi'));
      expect(parse('seoulfm://www.seoul.fm/kr/wall'), const WallLink());
    });

    test('home', () {
      expect(parse('seoulfm://'), const HomeLink());
      expect(parse('seoulfm:///'), const HomeLink());
      expect(parse('seoulfm://kr'), const HomeLink());
    });

    test('anything else opens the same page on the site', () {
      expect(parse('seoulfm://faq'), WebLink(Uri.parse('https://seoul.fm/faq/')));
      expect(parse('seoulfm://kr/charts?period=week'), WebLink(Uri.parse('https://seoul.fm/kr/charts/?period=week')));
    });
  });

  test('webUrl keeps site links and maps the scheme onto the site', () {
    final site = Uri.parse('https://www.seoul.fm/kr/song/1/?utm_source=app');
    expect(webUrl(site), site);
    expect(webUrl(Uri.parse('seoulfm://song/bts/spring-day')), Uri.parse('https://seoul.fm/song/bts/spring-day/'));
  });

  group('queue', () {
    test('links wait for ready, then flow straight through', () {
      final links = DeepLinks.instance;
      final opened = <Uri>[];
      // Nothing listens to the plugin in tests; deliver as the stream would.
      final a = Uri.parse('https://seoul.fm/wall/');
      final b = Uri.parse('https://seoul.fm/support/');
      links.receiveForTest(a);
      expect(opened, isEmpty);
      links.ready(opened.add);
      expect(opened, [a]);
      links.receiveForTest(b);
      expect(opened, [a, b]);
    });
  });
}
