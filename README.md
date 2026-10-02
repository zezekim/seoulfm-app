# SeoulFM app (iOS and Android)

SeoulFM is free 24/7 K-pop radio and a Korean music streaming platform: twelve live stations,
and a song library, growing every day, with lyrics that listeners search and request. A requested song
plays live for everyone.

This Flutter app replaces the earlier apps. It ships under the existing Play Store id
(`com.seoulfm.seoulfm`, also the iOS bundle id) so it installs as an update. It shares the mobile
site's (`seoulfm-site`) tokens and API contract, laid out like Spotify and Apple Music: Home
showcases the stations (featured cards, then genre tiles, each with what it plays now); the player
bar opens a full-screen player with lyrics, Up Next, requests and history. The tabs are Home,
Request (search the library to request), Charts and More (dedications, settings). On top of the site
it adds **Android Auto** (CarPlay later), lock-screen and Bluetooth controls, background play,
station skip from the steering wheel or headset, and a sleep timer.

## Run

```bash
cp dart-defines.example.json dart-defines.json   # then fill in the keys; it is gitignored
flutter pub get
flutter run --dart-define-from-file=dart-defines.json --dart-define=GIT_COMMIT=$(git rev-parse --short HEAD)
```

Each define can also be passed alone, e.g. `--dart-define=SEOULFM_API_KEY=…`. Without the key,
every REST call returns 401 and only the tuned station's live feed works.

| define | default | what |
|---|---|---|
| `SEOULFM_API_KEY` | none | A **publishable** v3 key for the app. Never a partner key. |
| `TURNSTILE_SITE_KEY` | the site's key | Turnstile for requests and votes (the API requires it). Leave it out: an empty value turns the captcha off and every request fails. |
| `SEOULFM_API_URL` | `https://api.seoul.fm/v3` | |
| `SEOULFM_SITE_URL` | `https://seoul.fm` | Artwork copies (`/api/art/`), artist photos, share links. |
| `SEOULFM_RUNTIME_CONFIG_URL` | dash-api runtime config | Operators' notices and listener delay. |
| `GIT_COMMIT` | none | The commit, shown after the version in More (`$(git rev-parse --short HEAD)`). The version and build number come from `pubspec.yaml`. |
| `SENTRY_DSN` | none (off) | Crash and error reports to Sentry. Nothing is sent without it. |
| `PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER` | none (off) | The Google Cloud project number linked in Play Console → App integrity. Android sends Play Integrity proofs with writes only with it (and the dashboard flag; `docs/app-attestation.md`). |

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
flutter build ios --config-only --release --dart-define-from-file=dart-defines.json \
  --dart-define=GIT_COMMIT=$(git rev-parse --short HEAD)
cd ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release \
  -destination 'id=<device udid>' -derivedDataPath ../build/device -allowProvisioningUpdates \
  DEVELOPMENT_TEAM=<team id> SFM_BUNDLE_ID=com.seoulfm.dev.<you> CODE_SIGN_ENTITLEMENTS=Runner/Dev.entitlements build
xcrun devicectl device install app --device <device udid> ../build/device/Build/Products/Release-iphoneos/Runner.app
```

Then trust the developer on the phone (Settings → General → VPN & Device Management). Free
builds expire after 7 days.

## Store listings and screenshots

`store/` holds everything the App Store and Google Play ask for, in every language:

- `store/ios/<locale>/` and `store/android/<locale>/`: name, subtitle, keywords, descriptions
  and release notes, in fastlane's `deliver` and `supply` layout. `store/locales.json` maps the
  app's languages to the stores' codes (the App Store has no Kazakh).
- `store/captions/<tag>.json`: the screenshot headlines and Play's feature graphic tagline.
- `store/privacy.md`: the App Privacy and Data safety answers, from what the code sends.
- `store/review.md`: categories, in-app purchases, review notes, age rating, the upload checklist.

`python3 store/check_store.py` checks every file against the stores' limits.

Screenshots: `tool/store_all.sh <simulator udid | adb serial> <raw dir> [tags]` drives the real
app (`integration_test/store_test.dart`) in each language and captures six screens with a clean
status bar; `swift tool/compose_store.swift <raw dir> <out dir> <tag> [WxH]` frames them with the
headline (macOS sets the text, so Arabic, Thai and CJK shape properly), and
`swift tool/compose_store.swift --feature <out.png> <tag>` draws Play's 1024 x 500 feature
graphic. Use the iPhone 18 Pro Max simulator (1320 x 2868) and the iPad Pro 13-inch
(2064 x 2752) for the App Store, and an Android emulator framed to `1080x1920` for Google Play
(which allows at most 2:1). The images are large, so they live outside the repo.

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

### Request notifications and the rating prompt

While the app is out of sight, the listener's own requests notify once when one is coming up
(with its ETA) and once when it is on air; tapping opens the player
(`lib/platform/request_notifications.dart`). The permission is asked once, right after the first
accepted request, never at launch. Android posts them on the "Your requests" channel with the
status-bar icon audio_service uses (`drawable/ic_stat_seoulfm`).

**Limitation:** these are local notifications fed by the request's live status stream, so they
only come while the app's process is alive: on iOS that means while it is playing in the
background; a suspended or closed app hears nothing. Real push needs the server; the brief is in
`docs/push-requests.md`.

The App Store / Play rating prompt (`lib/state/review_prompt.dart`, rules unit-tested) asks right
after the listener hears their own request with the app open, or on their third day with at least
10 minutes of listening. Never in the first 2 days, at most once per version, not within 10
minutes of an error, never over a sheet or the welcome. The OS may still show nothing; the app
never falls back to the store page.

### CarPlay

`ios/Runner/SceneDelegate.swift` adds a CarPlay scene: a list of stations, each with the cover
of what it is playing and the song as detail text, and the system Now Playing screen (fed by the
same metadata as the lock screen). Picking a station tunes and plays it through the shared
engine. Both scenes use one `FlutterEngine` started in `AppDelegate`: CarPlay can launch the app
with no phone screen, and two engines would mean two radios.

**Off in 3.0.** The code is in place but not registered, so nothing in the app mentions
CarPlay (More's "In the car" shows on Android only). To turn it on in an update: get the CarPlay
audio entitlement from Apple (developer.apple.com/carplay) and regenerate the profile; add
`com.apple.developer.carplay-audio` back to `Runner/Runner.entitlements`; add the
`CPTemplateApplicationSceneSessionRoleApplication` scene (`CarPlaySceneDelegate`) back to
`Info.plist`'s scene manifest, with `UIApplicationSupportsMultipleScenes` true; show "In the car"
on iOS again and put CarPlay back in `carBody`. Test in Xcode's CarPlay simulator (I/O →
External Displays → CarPlay).

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
3. **Signing.** Android: `android/key.properties` (not committed) points at the upload key.
   The old app's key is lost, so a new upload key was made; Play Console → Test and release →
   App integrity → App signing → "Request upload key reset", with its `upload_certificate.pem`.
   Keep the key and its passwords backed up outside this machine. iOS: the team that owns `com.seoulfm.seoulfm`. Raise `version` in `pubspec.yaml` above
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

Uploads and store listings can be automated with fastlane and the tag-triggered workflow
(`.github/workflows/release.yml`): see `docs/release.md`.

## Not in this version

Chromecast, the equalizer and visualizer, the marathon "Speed it up" boost (hidden on the site
too until the API ships it), server push for requests (`docs/push-requests.md`),
featured-artist heroes.
