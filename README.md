# SeoulFM app (iOS and Android)

SeoulFM is free 24/7 K-pop radio and a Korean music streaming platform: twelve live stations,
and a library of 58,000+ songs with lyrics that listeners search and request. A requested song
plays live for everyone.

This Flutter app replaces the earlier apps. It ships under the existing Play Store id
(`com.seoulfm.seoulfm`, also the iOS bundle id) so it installs as an update. It shares the mobile
site's (`seoulfm-site`) tokens and API contract, laid out like Spotify and Apple Music: Home
showcases the stations (featured cards, then genre tiles, each with what it plays now); the player
bar opens a full-screen player with lyrics, Up Next, requests and history. The tabs are Home,
Request (search the library to request), Charts and More (dedications, settings). On top of the site
it adds **Apple CarPlay**, **Android Auto**, lock-screen and Bluetooth controls, background play,
station skip from the steering wheel or headset, and a sleep timer.

## Run

```bash
cp dart-defines.example.json dart-defines.json   # then fill in the keys; it is gitignored
flutter pub get
flutter run --dart-define-from-file=dart-defines.json
```

Each define can also be passed alone, e.g. `--dart-define=SEOULFM_API_KEY=…`. Without the key,
every REST call returns 401 and only the tuned station's live feed works.

| define | default | what |
|---|---|---|
| `SEOULFM_API_KEY` | none | A **publishable** v3 key for the app. Never a partner key. |
| `TURNSTILE_SITE_KEY` | none (captcha off) | Turnstile for requests and votes. The API requires it in production. |
| `SEOULFM_API_URL` | `https://api.seoul.fm/v3` | |
| `SEOULFM_SITE_URL` | `https://seoul.fm` | Artwork copies (`/api/art/`), artist photos, share links. |
| `SEOULFM_RUNTIME_CONFIG_URL` | dash-api runtime config | Operators' notices and listener delay. |
| `SEOULFM_APP_VERSION` | `3.0.0` | Sent with heartbeats. |
| `SENTRY_DSN` | none (off) | Crash and error reports to Sentry. Nothing is sent without it. |

`flutter analyze` and `flutter test` must pass. `flutter gen-l10n` runs on `pub get`. CI (`.github/workflows/ci.yml`)
runs both on every push, then builds the Android and iOS apps.

The walkthrough tests in `integration_test/` drive the real app against the live API and save
screenshots. Run them on a device or emulator before a release:

```bash
SHOTS_DIR=/tmp/shots flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/screens_test.dart -d <device> --dart-define-from-file=dart-defines.json
```

`screens` walks every tab and the player, `welcome` the first run, `lyrics` lyrics and sharing,
`support` the support page, `look` both themes, `stream` startup time and stalls.

### On your own iPhone (free Apple ID)

A personal team can't use the real bundle id, CarPlay or the App Group, so build with a
personal id and no entitlements (the widget then shows placeholder data):

```bash
flutter build ios --config-only --release --dart-define-from-file=dart-defines.json
cd ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release \
  -destination 'id=<device udid>' -derivedDataPath ../build/device -allowProvisioningUpdates \
  DEVELOPMENT_TEAM=<team id> SFM_BUNDLE_ID=com.seoulfm.dev.<you> CODE_SIGN_ENTITLEMENTS=Runner/Dev.entitlements build
xcrun devicectl device install app --device <device udid> ../build/device/Build/Products/Release-iphoneos/Runner.app
```

Then trust the developer on the phone (Settings → General → VPN & Device Management). Free
builds expire after 7 days.

## Languages

The app speaks the site's 20 languages: English, Korean, Spanish (Latin America and Spain),
Brazilian Portuguese, French, German, Italian, Polish, Turkish, Russian, Kazakh, Arabic
(right to left), Indonesian, Malay, Thai, Vietnamese, Japanese, and Simplified and Traditional
Chinese. It follows the device, or the choice in More → Language (and Android 13+'s per-app
language). Translations reuse the site's wording; station taglines come straight from the
site (`python3 tool/import_station_taglines.py ../seoulfm-site`). To change a string, edit
`lib/l10n/app_en.arb` and the same key in every other `app_*.arb`; `flutter gen-l10n` runs on
`pub get`. Check a language on a device with
`integration_test/languages_test.dart --dart-define=LOCALE=<tag>`.

## How it is built

```
lib/
  config.dart               build-time settings (dart-define)
  theme.dart                the site's tokens (globals.css): surfaces, type, motion
  api/                      v3 client (api.dart), models, SSE reader
  data/channels.dart        the station registry (mirror of lib/channels.ts)
  audio/radio_handler.dart  the radio: just_audio + audio_service
  state/                    the site's contexts as ChangeNotifiers
  platform/carplay_bridge.dart
  ui/                       shell, screens, widgets
  l10n/                     the site's 20 languages (ARB); station taglines in data/
ios/Runner/SceneDelegate.swift   phone scene, CarPlay scene, the bridge
```

- **One radio.** `RadioHandler` (an `audio_service` handler) owns the only player. It lives in
  the audio service, not a screen, so nothing in the UI can stop the music. Lock screen,
  notification, Bluetooth, CarPlay's Now Playing and Android Auto all drive it.
- **Streams.** `/v3/streams/{stream}/manifest.m3u8`, with the Worker manifest as Pop!'s fallback.
  Segment tokens expire: recovery always reloads the manifest, never a segment. A playlist
  stale for more than 15 s is reloaded on play, so the listener lands near live. Volume ramps on
  play, pause and channel changes.
- **Lossless (HIFI).** The API's data notice is shown on every tune-in and never stored. Accepting
  plays the FLAC media playlist (`?bitrate=lossless&accept_data_usage=true`). If it fails, the app
  falls back to AAC with a "Retry FLAC" warning. The car always gets AAC.
- **Heard, not station time.** `/v3/events` is station time. `NowPlayingController` keeps the
  bodies on a timeline by `stream_started_at_epoch_ms` and shows the one covering
  `now − delay`. The delay is the dashboard's `lyrics.delay_ms` (per station), and at least 12 s
  while playing, because native players start at `EXT-X-START` and can't report their program
  date. Lyrics and progress use `positionMs()`.
- **Requests, votes, ratings** follow the site's rules: session id per launch, listener id kept on
  the device, idempotency keys, Turnstile in a small web view with seoul.fm as its base URL,
  thumbs only after 25 s of listening, and the API's `reason` shown as it is.
- **Fail open.** If the runtime config can't be fetched, the app keeps the last good copy, or
  the defaults.

### CarPlay

`ios/Runner/SceneDelegate.swift` adds a CarPlay scene: a list of stations, each with the cover
of what it is playing and the song as detail text, and the system Now Playing screen (fed by the
same metadata as the lock screen). Picking a station tunes and plays it through the shared
engine. Both scenes use one `FlutterEngine` started in `AppDelegate`: CarPlay can launch the app
with no phone screen, and two engines would mean two radios.

**Before it shows in a car:** request the CarPlay audio entitlement from Apple
(developer.apple.com/carplay), then regenerate the provisioning profile.
`Runner/Runner.entitlements` already declares `com.apple.developer.carplay-audio`. Signing fails
until the profile includes it. Test in Xcode's CarPlay simulator (I/O → External Displays → CarPlay).

### Android Auto

`RadioHandler.getChildren` serves a "Stations" folder as a grid of covers. Voice search
("play SeoulFM Ballad") matches station names, and the skip buttons change station. The manifest
declares the media app (`res/xml/automotive_app_desc.xml`) and the playback service. Test with
the Desktop Head Unit. Play Console review checks Auto apps for driver distraction, which is fine
here: the car shows only system templates.

## Before release

1. **An API key for the app.** The site's publishable key is locked to seoul.fm's origins for
   writes, and a native app sends no Origin. See section 17 of `docs/api-requests.md` in
   `seoulfm-site`.
2. **Turnstile.** Check that the site key accepts tokens from the in-app web view (its hostname is
   seoul.fm through the base URL). If the API should verify app writes another way, that is in
   the same section.
3. **Signing.** Android: `android/key.properties` (not committed) with the existing Play upload
   key. iOS: the team that owns `com.seoulfm.seoulfm`. Raise `version` in `pubspec.yaml` above
   the current store build numbers (it is `3.0.0+300`).
4. **Widgets and Live Activity (iOS).** Register the App Group `group.com.seoulfm.seoulfm` for the
   team, and create an App ID and profile for the extension `com.seoulfm.seoulfm.NowPlayingWidget`;
   both the app's and the extension's profiles need the group. Signing fails until they do.
5. **Support (in-app purchase).** Create these products in App Store Connect and the Play
   Console (prices are yours to set; the app shows the store's, in the listener's currency):
   consumable tips `seoulfm.tip.small`, `seoulfm.tip.medium`, `seoulfm.tip.large`, and the
   auto-renewing subscription `seoulfm.supporter.monthly`. Until they exist, Support says it
   opens soon. Apple doesn't allow linking to Ko-fi from the app (that is for registered
   non-profits), so the app sells support only through the stores.
6. **Icons.** Generated from the site's wordmark (`dart run flutter_launcher_icons`). The iOS
   1024 px icon is upscaled from the site's 512 px file: replace `assets/icon/app-icon-1024.png`
   with a real 1024 px master and regenerate.

## Not in this version

Chromecast, the equalizer and visualizer, the marathon "Speed it up" boost (hidden on the site
too until the API ships it), push notifications, featured-artist heroes.
