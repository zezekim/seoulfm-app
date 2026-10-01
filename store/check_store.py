"""Checks the store listings against each store's limits, and that every language has every
file. Run from the repo root: python3 store/check_store.py"""
import json, os, sys

ROOT = os.path.dirname(os.path.abspath(__file__))
IOS = {'name.txt': 30, 'subtitle.txt': 30, 'keywords.txt': 100, 'promotional_text.txt': 170,
       'description.txt': 4000, 'release_notes.txt': 4000}
ANDROID = {'title.txt': 30, 'short_description.txt': 80, 'full_description.txt': 4000, 'changelogs/300.txt': 500}
CAPTIONS = ['1-home', '2-player', '3-lyrics', '4-genres', '5-charts', '6-request', 'feature']

locales = {k: v for k, v in json.load(open(os.path.join(ROOT, 'locales.json'))).items() if not k.startswith('_')}
problems = []


def check(path, limit):
    if not os.path.exists(path):
        return problems.append(f'missing {os.path.relpath(path, ROOT)}')
    text = open(path, encoding='utf-8').read()
    if not text.strip():
        problems.append(f'empty {os.path.relpath(path, ROOT)}')
    if len(text) > limit:
        problems.append(f'{os.path.relpath(path, ROOT)}: {len(text)} > {limit}')
    if text != text.strip():
        problems.append(f'{os.path.relpath(path, ROOT)}: leading/trailing whitespace')
    return text


for tag, codes in locales.items():
    if codes['ios']:
        for f, limit in IOS.items():
            text = check(os.path.join(ROOT, 'ios', codes['ios'], f), limit)
            if f == 'keywords.txt' and text and (', ' in text or ' ,' in text):
                problems.append(f'ios/{codes["ios"]}/keywords.txt: no spaces around commas')
            if text and 'CarPlay' in text:
                problems.append(f'ios/{codes["ios"]}/{f}: mentions CarPlay')
    for f, limit in ANDROID.items():
        text = check(os.path.join(ROOT, 'android', codes['android'], f), limit)
        if text and ('CarPlay' in text or 'Dynamic Island' in text or 'AirPods' in text):
            problems.append(f'android/{codes["android"]}/{f}: mentions an Apple-only feature')
    cap = os.path.join(ROOT, 'captions', f'{tag}.json')
    if not os.path.exists(cap):
        problems.append(f'missing captions/{tag}.json')
    else:
        c = json.load(open(cap, encoding='utf-8'))
        for k in CAPTIONS:
            if not (isinstance(c.get(k), list) and len(c[k]) == 2 and all(isinstance(s, str) and s.strip() for s in c[k])):
                problems.append(f'captions/{tag}.json: {k} must be two non-empty lines')

print('\n'.join(problems) or f'OK: {len(locales)} languages')
sys.exit(1 if problems else 0)
