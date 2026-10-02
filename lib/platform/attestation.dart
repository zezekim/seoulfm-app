import 'dart:async';
import 'dart:convert';

import 'package:app_attest/app_attest.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/state/session.dart';

/// Device attestation for writes (requests, votes, nominations): Apple App Attest on iOS, Play
/// Integrity standard requests on Android. A proof says the write comes from the genuine app on a
/// genuine device, so the API can waive the captcha. The protocol is in docs/app-attestation.md.
///
/// Off unless the dashboard turns it on (`RuntimeConfig.attestation`), and it never blocks a
/// write: anything that fails sends the write without a proof, with the captcha as before.
class Attestation implements WriteAttestor {
  Attestation({
    required this.device,
    required this.server,
    required this.keys,
    bool Function()? enabled,
    this.cloudProjectNumber = Config.playIntegrityCloudProjectNumber,
    this.timeout = const Duration(seconds: 6),
    DateTime Function()? now,
  }) : enabled = enabled ?? (() => false),
       _now = now ?? DateTime.now;

  static final instance = Attestation(device: PluginAttestDevice(), server: ApiAttestServer(), keys: PrefsAttestKeys());

  final AttestDevice device;
  final AttestServer server;
  final AttestKeys keys;
  final int cloudProjectNumber;

  /// The whole proof (challenge, then the platform call) gets this long before the write goes
  /// without it: Play Integrity can take seconds on a cold device.
  final Duration timeout;

  /// The runtime config flag; set at launch.
  bool Function() enabled;
  final DateTime Function() _now;

  static const policyMaxAge = Duration(minutes: 10);
  // A failed key attestation calls Apple's servers again, so don't retry it on every write.
  static const _iosRetry = Duration(hours: 1);
  static const _androidRetry = Duration(minutes: 10);

  AttestPolicy _policy = const AttestPolicy();
  DateTime? _policyAt;
  bool _ready = false; // iOS: a key the API accepted; Android: a warmed-up token provider
  DateTime? _retryAt;
  bool _captchaForced = false;
  Future<void>? _warming;

  AttestPolicy get policy => _policy;

  /// 'ios' or 'android' where this build can attest; Android also needs the cloud project number.
  String? get platform => switch (device.platform) {
    'android' when cloudProjectNumber <= 0 => null,
    final p => p,
  };

  bool get active => enabled() && platform != null;

  /// A write may go without the captcha: the API waives it for attested clients on this platform,
  /// and this device is ready to attest. Read when a sheet opens; [warmUp] keeps it current.
  bool get captchaWaived => active && _ready && !_captchaForced && _policy.waives(platform!);

  /// The captcha is back until the app restarts: a proof couldn't be made, or the API refused it.
  void requireCaptcha() => _captchaForced = true;

  /// Fetches the policy and readies the device: an attested key on iOS, a token provider on
  /// Android. Cheap to call often; it never throws.
  Future<void> warmUp() {
    if (!active) return Future.value();
    return _warming ??= _warmUp().whenComplete(() => _warming = null);
  }

  Future<void> _warmUp() async {
    final now = _now();
    if (_policyAt == null || now.difference(_policyAt!) > policyMaxAge) {
      try {
        _policy = await server.policy();
        _policyAt = now;
      } catch (e) {
        _log('policy', e); // keep the last one; the default waives nothing
      }
    }
    if (_ready || (_retryAt != null && now.isBefore(_retryAt!))) return;
    final p = platform!;
    try {
      if (!await device.supported()) {
        _retryAt = now.add(const Duration(days: 365)); // a simulator, or an old device
        return;
      }
      if (p == 'ios') {
        if (keys.read() == null) {
          // First use: a new key, attested once over a server nonce; then assertions only.
          final keyId = await device.newKey();
          final challenge = await server.challenge();
          final attestation = await device.attestKey(keyId, challenge);
          await server.registerKey(keyId: keyId, attestation: attestation, challenge: challenge);
          await keys.write(keyId);
        }
      } else {
        await device.prepare(cloudProjectNumber);
      }
      _ready = true;
      _retryAt = null;
    } catch (e) {
      _log('warm-up', e);
      _retryAt = now.add(p == 'ios' ? _iosRetry : _androidRetry);
    }
  }

  @override
  Future<Map<String, String>> headersFor(String method, String path, List<int> body) async {
    if (!active) return const {};
    try {
      return await _proof(method, path, body).timeout(timeout);
    } catch (e) {
      _log('proof', e);
      return const {};
    }
  }

  Future<Map<String, String>> _proof(String method, String path, List<int> body) async {
    await warmUp();
    if (!_ready) return const {};
    final p = platform!;
    final nonce = await server.challenge();
    final data = clientData(method: method, path: path, nonce: nonce, body: body);
    if (p == 'ios') {
      final keyId = keys.read();
      if (keyId == null) return const {};
      return {
        AttestHeaders.platform: p,
        AttestHeaders.nonce: nonce,
        AttestHeaders.keyId: keyId,
        AttestHeaders.assertion: await _assert(keyId, data),
      };
    }
    return {
      AttestHeaders.platform: p,
      AttestHeaders.nonce: nonce,
      AttestHeaders.token: await device.integrityToken(requestHash(data)),
    };
  }

  // Assertions are made on the device, so a failure means the key is gone (a restore to another
  // phone): attest a new one next time.
  Future<String> _assert(String keyId, String data) async {
    try {
      return await device.assertion(keyId, data);
    } catch (_) {
      _ready = false;
      await keys.write(null);
      rethrow;
    }
  }

  @override
  void rejected(String code, [String? reason]) {
    // The API lost or revoked the key (or a backup brought the id to another phone): attest a new one.
    if (code == 'attestation_key_unknown' || reason == 'attestation_key_unknown') {
      _ready = false;
      _retryAt = null;
      keys.write(null);
    }
    if (code == 'captcha_required') requireCaptcha();
  }

  /// What a proof signs: the write itself (method, path, the exact body bytes) and a single-use
  /// server nonce. The API rebuilds this string from the request it received.
  static String clientData({
    required String method,
    required String path,
    required String nonce,
    required List<int> body,
  }) => 'sfm-attest-v1\n${method.toUpperCase()}\n$path\n$nonce\n${_b64(sha256.convert(body).bytes)}';

  /// Play Integrity's `requestHash` (at most 500 characters): SHA-256 of [clientData].
  static String requestHash(String clientData) => _b64(sha256.convert(utf8.encode(clientData)).bytes);

  static String _b64(List<int> bytes) => base64Url.encode(bytes).replaceAll('=', '');

  static void _log(String what, Object e) => debugPrint('attestation $what: $e');
}

/// The request headers carrying a proof.
abstract final class AttestHeaders {
  static const platform = 'X-SFM-Attestation';
  static const nonce = 'X-SFM-Attest-Nonce';
  static const keyId = 'X-SFM-Attest-Key-Id';
  static const assertion = 'X-SFM-Attest-Assertion';
  static const token = 'X-SFM-Attest-Token';
}

/// The API's attestation policy (`GET /attest/policy`). `shadow` verifies and logs proofs but
/// still wants the captcha; only `enforce` lets a verified proof stand in for it.
class AttestPolicy {
  const AttestPolicy({this.mode = 'off', this.captchaWaived = const {}});
  final String mode;
  final Set<String> captchaWaived;

  bool waives(String platform) => mode == 'enforce' && captchaWaived.contains(platform);

  static AttestPolicy parse(Object? body) {
    if (body is! Map) return const AttestPolicy();
    final waived = body['captcha_waived'];
    return AttestPolicy(
      mode: const {'off', 'shadow', 'enforce'}.contains(body['mode']) ? body['mode'] as String : 'off',
      captchaWaived: waived is List ? waived.whereType<String>().toSet() : const {},
    );
  }
}

/// The platform side: App Attest and Play Integrity.
abstract class AttestDevice {
  String? get platform;
  Future<bool> supported();
  Future<String> newKey();

  /// The attestation object (base64) for [keyId], over SHA-256 of [challenge].
  Future<String> attestKey(String keyId, String challenge);

  /// An assertion (base64) over SHA-256 of [clientData].
  Future<String> assertion(String keyId, String clientData);
  Future<void> prepare(int cloudProjectNumber);
  Future<String> integrityToken(String requestHash);
}

/// `package:app_attest`: it hashes the challenge and client data with SHA-256 natively, as
/// App Attest wants, and passes the request hash to Play Integrity as given.
class PluginAttestDevice implements AttestDevice {
  @override
  String? get platform => kIsWeb
      ? null
      : switch (defaultTargetPlatform) {
          TargetPlatform.iOS => 'ios',
          TargetPlatform.android => 'android',
          _ => null,
        };

  @override
  Future<bool> supported() => AppAttest.isSupported();
  @override
  Future<String> newKey() => AppAttest.generateKey();
  @override
  Future<String> attestKey(String keyId, String challenge) async =>
      (await AppAttest.attestKey(keyId: keyId, challenge: challenge)).attestationObject;
  @override
  Future<String> assertion(String keyId, String clientData) async =>
      (await AppAttest.generateAssertion(keyId: keyId, challenge: clientData)).assertionObject;
  @override
  Future<void> prepare(int cloudProjectNumber) =>
      AppAttest.preparePlayIntegrityTokenProvider(cloudProjectNumber: cloudProjectNumber);
  @override
  Future<String> integrityToken(String requestHash) =>
      AppAttest.requestStandardPlayIntegrityToken(requestHash: requestHash);
}

/// The API side (docs/app-attestation.md).
abstract class AttestServer {
  Future<AttestPolicy> policy();

  /// A single-use nonce.
  Future<String> challenge();
  Future<void> registerKey({required String keyId, required String attestation, required String challenge});
}

class ApiAttestServer implements AttestServer {
  @override
  Future<AttestPolicy> policy() async => AttestPolicy.parse(await api.get('/attest/policy'));

  @override
  Future<String> challenge() async {
    final nonce = (await api.get('/attest/challenge'))['nonce'];
    if (nonce is! String || nonce.isEmpty) throw const FormatException('no nonce');
    return nonce;
  }

  @override
  Future<void> registerKey({required String keyId, required String attestation, required String challenge}) =>
      api.post('/attest/ios/keys', {'key_id': keyId, 'attestation': attestation, 'challenge': challenge});
}

/// Where the iOS key id lives. The key itself stays in the Secure Enclave; a restore to another
/// device brings the id but not the key, and the API then answers `attestation_key_unknown`.
abstract class AttestKeys {
  String? read();
  Future<void> write(String? keyId);
}

class PrefsAttestKeys implements AttestKeys {
  static const _key = 'seoulfm-attest-key';
  @override
  String? read() => Session.prefs.getString(_key);
  @override
  Future<void> write(String? keyId) async =>
      keyId == null ? await Session.prefs.remove(_key) : await Session.prefs.setString(_key, keyId);
}
