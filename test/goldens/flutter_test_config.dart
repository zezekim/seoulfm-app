import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seoulfm/theme.dart';

/// Runs before every test in test/goldens (see docs/golden-tests.md):
///
/// * loads the real fonts, so text is drawn with glyphs instead of the test font's boxes: the
///   app's own (Pretendard, Lucide, Material Icons, from the font manifest) and, for the scripts
///   Pretendard lacks, the small Noto subsets in test/fonts, which are added to the theme's
///   fallback list (instead of the phone font names).
/// * compares the images only on macOS, where they were rendered: text rasterizes differently
///   on Linux, so there the same tests still check layout (overflow, direction) but skip the
///   pixels. A small tolerance absorbs anti-aliasing drift between macOS versions.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadAppFonts();
  await _loadTestFonts();
  final base = goldenFileComparator;
  if (base is LocalFileComparator) {
    goldenFileComparator = Platform.isMacOS
        ? _TolerantComparator(base.basedir.resolve('golden_test.dart'))
        : _LayoutOnlyComparator();
  }
  await testMain();
}

/// The families the golden tests add after the app's fallbacks.
const testFallbackFamilies = ['SfmTestArabic', 'SfmTestThai', 'SfmTestJP'];

Future<void> _loadAppFonts() async {
  final manifest = json.decode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(entry['family'] as String);
    for (final font in (entry['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

Future<void> _loadTestFonts() async {
  const files = {
    'SfmTestArabic': 'test/fonts/NotoSansArabic-Subset.ttf',
    'SfmTestThai': 'test/fonts/NotoSansThai-Subset.ttf',
    'SfmTestJP': 'test/fonts/NotoSansJP-Subset.ttf',
  };
  for (final MapEntry(key: family, value: path) in files.entries) {
    final bytes = File(path).readAsBytesSync();
    await (FontLoader(family)..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }
  // In place of the phone's fallbacks: a family the test engine doesn't have resolves to its
  // box-drawing test font, which would claim some characters (中) before these could.
  fontFallback
    ..clear()
    ..addAll(testFallbackFamilies);
}

/// The share of pixels that may differ before an image fails: 0.5%. A clipped label, a flipped
/// row or a missing glyph changes far more than that; sub-pixel anti-aliasing on glyph edges
/// (another macOS version, another Apple chip) changes less.
const goldenTolerance = 0.005;

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(imageBytes, await getGoldenBytes(golden));
    if (result.passed || result.diffPercent <= goldenTolerance) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}

/// Off macOS: layout is still checked by the tests themselves; images are neither compared nor
/// written (goldens rendered here would not match the macOS ones).
class _LayoutOnlyComparator extends GoldenFileComparator {
  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async => true;

  @override
  Future<void> update(Uri golden, Uint8List imageBytes) async {
    throw UnsupportedError('Goldens are rendered on macOS only (docs/golden-tests.md).');
  }
}
