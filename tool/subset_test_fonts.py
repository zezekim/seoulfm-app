"""Builds the fallback fonts the golden tests draw with (test/fonts; see docs/golden-tests.md).

Pretendard covers Latin and Hangul; these cover the scripts it lacks among the golden locales
(Arabic, Thai, Japanese), cut down to those scripts so the repo stays small. Sources: the Noto
fonts in the google/fonts repository (SIL OFL 1.1):

  ofl/notosansarabic/NotoSansArabic[wdth,wght].ttf
  ofl/notosansthai/NotoSansThai[wdth,wght].ttf
  ofl/notosansjp/NotoSansJP[wght].ttf

  python3 tool/subset_test_fonts.py <folder holding those three files>

Needs fontTools (`pip install fonttools`). Japanese keeps the kana and the kanji app_ja.arb uses:
rerun this when Japanese strings gain new kanji (they would draw as boxes in the goldens).
"""

import glob
import io
import json
import os
import sys

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'test', 'fonts')


def arb_chars(name):
    chars = set()
    for path in glob.glob(os.path.join(ROOT, 'lib', 'l10n', name)):
        with open(path, encoding='utf-8') as f:
            for key, value in json.load(f).items():
                if not key.startswith('@') and isinstance(value, str):
                    chars.update(ord(c) for c in value)
    return chars


def span(a, b):
    return set(range(a, b + 1))


def build(src, dst, codepoints):
    font = TTFont(src)
    # One width (normal); the weight axis stays, as Pretendard's does.
    if 'fvar' in font and any(a.axisTag == 'wdth' for a in font['fvar'].axes):
        font = instancer.instantiateVariableFont(font, {'wdth': 100})
        buf = io.BytesIO()
        font.save(buf)
        buf.seek(0)
        font = TTFont(buf)
    options = subset.Options()
    options.layout_features = ['*']
    options.name_IDs = ['*']
    options.notdef_outline = True
    options.hinting = False
    sub = subset.Subsetter(options)
    sub.populate(unicodes=codepoints)
    sub.subset(font)
    path = os.path.join(OUT, dst)
    font.save(path)
    print(dst, os.path.getsize(path))


def main(src_dir):
    os.makedirs(OUT, exist_ok=True)
    common = span(0x20, 0x7E) | {0xA0, 0xB7, 0x200C, 0x200D, 0x200E, 0x200F, 0x2013, 0x2014, 0x2026, 0x2212}
    build(
        glob.glob(os.path.join(src_dir, 'NotoSansArabic*.ttf'))[0],
        'NotoSansArabic-Subset.ttf',
        common | span(0x0600, 0x06FF) | span(0x0750, 0x077F) | span(0xFB50, 0xFDFF) | span(0xFE70, 0xFEFF),
    )
    build(
        glob.glob(os.path.join(src_dir, 'NotoSansThai*.ttf'))[0],
        'NotoSansThai-Subset.ttf',
        common | span(0x0E00, 0x0E7F),
    )
    build(
        glob.glob(os.path.join(src_dir, 'NotoSansJP*.ttf'))[0],
        'NotoSansJP-Subset.ttf',
        common | span(0x3000, 0x30FF) | span(0xFF00, 0xFFEF) | arb_chars('app_ja.arb'),
    )


if __name__ == '__main__':
    main(sys.argv[1])
