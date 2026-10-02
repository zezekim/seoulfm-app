# App attestation for writes (spec for the API)

Status: the app side is built and **off** (`lib/platform/attestation.dart`, behind the runtime
config flag `attestation.enabled`). Nothing changes for listeners until the API implements this
document and the flag is turned on.

## Why

Song requests, Marathon votes and Marathon nominations need a Cloudflare Turnstile token today.
In the app that means a web view that loads Cloudflare's script, sometimes shows a challenge, and
sometimes fails (offline, blocked script, slow phone). Apple App Attest and Google Play Integrity
let the app prove that a write comes from **the genuine SeoulFM app on a genuine device**, without
asking the listener anything. Once the API verifies those proofs, it can waive the captcha for
attested clients.

The captcha stays the fallback forever: simulators, rooted or uncertified phones, old iOS
versions, sideloaded builds and any failure along the way get the captcha exactly as today.

## What you build (summary)

| # | What | Where |
|---|---|---|
| 1 | `GET /v3/attest/policy` | new |
| 2 | `GET /v3/attest/challenge` | new |
| 3 | `POST /v3/attest/ios/keys` (App Attest key registration) | new |
| 4 | Verify the proof headers on `POST /v3/requests`, `POST /v3/marathon/nominations`, `POST /v3/marathon/nominations/{id}/votes` | existing writes |
| 5 | Error code `captcha_required` (see "Errors") | existing writes |
| 6 | `attestation.enabled` in the dashboard runtime config (`/public/runtime-config`) | dash-api |
| 7 | Verdict logging and metrics for shadow mode | logging |

All new endpoints take the usual `X-API-Key` (the app's publishable key) and are not
station-scoped (no `?station=`).

## Identifiers you need

- **iOS App ID:** `296555UMRR.com.seoulfm.seoulfm` (the Team ID of the account that owns the app;
  ask the app owner). The app's entitlement is `com.apple.developer.devicecheck.appattest-environment
  = production`, so keys come from the **production** environment in every build signed with the
  paid team, including TestFlight and debug builds on a developer's phone.
- **Android package:** `com.seoulfm.seoulfm`.
- **Play app signing certificate SHA-256:** Play Console → Test and release → App integrity →
  App signing → "App signing key certificate" (not the upload key).
- **Google Cloud project** linked in Play Console → App integrity → Play Integrity API. Its
  project **number** is built into the app (`PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER`), and a service
  account in that project with the Play Integrity API enabled decodes tokens on the server.

## Endpoints

### 1. `GET /v3/attest/policy`

What the API currently does with proofs. The app caches it for 10 minutes.

```json
{
  "mode": "shadow",
  "captcha_waived": ["ios"],
  "challenge_ttl_seconds": 120
}
```

- `mode`: `off` (ignore proof headers), `shadow` (verify and log, captcha still required) or
  `enforce` (a verified proof stands in for the captcha on the platforms listed).
- `captcha_waived`: platforms (`ios`, `android`) whose attested writes don't need the captcha.
  Only meaningful with `enforce`; the app waives the captcha only when **both** say so.
- Unknown or missing fields mean "off". Send `Cache-Control: public, max-age=300`.

### 2. `GET /v3/attest/challenge`

A single-use nonce. The app fetches one per write (and one per key registration).

```json
{ "nonce": "Jd8qHq3o6c2n7c0Yt1m2VbqkzK8T0m3fKp4oQ5uYwZs", "expires_in": 120 }
```

- 32 bytes from a CSPRNG, base64url without padding (43 characters).
- Store it (Redis/KV) with a 120 s TTL, together with the API key id that asked for it.
- **Single use:** consume it atomically (`GETDEL` or equivalent) when a write or a key
  registration presents it. A nonce that is unknown, expired, already used, or issued to another
  API key fails the proof.
- `Cache-Control: no-store`.

### 3. `POST /v3/attest/ios/keys`

First use on iOS: the app generates an App Attest key, attests it over a fresh nonce, and
registers it here. After that it only sends assertions.

```json
{ "key_id": "<base64 key identifier>", "attestation": "<base64 CBOR attestation object>", "challenge": "<nonce>" }
```

Answer `201 {"key_id": "..."}` when the key is stored; `200` with the same body if that key is
already registered with the same public key. Errors: `400 attestation_invalid` (with
`detail.reason`), `409 nonce_invalid`.

Verify the attestation as in Apple's "Validating apps that connect to your server"
(developer.apple.com/documentation/devicecheck/validating-apps-that-connect-to-your-server):

1. Consume `challenge` as a nonce (see 2).
2. CBOR-decode `attestation`: `fmt` must be `apple-appattest`; take `attStmt.x5c` and `authData`.
3. Verify the `x5c` chain (leaf `credCert`, intermediate) up to Apple's App Attest root CA
   (`Apple_App_Attestation_Root_CA.pem`).
4. `clientDataHash = SHA256(utf8(challenge))`. Compute `nonce = SHA256(authData || clientDataHash)`.
5. The `credCert` extension `1.2.840.113635.100.8.2` must contain `nonce`.
6. `SHA256(credCert public key, uncompressed point)` must equal the decoded `key_id`.
7. `authData.rpIdHash == SHA256("296555UMRR.com.seoulfm.seoulfm")`.
8. `authData.signCount == 0`.
9. `authData.aaguid == "appattest" + 7 zero bytes` (production). Reject `appattestdevelop`.
10. `authData.credentialId == key_id`.

Store per key: `key_id`, the public key, `sign_count = 0`, the receipt (for optional fraud-metric
checks with Apple later), `created_at`, `last_used_at`, `revoked`. Keep keys at least a year.

### 4. Proof headers on writes

A write that carries a proof has these headers:

| Header | iOS | Android |
|---|---|---|
| `X-SFM-Attestation` | `ios` | `android` |
| `X-SFM-Attest-Nonce` | a nonce from `/attest/challenge` | same |
| `X-SFM-Attest-Key-Id` | the registered `key_id` | (absent) |
| `X-SFM-Attest-Assertion` | base64 CBOR assertion | (absent) |
| `X-SFM-Attest-Token` | (absent) | the Play Integrity token |

The proof signs this **client data** string (UTF-8, `\n` = a single line feed, no trailing
newline):

```
sfm-attest-v1\n<METHOD>\n<path>\n<nonce>\n<bodyHash>
```

- `<METHOD>`: `POST`.
- `<path>`: the request path as sent, without the query string, e.g. `/v3/requests` or
  `/v3/marathon/nominations/n_123/votes` (percent-encoding as on the wire).
- `<nonce>`: the `X-SFM-Attest-Nonce` value.
- `<bodyHash>`: base64url without padding of `SHA256(raw request body bytes)`. Hash the bytes
  you received, before any JSON parsing.

Example: an empty body to `/v3/requests` with nonce `n1` gives

```
sfm-attest-v1
POST
/v3/requests
n1
47DEQpj8HBSa-_TImW-5JCeuQeRkm5NMpJWZG3hSuFU
```

#### iOS: verify the assertion

1. Consume the nonce.
2. Look up `key_id`; unknown or revoked → the proof fails with reason `attestation_key_unknown`.
3. CBOR-decode the assertion: `{ signature, authenticatorData }`.
4. `clientDataHash = SHA256(utf8(clientData))`; `nonce = SHA256(authenticatorData || clientDataHash)`.
5. Verify `signature` (ECDSA P-256, DER) over `nonce` with SHA-256, using the stored public key
   (in Node: `crypto.verify('sha256', nonce, publicKey, signature)`).
6. `authenticatorData.rpIdHash == SHA256("296555UMRR.com.seoulfm.seoulfm")`.
7. `authenticatorData.signCount > stored sign_count`; then store the new count, **atomically**
   (compare-and-set), so two concurrent replays can't both pass.

#### Android: verify the integrity token (standard request)

The app uses Play Integrity **standard** requests: it warms up a token provider with the cloud
project number, then asks for a token with `requestHash = base64url-nopad(SHA256(utf8(clientData)))`
(43 characters). Standard tokens are encrypted by Google; decode them on the server with
`POST https://playintegrity.googleapis.com/v1/com.seoulfm.seoulfm:decodeIntegrityToken`
(service account of the linked project). Then check the payload:

1. Consume the nonce (the nonce is inside `clientData`, which the hash binds).
2. `requestDetails.requestPackageName == "com.seoulfm.seoulfm"`.
3. `requestDetails.requestHash == base64url-nopad(SHA256(utf8(clientData)))`, recomputed from the
   request you received.
4. `requestDetails.timestampMillis` within 5 minutes of now.
5. `appIntegrity.appRecognitionVerdict == "PLAY_RECOGNIZED"`,
   `appIntegrity.packageName == "com.seoulfm.seoulfm"` and
   `appIntegrity.certificateSha256Digest` contains the Play app signing certificate digest.
6. `deviceIntegrity.deviceRecognitionVerdict` contains `MEETS_DEVICE_INTEGRITY`. (Log
   `MEETS_BASIC_INTEGRITY`-only devices separately in shadow mode to decide whether to accept them.)
7. Don't require `accountDetails.appLicensingVerdict == LICENSED`: the app is free, and the
   verdict is often `UNEVALUATED`.

Quota: Play Integrity allows 10,000 token decodes per day by default. Writes are far fewer today,
but watch it and request more in the Play Console before enforcing if needed.

### 5. What a write does with a proof

| Policy mode | Proof | Captcha token | Result |
|---|---|---|---|
| `off` | ignored | as today | as today |
| `shadow` | verify, log the verdict | required as today | as today; never rejected because of the proof |
| `enforce`, platform in `captcha_waived` | valid | optional | accepted without the captcha (verify it if present) |
| `enforce`, platform in `captcha_waived` | invalid or absent | present | verify the captcha as today; log the proof verdict |
| `enforce`, platform in `captcha_waived` | invalid or absent | absent | `403 captcha_required` (with `detail.reason`) |
| `enforce`, platform not in `captcha_waived` | verify, log | required | as today |

Proof verification must never make a write fail that would succeed today: a write with a valid
captcha is accepted whatever its proof says.

Attested writes keep every existing rule: per-session and per-listener request limits,
idempotency keys, cooldowns, moderation.

### Errors

The app branches on the code; keep the envelope the API already uses
(`{"error": {"code", "message", "detail"}}`).

- `403 captcha_required`: the write needs a captcha (no valid proof). `detail.reason` is one of
  `attestation_missing`, `attestation_invalid`, `attestation_key_unknown`, `nonce_invalid`,
  `integrity_verdict` (the device or app didn't pass). The app then shows the captcha and resends;
  for `attestation_key_unknown` it also discards its key and registers a new one.
- Don't use a generic validation error (422) for a missing captcha when a proof was sent: the
  app only recognises `captcha_required`.

## Rate limits

Per client IP, on top of the existing write limits:

| Endpoint | Limit |
|---|---|
| `GET /attest/challenge` | 30 per minute, 300 per hour |
| `POST /attest/ios/keys` | 5 per hour, 20 per day |
| `GET /attest/policy` | 60 per hour (it is cacheable) |

Answer `429 rate_limited` with `detail.retry_after_seconds`, as elsewhere. Also cap outstanding
nonces per IP (e.g. 50) so the store can't be filled.

Per key (iOS `key_id`) and per Android device (no stable id; use the token's
`requestDetails` + IP), apply the same write limits as per session today. A key that keeps
failing assertions or replays nonces should be revoked (`revoked = true`), which sends that
install back to the captcha and a new key.

## Runtime config flag

Add to the dashboard's runtime config (`GET https://dash-api.seoul.fm/public/runtime-config`):

```json
{ "attestation": { "enabled": false } }
```

- `enabled: true` makes the app fetch the policy, register an App Attest key (iOS) or warm up the
  Play Integrity provider (Android), and send proof headers with requests, votes and nominations.
- Missing, or anything but `true`, means off. This is the app-side kill switch: turning it off
  stops proofs (and therefore any captcha waiver) within about 30 seconds of the app's next poll.
- The API's `policy.mode` is the server-side switch. Both must agree before the captcha is waived.

## Rollout

1. **Build, mode `off`.** Ship the endpoints and verification with `mode: off`. Test with a
   TestFlight build and an internal-track Android build, flag on for a staging config or by
   pointing a test build at a staging `SEOULFM_RUNTIME_CONFIG_URL`.
2. **Shadow.** `mode: shadow`, then turn `attestation.enabled` on in the dashboard. The captcha
   stays required. For each write with a proof, log: platform, verdict (`valid` or the reason),
   for Android the device and app verdicts, latency of the decode call, and whether the
   captcha also passed. Watch for a week or two:
   - share of writes with a valid proof, per platform and app version;
   - writes whose captcha passed but proof failed (false negatives: find out why first);
   - writes whose proof passed but captcha failed (expected to be rare; a sign of captcha flakiness);
   - Play Integrity quota use and decode latency; App Attest key registrations per day.
3. **Enforce on iOS.** `mode: enforce`, `captcha_waived: ["ios"]`. App Attest is the more
   deterministic of the two. Watch abuse metrics (requests per key, per IP) for a week.
4. **Enforce on Android.** Add `"android"` once the shadow numbers for Android look right.
5. **Rollback** at any step: set `mode` back to `shadow` or `off` (server), or
   `attestation.enabled: false` (app). Both are instant; the captcha path is untouched.

## Privacy and store answers

- The App Attest `key_id` is a random, per-install identifier that never leaves Apple's and our
  systems; it is not linked to a person. Play Integrity tokens carry device and app verdicts, not
  identity. Both are used only for fraud prevention and security.
- Before step 2 ships, update `store/privacy.md` (App Privacy: "Device ID" / "Other data", used for
  App Functionality and fraud prevention, not linked to the user, not tracking; Play Data safety:
  "App info and performance" or "Device or other IDs", purpose "Fraud prevention, security, and
  compliance") and the privacy policy page.

## App side, for reference

- `lib/platform/attestation.dart`: the protocol above (`Attestation`), `package:app_attest` for
  the platform calls (it hashes the challenge and client data with SHA-256 natively before
  `attestKey` / `generateAssertion`, and passes `requestHash` to Play Integrity as given).
- `lib/api/api.dart`: `post(..., attest: true)` adds the headers to requests, votes and
  nominations, and turns a skipped captcha without a proof into `captcha_required` before sending.
- `lib/state/runtime_config.dart`: the `attestation.enabled` flag.
- The proof has a 6 s budget (nonce plus the platform call); past it, or on any error, the write
  goes without a proof (with the captcha, unless the sheet had skipped it, in which case the
  captcha is shown and the listener sends again).
