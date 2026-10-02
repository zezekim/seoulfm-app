# Releasing

A tag `v<version>` builds both apps and uploads them for testing: Android to Play's **internal**
track, iOS to **TestFlight** (`.github/workflows/release.yml`). Everything after that (store
listings, review, production) is a fastlane lane you run by hand when the build looks right.

| Lane | What it does |
|---|---|
| `fastlane ios beta` | `flutter build ios --config-only --release` with the defines and `GIT_COMMIT`, archives and signs with Xcode (automatic signing through the API key), uploads to TestFlight. |
| `fastlane ios metadata` | Uploads `store/ios/<locale>/` (name, subtitle, keywords, promotional text, description, release notes) to the version in "Prepare for Submission", and the screenshots in `IOS_SCREENSHOTS_DIRS` when set. No binary, no submission. |
| `fastlane ios release` | Picks the TestFlight build of pubspec's version and build number, uploads the listing text, answers the export compliance / IDFA / content rights questions and submits for review. Release is **manual**: after approval, press "Release this version" in App Store Connect. |
| `fastlane android internal` | `flutter build appbundle --release` with the defines and `GIT_COMMIT`, uploads it to the internal track with the release notes from `store/android/<locale>/changelogs/<build>.txt`, and the R8 mapping. |
| `fastlane android metadata` | Uploads `store/android/<locale>/` (title, short and full description), and the phone screenshots and feature graphic in `ANDROID_SCREENSHOTS_DIR` when set. |
| `fastlane android promote` | Promotes pubspec's build from internal to production as a staged rollout (`rollout:0.1` = 10 %, the default). |
| `fastlane android rollout` | Raises production's rollout (`rollout:0.5`), or completes it (`rollout:1`). |

Run lanes from the repo root: `bundle exec fastlane <ios|android> <lane> [rollout:0.2]`.

## One-time setup

### Ruby and fastlane

Ruby 3.2 or newer (macOS: `brew install ruby`, then put `/opt/homebrew/opt/ruby/bin` first on
`PATH`). Then, from the repo root:

```bash
bundle config set --local path vendor/bundle   # optional: keep the gems in the repo (gitignored)
bundle install
bundle exec fastlane lanes                      # lists the lanes above
```

`Gemfile` and `Gemfile.lock` pin fastlane; `bundle update fastlane` moves it forward.

### App Store Connect API key (iOS)

1. App Store Connect → Users and Access → Integrations → App Store Connect API → Team Keys →
   **Generate API Key**, role **Admin**. Admin is needed because Xcode's automatic signing
   creates the cloud-managed distribution certificate and the provisioning profiles with this key;
   App Manager can upload and submit but not sign.
2. Download `AuthKey_<KEY_ID>.p8` (only possible once). Note the **Key ID** and the **Issuer ID**
   shown above the list.
3. `base64 -i AuthKey_<KEY_ID>.p8 | pbcopy` gives the value of `ASC_KEY_P8_BASE64`.
4. The **Team ID**: developer.apple.com → Membership details.
5. Signing needs, once, in Certificates, Identifiers & Profiles (README "Before release" step 4):
   the App IDs `com.seoulfm.seoulfm` and `com.seoulfm.seoulfm.NowPlayingWidget`, and the App Group
   `group.com.seoulfm.seoulfm` on both. The app also carries the App Attest entitlement
   (`docs/app-attestation.md`); automatic signing adds it to the profile, but if the archive fails on
   that entitlement, turn on **App Attest** for `com.seoulfm.seoulfm` there.

**Alternative: fastlane match.** If you'd rather not give an Admin key to CI, store a
distribution certificate and App Store profiles (app and widget) in a private git repo or bucket
with `fastlane match appstore`, add `match(type: "appstore", readonly: true, api_key: asc_api_key)`
before `build_app` in the `beta` lane, switch `export_options` to `signingStyle: "manual"` with a
`provisioningProfiles` map, and give the workflow `MATCH_PASSWORD` and the repo's credentials. An
App Manager key is then enough.

### Google Play service account (Android)

1. Google Cloud console, in a project you own (it can be the one linked for Play Integrity):
   enable the **Google Play Android Developer API**, create a service account, and create a JSON key
   for it.
2. Play Console → Users and permissions → **Invite new users** → the service account's email.
   App permissions for SeoulFM: *View app information*, *Release to production, exclude devices,
   and use Play App Signing*, *Release apps to testing tracks*, *Manage store presence*.
3. The JSON key's contents are `PLAY_SERVICE_ACCOUNT_JSON`. It can take a day before a new
   service account works.
4. If the listing has never had a published release, uploads must be drafts: set
   `PLAY_RELEASE_STATUS=draft` for the first `android internal`, and roll it out in the console.

### Android upload key

The release bundle is signed with the Play upload key (README "Before release" step 3). For CI:

```bash
base64 -i upload-keystore.jks | pbcopy    # ANDROID_KEYSTORE_BASE64
```

plus the store password, the key alias and the key password from `android/key.properties`. CI
writes `android/key.properties` and the keystore at run time and deletes them afterwards.

### Play Integrity cloud project number

Play Console → Test and release → App integrity → Play Integrity API → **Link a Cloud project**.
The project **number** (not its id) goes into the defines as
`PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER`. It has no default: without it, Android never attests.
Attestation itself stays off until the dashboard flag and the API say otherwise
(`docs/app-attestation.md`).

### Build defines

The build reads the gitignored `dart-defines.json` (see `dart-defines.example.json`): the API key,
the Sentry DSN, the Play Integrity project number. CI writes it from the `DART_DEFINES_JSON`
secret, which holds the whole file:

```json
{
  "SEOULFM_API_KEY": "sfm_...",
  "SENTRY_DSN": "https://...",
  "PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER": "123456789012"
}
```

### Crash reports (Sentry)

Release builds are obfuscated (`--obfuscate --split-debug-info=build/symbols`), so a crash report
can only be read with that build's symbols. Create a Sentry project (platform Flutter), put its DSN
in `DART_DEFINES_JSON` as `SENTRY_DSN`, and give the `release` environment:

- secret `SENTRY_AUTH_TOKEN`: an organization auth token with `project:releases` and `org:read`;
- variables `SENTRY_ORG` and `SENTRY_PROJECT`: the slugs.

Each release job then runs `dart run sentry_dart_plugin` after its build (the `sentry:` block in
`pubspec.yaml`), uploading the Dart symbols and the native debug files under the release name the
app reports, `seoulfm@<version>+<build>`, with the commit as `dist`. Without the token the step
says so and skips. Reports carry the playback trail (stalls, recoveries, station cut-overs) and
page changes as breadcrumbs; nothing personal is sent (`sendDefaultPii` is off).

### GitHub secrets

Repository → Settings → Environments → **release** (create it; add required reviewers if a
person should approve each upload, and a deployment tag rule `v*.*.*`). Secrets there:

| Secret | Value |
|---|---|
| `DART_DEFINES_JSON` | the whole `dart-defines.json` |
| `ANDROID_KEYSTORE_BASE64` | the upload keystore, base64 |
| `ANDROID_KEYSTORE_PASSWORD` | its store password |
| `ANDROID_KEY_ALIAS` | the key alias |
| `ANDROID_KEY_PASSWORD` | the key password |
| `PLAY_SERVICE_ACCOUNT_JSON` | the service account's JSON key |
| `APPLE_TEAM_ID` | the Apple Team ID: `296555UMRR` |
| `ASC_KEY_ID` | the App Store Connect API key id |
| `ASC_ISSUER_ID` | its issuer id |
| `ASC_KEY_P8_BASE64` | the `.p8` file, base64 |

### Environment variables for local runs

The lanes read the same names. Locally you can use files instead:

| Variable | Used by | What |
|---|---|---|
| `ASC_KEY_ID`, `ASC_ISSUER_ID` | ios lanes | as above |
| `ASC_KEY_P8_BASE64` or `ASC_KEY_PATH` | ios lanes | the key, base64, or the path to the `.p8` |
| `APPLE_TEAM_ID` | `ios beta` | |
| `PLAY_SERVICE_ACCOUNT_JSON` or `PLAY_SERVICE_ACCOUNT_JSON_PATH` | android lanes | the JSON, or its path |
| `DART_DEFINES_FILE` | build lanes | defaults to `dart-defines.json` |
| `GIT_COMMIT` | build lanes | defaults to `git rev-parse --short HEAD` |
| `IOS_SCREENSHOTS_DIRS` | `ios metadata` | comma-separated folders: the iPhone set, the iPad set |
| `ANDROID_SCREENSHOTS_DIR` | `android metadata` | one folder: phone screenshots and feature graphics |
| `IOS_PHASED_RELEASE` | `ios release` | `true` for Apple's 7-day phased release after approval |
| `PLAY_RELEASE_STATUS` | `android internal` | `draft` before the first published release |
| `PLAY_TRACK` | `android metadata` | the track holding pubspec's build (default `internal`) |
| `PLAY_ROLLOUT` | `android promote`, `rollout` | the fraction, if not given as `rollout:` |

Relative paths are taken from the repo root.

## Screenshots

The images are made outside the repo (README "Store listings and screenshots") and the lanes
take `tool/compose_store.swift`'s output as it is: flat folders of `<tag>-<n>-<screen>.png`,
where `<tag>` is the app language (`en`, `zh-Hant`, …). The lanes map tags to store locales with
`store/locales.json` and stage the layout each tool expects (deliver: `<locale>/*.png`, sized
to tell iPhone from iPad; supply: `<locale>/images/phoneScreenshots/` and
`<locale>/images/featureGraphic.png`), so nothing in `store/` moves.

```bash
# App Store: one folder per device
swift tool/compose_store.swift ~/shots/raw-iphone ~/shots/iphone <tag>      # 1320 x 2868
swift tool/compose_store.swift ~/shots/raw-ipad   ~/shots/ipad   <tag>      # 2064 x 2752
IOS_SCREENSHOTS_DIRS=~/shots/iphone,~/shots/ipad bundle exec fastlane ios metadata

# Google Play: screenshots and the feature graphic in one folder
swift tool/compose_store.swift ~/shots/raw-android ~/shots/play <tag> 1080x1920
swift tool/compose_store.swift --feature ~/shots/play/feature-<tag>.png <tag>
ANDROID_SCREENSHOTS_DIR=~/shots/play bundle exec fastlane android metadata
```

`ios metadata` replaces all screenshots of the languages it has images for. A language without
images keeps what the store has, and the lane says which ones it skipped.

## Release checklist

1. **Version.** Raise `version` in `pubspec.yaml`: the name (`3.0.1`) is what the stores show;
   the build number (`+301`) must be above both stores' latest build.
2. **Release notes.** `store/ios/<locale>/release_notes.txt`, and
   `store/android/<locale>/changelogs/<build>.txt` for the new build number (500 characters at most)
   in every language. `store/check_store.py` checks `changelogs/300.txt`; point it at the new file
   (`ANDROID` in the script) so the limits are checked.
3. **Checks.** `python3 store/check_store.py`, `flutter analyze`, `flutter test`, and the
   walkthrough tests in `integration_test/` on a device (README).
4. **Tag.** Commit, then `git tag v3.0.1 && git push origin v3.0.1`. The tag must match pubspec's
   version name, or the workflow stops.
5. **CI.** The Release workflow runs the checks, then uploads Android to the internal track and
   iOS to TestFlight (the build appears after Apple's processing, 10 to 30 minutes). The bundle and
   the ipa are also kept as workflow artifacts for 30 days.
6. **Test** the internal-track build and the TestFlight build on real phones.
7. **Listings**, when they changed: `bundle exec fastlane ios metadata` and
   `bundle exec fastlane android metadata` (with the screenshot folders if the images changed).
8. **iOS:** `bundle exec fastlane ios release`. After approval, release it by hand in App Store
   Connect (or set `IOS_PHASED_RELEASE=true` before submitting for a 7-day phased release).
9. **Android:** `bundle exec fastlane android promote` (10 %). Watch Sentry and Android vitals for a
   day or two, then `bundle exec fastlane android rollout rollout:0.5`, then `rollout:1`. To stop a
   bad rollout, use **Halt rollout** on the release in Play Console, fix, and ship a new build.

## Troubleshooting

- **iOS signing fails with "No Accounts" or "No profiles"**: the API key isn't Admin, or
  `APPLE_TEAM_ID` is wrong. Xcode needs `-allowProvisioningUpdates` with the key (the lane passes
  it to both the archive and the export).
- **iOS signing fails on an entitlement**: the App Group or App Attest isn't on the App ID (One-time
  setup, App Store Connect step 5).
- **"Only releases with status draft may be created on draft app"** (Play): the listing has no
  published release yet; use `PLAY_RELEASE_STATUS=draft`.
- **"Track 'internal' doesn't have any releases" or "Could not find release for version code"**:
  `android promote` and `android metadata` look for pubspec's build number on the internal track;
  run them on the commit that was tagged.
- **The workflow can't find `Gemfile.lock` gems**: run `bundle lock --add-platform x86_64-linux
  arm64-darwin` after updating gems, so both runners resolve.
