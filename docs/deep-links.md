# Deep links

Links to seoul.fm open the app on the matching screen: Universal Links on iOS, App Links on
Android, plus the custom scheme `seoulfm://` (any site path: `seoulfm://song/{id}`, `seoulfm://pop`).

## What opens where

The language prefix (`/kr/`, `/jp/`, … and `/en/`), `www.`, a trailing slash and the query
string (the share tracking `utm_*`) don't matter.

| Site address | In the app |
| --- | --- |
| `/song/{id}/` (UUID or legacy number), `/song/?id={id}` | the song's page |
| `/song/{artist-slug}/{title-slug}/` | the song's page, found with `/tracks/lookup` |
| `/artist/{key}/`, `/artist/?name={name}` | the artist's page |
| `/{station}/` (`/pop/`, `/hifi/`, `/new-releases/`, …; aliases `/seoulfm/`, `/2010/`) | tunes the station and opens the player |
| `/wall/` | the dedications wall |
| `/support/` | Support SeoulFM |
| `/` | just the app |
| anything else (only reachable through `seoulfm://`) | the page, in the in-app browser |

A song the API can't find opens its page on the site instead. Parsing is
`parseDeepLink` in `lib/platform/deep_links.dart` (tests: `test/deep_links_test.dart`); the
routing is `lib/ui/deep_link_routes.dart`. Links that arrive before the shell is up (the one
that launched the app, or any during the first-run welcome) wait and open after it.

The app claims only the paths above (Android intent filter, iOS `components` below): every
other page stays in the browser, and the in-app browser never bounces back into the app.
**When a station is added, add its slug to `AndroidManifest.xml` and to the
`apple-app-site-association` file**; until then its links open the site, which still works.

## Files the website must serve

Both on `https://seoul.fm` **and** `https://www.seoul.fm`, with status 200 and **no redirect**
(Apple and Google don't follow redirects for these; `www` must not 301 to the bare domain for
these two paths). If `www` can't serve them, drop `applinks:www.seoul.fm` from
`ios/Runner/Runner.entitlements` and `www.seoul.fm` from the manifest instead: on Android 11
and earlier one failing host fails verification for all of them.

### `/.well-known/apple-app-site-association`

No file extension, served as `Content-Type: application/json`.

`<TEAM_ID>` is the Apple Developer Team ID (10 characters, developer.apple.com → Membership).
**Replace it once the Apple developer account is active**; until then Universal Links can't
work (and the associated-domains entitlement in `Runner.entitlements` needs the paid team to
sign; `Dev.entitlements`, for free-team test builds, deliberately doesn't have it).

```json
{
  "applinks": {
    "details": [
      {
        "appIDs": [
          "<TEAM_ID>.com.seoulfm.seoulfm"
        ],
        "components": [
          { "/": "/song/*" },
          { "/": "/artist/*" },
          { "/": "/wall" },
          { "/": "/wall/" },
          { "/": "/support" },
          { "/": "/support/" },
          { "/": "/pop" },
          { "/": "/pop/" },
          { "/": "/hifi" },
          { "/": "/hifi/" },
          { "/": "/new-releases" },
          { "/": "/new-releases/" },
          { "/": "/marathon" },
          { "/": "/marathon/" },
          { "/": "/dance" },
          { "/": "/dance/" },
          { "/": "/2010s" },
          { "/": "/2010s/" },
          { "/": "/classics" },
          { "/": "/classics/" },
          { "/": "/indie" },
          { "/": "/indie/" },
          { "/": "/hiphop" },
          { "/": "/hiphop/" },
          { "/": "/rnb" },
          { "/": "/rnb/" },
          { "/": "/ballad" },
          { "/": "/ballad/" },
          { "/": "/ost" },
          { "/": "/ost/" },
          { "/": "/seoulfm" },
          { "/": "/seoulfm/" },
          { "/": "/2010" },
          { "/": "/2010/" },
          { "/": "/??/song/*" },
          { "/": "/??/artist/*" },
          { "/": "/??/wall" },
          { "/": "/??/wall/" },
          { "/": "/??/support" },
          { "/": "/??/support/" },
          { "/": "/??/pop" },
          { "/": "/??/pop/" },
          { "/": "/??/hifi" },
          { "/": "/??/hifi/" },
          { "/": "/??/new-releases" },
          { "/": "/??/new-releases/" },
          { "/": "/??/marathon" },
          { "/": "/??/marathon/" },
          { "/": "/??/dance" },
          { "/": "/??/dance/" },
          { "/": "/??/2010s" },
          { "/": "/??/2010s/" },
          { "/": "/??/classics" },
          { "/": "/??/classics/" },
          { "/": "/??/indie" },
          { "/": "/??/indie/" },
          { "/": "/??/hiphop" },
          { "/": "/??/hiphop/" },
          { "/": "/??/rnb" },
          { "/": "/??/rnb/" },
          { "/": "/??/ballad" },
          { "/": "/??/ballad/" },
          { "/": "/??/ost" },
          { "/": "/??/ost/" },
          { "/": "/??/seoulfm" },
          { "/": "/??/seoulfm/" },
          { "/": "/??/2010" },
          { "/": "/??/2010/" }
        ]
      }
    ]
  }
}
```

`*` matches anything (slashes too), `?` exactly one character, so `/??/` is any language
prefix. Apple's CDN caches this file: after a change, allow up to a day, or check
`https://app-site-association.cdn-apple.com/a/v1/seoul.fm`.

### `/.well-known/assetlinks.json`

Served as `Content-Type: application/json`.

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.seoulfm.seoulfm",
      "sha256_cert_fingerprints": [
        "<PLAY_APP_SIGNING_SHA256>",
        "91:25:2A:97:2D:DB:B9:37:03:4C:11:6E:AC:90:56:87:73:97:61:57:02:3C:B1:E6:C8:21:2D:59:5D:64:C3:7A"
      ]
    }
  }
]
```

`<PLAY_APP_SIGNING_SHA256>` is the **app signing key** certificate's SHA-256 from Play Console →
the app → Test and release → App integrity → App signing (installs from Play are signed with
it). The second entry is the upload key, so builds installed outside Play (sideloaded release
APKs) verify too. Play Console → Deep links shows whether verification passes.

### Serving them from the Next.js site

- `middleware.ts` matches every path without a file extension, so
  `/.well-known/apple-app-site-association` would be rewritten to `/en/.well-known/…` and 404.
  Add `\.well-known/` to the exclusions in its `matcher`.
- Either put both files in `public/.well-known/` and set the AASA content type with a
  `public/_headers` rule (Workers static assets read it):

  ```
  /.well-known/apple-app-site-association
    Content-Type: application/json
  ```

  or serve them from route handlers that return the JSON with that header.
- Check: `curl -sI https://seoul.fm/.well-known/apple-app-site-association` (and on `www`, and
  `assetlinks.json`) answers `200` and `content-type: application/json`, without a `location`.

## Testing

iOS (simulator; Universal Links need the AASA live and a build signed with the real team):

```sh
xcrun simctl openurl booted "https://seoul.fm/kr/song/bts/spring-day/"
xcrun simctl openurl booted "https://seoul.fm/pop/"
xcrun simctl openurl booted "seoulfm://artist/newjeans"
xcrun simctl openurl booted "seoulfm://wall"
```

On a device, Settings → Developer → Universal Links → Diagnostics checks a URL against the
installed app. A link pasted in Notes and long-pressed shows "Open in SeoulFM".

Android:

```sh
adb shell am start -a android.intent.action.VIEW -d "https://seoul.fm/song/12345/" com.seoulfm.seoulfm
adb shell am start -a android.intent.action.VIEW -d "https://www.seoul.fm/jp/hifi/" com.seoulfm.seoulfm
adb shell am start -a android.intent.action.VIEW -d "seoulfm://support"
# Verification state per host (needs assetlinks.json live):
adb shell pm get-app-links com.seoulfm.seoulfm
# Re-run verification after changing assetlinks.json:
adb shell pm verify-app-links --re-verify com.seoulfm.seoulfm
```

Without the package name, `am start` behaves like a tapped link: it opens the app only when
the host is verified (or the user enabled the link in the app's settings), else the browser.

## Prompt for the site team

> The SeoulFM apps now open seoul.fm links (songs, artists, stations, the wall, support). Please
> serve two files on both `seoul.fm` and `www.seoul.fm`, 200 with `Content-Type: application/json`
> and no redirect: `/.well-known/apple-app-site-association` (no extension) and
> `/.well-known/assetlinks.json`, with the exact content in the app repo's `docs/deep-links.md`.
> Exclude `.well-known/` from the `middleware.ts` matcher (otherwise the AASA path is rewritten
> to `/en/…` and 404s), and set the AASA content type (a `public/_headers` rule, or a route
> handler). Fill in `<TEAM_ID>` (Apple Team ID, once the developer account is active) and the
> Play App Signing SHA-256 (Play Console → App integrity). When a station is added, add its slug
> to the AASA `components` as well.
