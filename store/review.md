# Submitting to the stores

Everything the store forms ask for besides the listing text (`store/ios`, `store/android`) and
the privacy answers (`store/privacy.md`).

## Both stores

| Field | Answer |
|---|---|
| Category | Music (Apple secondary: Entertainment) |
| Price | Free, with in-app purchases |
| Support URL | https://seoul.fm/contact/ |
| Marketing URL | https://seoul.fm |
| Privacy policy URL | https://seoul.fm/privacy/ |
| Copyright (Apple) | © 2026 SeoulFM |
| Sign-in needed to review? | No. There are no accounts. |
| Ads | None |

## In-app purchases

**Held back from 3.0** (decided 2026-10-02): the app ships with support switched off
(`SEOULFM_SUPPORT`, default off: no Support card, page or button), and the store descriptions
dropped their closing paragraph about tips (restore it from git history). The four products below
already exist in App Store Connect, priced: small $2.99, medium $10.99, large $20.99, monthly
$5.99, in the app's 174 territories (no mainland China). To launch them: build with
`--dart-define=SEOULFM_SUPPORT=true`, restore the description paragraph, add each product's
review screenshot, and submit them with that version once the Paid Apps Agreement is active.


Create these before submitting. The app reads the names and prices from the store, so set them
there, in each language.

| Product ID | Type | Reference name |
|---|---|---|
| `seoulfm.tip.small` | Consumable | Small tip |
| `seoulfm.tip.medium` | Consumable | Medium tip |
| `seoulfm.tip.large` | Consumable | Large tip |
| `seoulfm.supporter.monthly` | Auto-renewable subscription (group "Supporter") | Monthly supporter |

Apple also needs a screenshot of each purchase in the app (the Support screen) and a
review note for each product: "A tip to support the free radio station. Nothing is unlocked."

**Risk to know about:** the subscription unlocks nothing; the Support page says so on purpose.
Apple allows tips as consumables (guideline 3.1.1), but has rejected subscriptions with no
ongoing value (3.1.2a). If Apple rejects the subscription, the fastest fixes are:
1. Ship the tips only, and add the subscription in an update, or
2. Give supporters something small and ongoing: a supporter badge on their dedications, or
   alternate app icons.

Submit the subscription with the first version anyway; a rejection of one in-app purchase
doesn't hold back the app if it is submitted separately.

## Apple: App Review information

**Notes for the reviewer** (paste as is):

> SeoulFM is a free, listener-supported K-pop radio station with twelve live stations. No sign-in
> is needed: open the app and tap play.
>
> Background audio: the app plays live radio, so it keeps playing with the screen locked
> (UIBackgroundModes audio), with lock-screen and Control Center controls.
>
> HIFI station: it streams lossless FLAC. Before it plays, the app shows a notice about data
> usage, which the listener accepts each time.
>
> Requests and dedications: listeners can request a song and add an optional display name and a
> short dedication, which are shown to everyone. Every dedication has a ⋯ menu to report it (it
> emails our team, and we review reports within 24 hours) and to hide all dedications from that
> name. Requests are protected by Cloudflare Turnstile.
>
> In-app purchases: three one-time tips and a monthly supporter subscription, all optional.
> They unlock nothing; every feature stays free. They're on More → Support.
>
> Contact for review questions: <name, phone, email>

**Contact information:** the account holder's name, phone and email.

**Age rating questionnaire (2025 form):**
- Profanity or crude humour: Infrequent/Mild (song lyrics; listener dedications).
- User-generated content: Yes (dedications), with reporting and hiding in the app.
- Messaging and chat: No.
- Unrestricted web access: No (the in-app browser opens only seoul.fm pages).
- Everything else (violence, sexual content, gambling, contests, medical, alcohol and drugs): None.

The form works out the rating; expect 13+.

**Export compliance:** already answered in the app (`ITSAppUsesNonExemptEncryption` = NO); the
app uses only HTTPS.

**Content rights:** "Yes, it has the rights" (licensed radio broadcasting).

## Google Play: App content

- **Content rating (IARC):** category "All other app types" (music streaming). Users interact
  or exchange content: Yes (public dedications). Shares location: No. Digital purchases: Yes.
- **Target audience:** 13 and over. Don't include under-13s: that would bring in the Families
  policy.
- **Ads:** No.
- **App access:** All functionality is available without special access.
- **News app:** No.
- **Foreground service:** declare the `mediaPlayback` type (live radio that keeps playing in
  the background). Play may ask for a short video: play a station, lock the phone, and show
  the notification controls.
- **Android Auto:** turn it on under Advanced settings → Form factors; it gets its own review.

## Upload checklist

1. `flutter analyze`, `flutter test`, and the walkthrough tests in `integration_test/` on a
   device.
2. Raise the build number in `pubspec.yaml` above the stores' latest.
3. Build with the commit:
   - Android: `flutter build appbundle --release --dart-define-from-file=dart-defines.json --dart-define=GIT_COMMIT=$(git rev-parse --short HEAD)`
   - iOS: `flutter build ipa --release` with the same defines, then upload with Xcode or
     Transporter.
4. `python3 store/check_store.py`, then paste the listing files into each store (or upload
   them with fastlane: the folders follow `deliver` and `supply`'s file names).
5. Screenshots: `tool/store_all.sh <device> <raw dir>`, then
   `swift tool/compose_store.swift <raw dir> <out dir> <tag> [WxH]` (1080x1920 for Play) and
   `swift tool/compose_store.swift --feature <out.png> <tag>` for Play's feature graphic.
6. Internal testing (Play) and TestFlight first; then a staged rollout on Play.
