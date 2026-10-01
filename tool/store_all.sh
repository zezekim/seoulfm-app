#!/bin/bash
# Captures the raw store screenshots for every app language on one device:
#   tool/store_all.sh <simulator udid | adb serial> <out dir> [tag ...]
# Languages default to every tag in store/locales.json. Frame them with tool/compose_store.swift.
set -uo pipefail
DEVICE="$1"; OUT="$2"; shift 2
TAGS=("$@")
if [ ${#TAGS[@]} -eq 0 ]; then
  TAGS=($(python3 -c "import json;print(' '.join(k for k in json.load(open('store/locales.json')) if not k.startswith('_')))"))
fi
for tag in "${TAGS[@]}"; do
  echo "== $tag"
  tool/store_screenshots.sh "$DEVICE" "$tag" "$OUT"
done
