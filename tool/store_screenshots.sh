#!/bin/bash
# Captures the store screenshots on an iOS simulator or an Android emulator/device: runs
# integration_test/store_test.dart and takes a full-screen capture (status bar included) at each
# `SHOT` line. Android gets a clean 9:41 status bar through System UI demo mode.
#   tool/store_screenshots.sh <simulator udid | adb serial> <locale> <out dir>
set -euo pipefail
DEVICE="$1"; LOCALE="$2"; OUT="$3"
mkdir -p "$OUT"
ADB="${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools/adb"
ANDROID=0
if "$ADB" devices 2>/dev/null | grep -q "^$DEVICE[[:space:]]"; then
  ANDROID=1
  "$ADB" -s "$DEVICE" shell settings put global sysui_demo_allowed 1
  for cmd in "clock -e hhmm 0941" "battery -e level 100 -e plugged false" "network -e wifi show -e level 4" \
             "network -e mobile show -e level 4 -e datatype none" "notifications -e visible false"; do
    "$ADB" -s "$DEVICE" shell am broadcast -a com.android.systemui.demo -e command enter >/dev/null
    "$ADB" -s "$DEVICE" shell am broadcast -a com.android.systemui.demo -e command $cmd >/dev/null
  done
fi
capture() {
  if [ "$ANDROID" = 1 ]; then "$ADB" -s "$DEVICE" exec-out screencap -p > "$1"; else xcrun simctl io "$DEVICE" screenshot "$1" >/dev/null 2>&1; fi
}
LOG=$(mktemp)
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/store_test.dart \
  -d "$DEVICE" --dart-define-from-file=dart-defines.json --dart-define=LOCALE="$LOCALE" > "$LOG" 2>&1 &
PID=$!
seen=0
while kill -0 "$PID" 2>/dev/null; do
  n=$(grep -c "SHOT " "$LOG" || true)
  if [ "$n" -gt "$seen" ]; then
    name=$(grep "SHOT " "$LOG" | sed -n "${n}p" | sed -E 's/.*SHOT ([^ ]+).*/\1/')
    sleep 2
    capture "$OUT/$name.png" && echo "captured $name"
    seen=$n
  fi
  sleep 0.5
done
wait "$PID" || true
grep -E "tests passed|Some tests" "$LOG" || true
# Keep the whole log when a language fails, to see why.
if grep -q "Some tests failed" "$LOG"; then cp "$LOG" "$OUT/$LOCALE-failure.log"; echo "log: $OUT/$LOCALE-failure.log"; fi
rm -f "$LOG"
if [ "$ANDROID" = 1 ]; then "$ADB" -s "$DEVICE" shell am broadcast -a com.android.systemui.demo -e command exit >/dev/null; fi
