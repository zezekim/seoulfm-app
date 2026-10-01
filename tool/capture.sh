#!/bin/bash
# Runs an integration test on a simulator and captures the whole screen at each `SHOT <name>`
# line it prints:  tool/capture.sh <simulator udid> <test file> <out dir>
set -uo pipefail
DEVICE="$1"; TARGET="$2"; OUT="$3"
mkdir -p "$OUT"
LOG=$(mktemp)
flutter drive --driver=test_driver/integration_test.dart --target="$TARGET" -d "$DEVICE" \
  --dart-define-from-file=dart-defines.json > "$LOG" 2>&1 &
PID=$!
seen=0
while kill -0 "$PID" 2>/dev/null; do
  n=$(grep -c "SHOT " "$LOG" || true)
  if [ "$n" -gt "$seen" ]; then
    name=$(grep "SHOT " "$LOG" | sed -n "${n}p" | sed -E 's/.*SHOT ([^ ]+).*/\1/')
    case "$name" in *rising*) ;; *) sleep 1.5 ;; esac
    xcrun simctl io "$DEVICE" screenshot "$OUT/$name.png" >/dev/null 2>&1 && echo "captured $name"
    seen=$n
  fi
  sleep 0.2
done
wait "$PID" || true
grep -E "tests passed|Some tests|Expected|Actual" "$LOG" || true
rm -f "$LOG"
