# Privacy answers for the stores

What the app sends, from the code (not from memory), and how that maps onto Apple's App Privacy
labels and Google Play's Data safety form. The iOS privacy manifest
(`ios/Runner/PrivacyInfo.xcprivacy`) declares the same. If the app starts sending something new,
update all three.

## What leaves the device

| Data | Where it goes | Why | Where in the code |
|---|---|---|---|
| A random listener ID, made on first launch and kept on the device | SeoulFM API | Ratings (one per listener) and listener counts | `lib/state/session.dart` |
| A random session ID, new for each listening session | SeoulFM API | Groups heartbeats into sessions | `lib/state/session.dart` |
| Listening heartbeats: station, playing or paused, app on screen or not, app version, platform | SeoulFM API | Live listener counts; listening analytics | `RadioHandler._beat` |
| Playback quality: bitrate, network type (wifi, cellular), start-up time, rebuffer count | SeoulFM API | Stream quality monitoring | `RadioHandler._beat` |
| Thumbs up or down on a song | SeoulFM API | Song ratings | `lib/state/ratings_controller.dart` |
| A request: the song, and optionally a display name and a dedication message | SeoulFM API, then shown publicly in the app and on seoul.fm | Requests and dedications | `lib/ui/widgets/request_sheet.dart` |
| Bot checks for requests and votes (Cloudflare Turnstile, in a web view) | Cloudflare | Fraud and spam prevention | `lib/ui/widgets/turnstile.dart` |
| A report of a dedication (the dedication's details and the listener ID) | Email to the team, if the listener sends it | Moderation | `lib/ui/widgets/dedication_actions.dart` |
| Crash reports | Sentry, **only if `SENTRY_DSN` is set** (it isn't today) | Fixing crashes | `lib/main.dart` |

No account, no email address, no contacts, no location, no photos, no advertising ID, no
third-party analytics or advertising SDKs. Purchases (tips, the monthly supporter subscription)
are handled entirely by Apple and Google; the app doesn't send them anywhere.

**Confirm with the backend team before submitting:** does the API store IP addresses, or turn
them into a country or city for the dashboard? If it does, add **Coarse Location** (Apple) /
**Approximate location** (Google), purpose Analytics, not linked to identity.

## Apple: App Privacy (App Store Connect → App Privacy)

- **Do you or your third-party partners collect data from this app?** Yes.
- **Tracking:** No. Nothing is used for tracking, and the app never asks for it.

| Data type | Purposes | Linked to the user? | Used for tracking? |
|---|---|---|---|
| Identifiers → **Device ID** (the random listener ID) | Analytics, App Functionality | No | No |
| Usage Data → **Product Interaction** (heartbeats, ratings) | Analytics, App Functionality | No | No |
| Diagnostics → **Performance Data** (bitrate, start-up time, rebuffers) | Analytics | No | No |
| Diagnostics → **Other Diagnostic Data** (Turnstile's bot checks) | App Functionality | No | No |
| User Content → **Other User Content** (display name and dedication on a request) | App Functionality | No | No |

If Sentry is turned on, add Diagnostics → **Crash Data**, App Functionality, not linked.

"Not linked" is right because the IDs are random, made on the device, and never joined with
anything that identifies a person (there are no accounts).

## Google Play: Data safety (Play Console → App content → Data safety)

- **Does your app collect or share any of the required user data types?** Yes.
- **Is all of the user data encrypted in transit?** Yes (HTTPS only).
- **Do you provide a way for users to request that their data is deleted?** No account exists,
  and the data isn't tied to a person. Answer "No" and explain that the data is anonymous;
  listeners can clear it by clearing the app's storage.
- **Shared** with third parties: No (Cloudflare and Sentry act as service providers, which Google
  doesn't count as sharing).

| Category → type | Collected | Optional? | Purposes |
|---|---|---|---|
| App activity → **App interactions** | Yes | Required | Analytics, App functionality |
| App activity → **Other user-generated content** (dedications) | Yes | Optional | App functionality |
| App info and performance → **Diagnostics** | Yes | Required | Analytics, App functionality (fraud prevention) |
| App info and performance → **Crash logs** | Only with Sentry on | Required | App functionality |
| Device or other IDs → **Device or other IDs** | Yes | Required | Analytics, App functionality |

Mark none of them as processed ephemerally, except Turnstile's checks.

## Privacy policy

Both stores need a privacy policy URL: `https://seoul.fm/privacy/`. It should mention the
anonymous listener ID, heartbeats, dedications being public, Cloudflare Turnstile, and (if on)
Sentry.
