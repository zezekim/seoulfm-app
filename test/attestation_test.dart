import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/platform/attestation.dart';
import 'package:seoulfm/state/runtime_config.dart';

class FakeDevice implements AttestDevice {
  FakeDevice(this.platform);
  @override
  final String? platform;
  bool isSupported = true;
  bool fail = false;
  Duration delay = Duration.zero;
  int keysMade = 0, prepared = 0;
  final attested = <String>[]; // challenges
  final asserted = <String>[]; // client data
  final hashes = <String>[];

  Future<T> _run<T>(T value) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (fail) throw Exception('device');
    return value;
  }

  @override
  Future<bool> supported() async => isSupported;
  @override
  Future<String> newKey() => _run('key-${++keysMade}');
  @override
  Future<String> attestKey(String keyId, String challenge) {
    attested.add(challenge);
    return _run('attestation-of-$keyId');
  }

  @override
  Future<String> assertion(String keyId, String clientData) {
    asserted.add(clientData);
    return _run('assertion-by-$keyId');
  }

  @override
  Future<void> prepare(int cloudProjectNumber) {
    prepared++;
    return _run(null);
  }

  @override
  Future<String> integrityToken(String requestHash) {
    hashes.add(requestHash);
    return _run('integrity-token');
  }
}

class FakeServer implements AttestServer {
  AttestPolicy current = const AttestPolicy(mode: 'enforce', captchaWaived: {'ios', 'android'});
  int nonces = 0, policies = 0;
  final registered = <String>[];
  bool down = false;

  @override
  Future<AttestPolicy> policy() async {
    policies++;
    if (down) throw Exception('offline');
    return current;
  }

  @override
  Future<String> challenge() async {
    if (down) throw Exception('offline');
    return 'nonce-${++nonces}';
  }

  @override
  Future<void> registerKey({required String keyId, required String attestation, required String challenge}) async {
    if (down) throw Exception('offline');
    registered.add('$keyId:$attestation:$challenge');
  }
}

class MemoryKeys implements AttestKeys {
  String? keyId;
  @override
  String? read() => keyId;
  @override
  Future<void> write(String? id) async => keyId = id;
}

void main() {
  final body = utf8.encode('{"track_id":"t1"}');
  late FakeDevice device;
  late FakeServer server;
  late MemoryKeys keys;
  var flag = true;
  var now = DateTime(2026, 10, 2);

  Attestation make(String platform, {int cloudProjectNumber = 123456789012}) {
    device = FakeDevice(platform);
    server = FakeServer();
    keys = MemoryKeys();
    flag = true;
    now = DateTime(2026, 10, 2);
    return Attestation(
      device: device,
      server: server,
      keys: keys,
      enabled: () => flag,
      cloudProjectNumber: cloudProjectNumber,
      timeout: const Duration(milliseconds: 200),
      now: () => now,
    );
  }

  group('client data', () {
    test('binds method, path, nonce and the body hash', () {
      final data = Attestation.clientData(method: 'post', path: '/v3/requests', nonce: 'n1', body: utf8.encode(''));
      // SHA-256 of nothing, base64url without padding.
      expect(data, 'sfm-attest-v1\nPOST\n/v3/requests\nn1\n47DEQpj8HBSa-_TImW-5JCeuQeRkm5NMpJWZG3hSuFU');
    });

    test('the request hash is the base64url SHA-256 of the client data', () {
      final expected = base64Url.encode(sha256.convert(utf8.encode('abc')).bytes).replaceAll('=', '');
      expect(Attestation.requestHash('abc'), expected);
      expect(Attestation.requestHash('abc').length, 43);
    });
  });

  group('iOS', () {
    test('attests a key once, then signs each write with an assertion over a fresh nonce', () async {
      final a = make('ios');
      final first = await a.headersFor('POST', '/v3/requests', body);
      expect(server.registered, ['key-1:attestation-of-key-1:nonce-1']);
      expect(device.attested, ['nonce-1']);
      expect(first, {
        AttestHeaders.platform: 'ios',
        AttestHeaders.nonce: 'nonce-2',
        AttestHeaders.keyId: 'key-1',
        AttestHeaders.assertion: 'assertion-by-key-1',
      });
      expect(
        device.asserted.single,
        Attestation.clientData(method: 'POST', path: '/v3/requests', nonce: 'nonce-2', body: body),
      );

      final second = await a.headersFor('POST', '/v3/marathon/nominations/n1/votes', body);
      expect(second[AttestHeaders.nonce], 'nonce-3');
      expect(device.keysMade, 1);
      expect(server.registered, hasLength(1));
    });

    test('a failed assertion drops the key, and the next warm-up attests a new one', () async {
      final a = make('ios');
      await a.warmUp();
      device.fail = true;
      expect(await a.headersFor('POST', '/v3/requests', body), isEmpty);
      expect(keys.keyId, isNull);
      device.fail = false;
      expect((await a.headersFor('POST', '/v3/requests', body))[AttestHeaders.keyId], 'key-2');
    });

    test('the API forgetting the key starts over', () async {
      final a = make('ios');
      await a.warmUp();
      a.rejected('captcha_required', 'attestation_key_unknown');
      expect(keys.keyId, isNull);
      expect(a.captchaWaived, isFalse);
      await a.warmUp();
      expect(keys.keyId, 'key-2');
    });

    test('a failed key attestation is not retried on every write', () async {
      final a = make('ios');
      server.down = true;
      expect(await a.headersFor('POST', '/v3/requests', body), isEmpty);
      server.down = false;
      expect(await a.headersFor('POST', '/v3/requests', body), isEmpty);
      expect(device.keysMade, 1);
      now = now.add(const Duration(hours: 2));
      expect(await a.headersFor('POST', '/v3/requests', body), isNotEmpty);
    });

    test('an unsupported device (a simulator) sends nothing', () async {
      final a = make('ios');
      device.isSupported = false;
      expect(await a.headersFor('POST', '/v3/requests', body), isEmpty);
      expect(device.keysMade, 0);
      expect(a.captchaWaived, isFalse);
    });
  });

  group('Android', () {
    test('prepares the provider once and sends a standard token bound to the request hash', () async {
      final a = make('android');
      final h = await a.headersFor('POST', '/v3/requests', body);
      final data = Attestation.clientData(method: 'POST', path: '/v3/requests', nonce: 'nonce-1', body: body);
      expect(h, {
        AttestHeaders.platform: 'android',
        AttestHeaders.nonce: 'nonce-1',
        AttestHeaders.token: 'integrity-token',
      });
      expect(device.hashes.single, Attestation.requestHash(data));
      await a.headersFor('POST', '/v3/requests', body);
      expect(device.prepared, 1);
    });

    test('without the cloud project number it stays off', () async {
      final a = make('android', cloudProjectNumber: 0);
      expect(a.platform, isNull);
      expect(await a.headersFor('POST', '/v3/requests', body), isEmpty);
      expect(device.prepared, 0);
      expect(server.policies, 0);
    });

    test('a slow token gives up within the timeout and sends nothing', () async {
      final a = make('android');
      await a.warmUp();
      device.delay = const Duration(seconds: 1);
      expect(await a.headersFor('POST', '/v3/requests', body), isEmpty);
    });
  });

  group('flag and policy', () {
    test('with the flag off nothing is asked of the device or the API', () async {
      final a = make('ios');
      flag = false;
      await a.warmUp();
      expect(await a.headersFor('POST', '/v3/requests', body), isEmpty);
      expect(a.captchaWaived, isFalse);
      expect(server.policies + server.nonces + device.keysMade, 0);
    });

    test('the captcha is waived only when enforced for this platform and the device is ready', () async {
      final a = make('ios');
      expect(a.captchaWaived, isFalse); // not warmed up yet
      await a.warmUp();
      expect(a.captchaWaived, isTrue);
      flag = false;
      expect(a.captchaWaived, isFalse);
    });

    test('shadow mode verifies but keeps the captcha', () async {
      final a = make('android');
      server.current = const AttestPolicy(mode: 'shadow', captchaWaived: {'ios', 'android'});
      await a.warmUp();
      expect(a.captchaWaived, isFalse);
      expect(await a.headersFor('POST', '/v3/requests', body), isNotEmpty);
    });

    test('a platform not listed keeps the captcha', () async {
      final a = make('android');
      server.current = const AttestPolicy(mode: 'enforce', captchaWaived: {'ios'});
      await a.warmUp();
      expect(a.captchaWaived, isFalse);
    });

    test('the policy is refreshed after it ages', () async {
      final a = make('ios');
      await a.warmUp();
      await a.warmUp();
      expect(server.policies, 1);
      now = now.add(const Duration(minutes: 11));
      await a.warmUp();
      expect(server.policies, 2);
    });

    test('a refused proof brings the captcha back', () async {
      final a = make('ios');
      await a.warmUp();
      a.rejected('captcha_required');
      expect(a.captchaWaived, isFalse);
    });

    test('policy parsing defaults to off', () {
      expect(AttestPolicy.parse(null).waives('ios'), isFalse);
      expect(
        AttestPolicy.parse({
          'mode': 'bogus',
          'captcha_waived': ['ios'],
        }).waives('ios'),
        isFalse,
      );
      final p = AttestPolicy.parse({
        'mode': 'enforce',
        'captcha_waived': ['ios', 3],
      });
      expect(p.waives('ios'), isTrue);
      expect(p.waives('android'), isFalse);
    });

    test('the runtime config flag defaults to off', () {
      expect(RuntimeConfig.parse({'maintenance': {}})!.attestation, isFalse);
      expect(
        RuntimeConfig.parse({
          'maintenance': {},
          'attestation': {'enabled': true},
        })!.attestation,
        isTrue,
      );
    });
  });

  group('Api.post', () {
    late http.Request sent;
    setUp(() {
      api.client = MockClient((r) async {
        sent = r;
        return http.Response('{"accepted":true}', 200);
      });
    });
    tearDown(() => api.attestor = null);

    test('a write carries the proof, signed over the bytes it sends', () async {
      final fake = _FakeAttestor({AttestHeaders.platform: 'ios', AttestHeaders.nonce: 'n'});
      api.attestor = fake;
      await api.submitRequest({'track_id': 't1', 'captcha_token': 'tok'});
      expect(sent.headers[AttestHeaders.platform], 'ios');
      expect(fake.path, sent.url.path);
      expect(fake.body, sent.bodyBytes);
    });

    test('reads stay unsigned', () async {
      final fake = _FakeAttestor({AttestHeaders.platform: 'ios'});
      api.attestor = fake;
      await api.post('/listeners/heartbeat', {'x': 1});
      expect(sent.headers.containsKey(AttestHeaders.platform), isFalse);
      expect(fake.path, isNull);
    });

    test('a skipped captcha without a proof asks for the captcha instead of sending', () async {
      if (!Config.captchaEnabled) return;
      final fake = _FakeAttestor(const {});
      api.attestor = fake;
      sent = http.Request('GET', Uri.parse('https://unused'));
      await expectLater(
        api.submitRequest({'track_id': 't1', 'captcha_token': null}),
        throwsA(isA<ApiError>().having((e) => e.code, 'code', 'captcha_required')),
      );
      expect(sent.method, 'GET'); // nothing went out
      expect(fake.rejections, ['captcha_required']);
    });

    test('a refusal of a proof is reported back', () async {
      api.client = MockClient(
        (r) async =>
            http.Response('{"error":{"code":"captcha_required","detail":{"reason":"attestation_key_unknown"}}}', 403),
      );
      final fake = _FakeAttestor({AttestHeaders.platform: 'ios'});
      api.attestor = fake;
      await expectLater(api.marathonVote('n1', {'captcha_token': 'tok'}), throwsA(isA<ApiError>()));
      expect(fake.rejections, ['attestation_key_unknown']);
    });
  });
}

class _FakeAttestor implements WriteAttestor {
  _FakeAttestor(this.headers);
  final Map<String, String> headers;
  String? path;
  List<int>? body;
  final rejections = <String>[];

  @override
  Future<Map<String, String>> headersFor(String method, String path, List<int> body) async {
    this.path = path;
    this.body = body;
    return headers;
  }

  @override
  void rejected(String code, [String? reason]) => rejections.add(reason ?? code);
}
