# Golden tests

`test/goldens/screens_golden_test.dart` takes screen snapshots of the parts of the app that break first
when a translation runs long or the text direction flips:

| Subject | What is drawn |
| --- | --- |
| `tab_bar` | the glass tab bar (`GlassTabBar`) over covers |
| `player_bar` | the floating player bar (`MiniPlayer`) with a long title |
| `track_list` | `TrackRow`s: long titles, Hangul, no cover, one on air |
| `spatial_progress` | the full player's `PlayerProgress` with the 3D BS2B badge |
| `your_songs` | the Your songs page with six saved songs |
| `quality_sheet` | the streaming quality sheet |
| `request_sheet` | the request sheet's form, waiting for the captcha |

Each one runs in **en, ko, ar (right to left), th, ja and de** (long words), in the dark theme, on a
390×844 phone with a notch, at two text sizes:

* **1.0**: the layout must not overflow or throw, and the image must match `test/goldens/images/<subject>.<locale>.png`.
* **2.0**: the layout must not overflow or throw (no image).

Some cases also assert things an image would only hint at: tab labels aren't cut short at 1.0, and in
Arabic the tabs, the player bar and the progress times run right to left.

Any `RenderFlex overflowed`, assertion or other exception fails the test, on every platform.

## Platform: images are compared on macOS only

Text rasterizes differently on Linux (FreeType) and macOS (Core Text), so one set of images can't match
both. The goldens are rendered on **macOS**, where the app is developed:

* `flutter test` on a Mac runs everything, comparing the images.
* On Linux (the CI `check` job) the same tests still run and still fail on overflow, exceptions and
  wrong direction, but the image comparison is skipped (`test/goldens/flutter_test_config.dart`).
  `--update-goldens` refuses to write there, so Linux images never get committed by mistake.
* The CI `goldens` job runs `flutter test --tags golden` on `macos-15` and compares the images. When it
  fails, the expected/actual/diff images are uploaded as the `golden-failures` artifact.

A comparison passes when at most **0.5%** of the pixels differ. That absorbs anti-aliasing drift between
macOS versions and Apple chips; a real change doesn't fit in it (one point more on the tab labels
already changes 1.4–2% of the tab bar).

Images are drawn at **1x**: overflow, clipping and direction are decided in logical pixels, so they show
the same at any density, and 42 images take 1.7 MB instead of 5.5 MB at 3x.

## Updating the images

After an intended visual change, on a Mac:

```sh
flutter test --update-goldens test/goldens
```

Look at the changed PNGs (`git diff --stat test/goldens/images`, then open them) before committing.

If the CI goldens job disagrees with images made on your Mac (a newer macOS draws text slightly
differently), let CI draw them: run the **CI** workflow by hand (Actions → CI → Run workflow) with
**update goldens** ticked, download the `golden-images` artifact and copy it into `test/goldens/images/`.

## How the tests stay deterministic

* **Fonts.** The default test font draws every glyph as a box, so `flutter_test_config.dart` loads the
  app's fonts from the font manifest (Pretendard, Lucide, Material Icons) and three small Noto subsets
  from `test/fonts` (Arabic, Thai, and Japanese kana plus the kanji in `app_ja.arb`; SIL OFL, see
  `test/fonts/OFL.txt`; about 1 MB in all). They replace the phone font names in the theme's fallback
  list (`fontFallback` in `lib/theme.dart`): a family the test engine doesn't have resolves to its box
  font. When Japanese strings gain new kanji they show as boxes in the `ja` images: rebuild the subset
  with `python3 tool/subset_test_fonts.py <folder with the Noto fonts>` (the script says where to get them).
* **Covers.** `Artwork` and `CoverColors` load covers through `coverProvider`
  (`lib/ui/widgets/cover_image.dart`), which the tests point at gradient images drawn in memory. No network.
* **State.** The bars read fakes of `NowPlayingController` (a fixed song, 1:23 in), `ChannelController`
  (the registry's line-up, no polling), `CoverColors` (a fixed tint) and `RadioHandler` (playing, nothing
  loaded). `SavedSongs` and shared preferences are real, in memory.
* **API.** `api.client` is an `http` `MockClient`: the request sheet's availability check answers
  "requestable"; anything else is a 404.
* **Captcha.** The Turnstile web view can't run in a widget test; `Turnstile.standIn` draws a box of its
  size instead, so the request sheet is laid out as on a phone while it waits for the token.
* **Time.** The bars tick every second and the on-air bars loop, so nothing settles: each case pumps a
  fixed second before the snapshot.

## Adding a case

Add a `golden('subject', () => widget, ...)` call in `screens_golden_test.dart` (pass `capture:` to
snapshot only part of the screen, `playing:` / `saved:` for state, `check:` for extra assertions), then
run `flutter test --update-goldens test/goldens` on a Mac and commit the new images.
