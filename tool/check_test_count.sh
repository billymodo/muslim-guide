#!/bin/bash
# CI-012 — عدد الاختبارات لا ينقص عن الأساسي.
# baseline = 2 لأنه يحسب testID فريدة (widget test = 2 entries) — معتمد 2026-10-06.
# عند إضافة اختبارات: حدّث tool/test_count_baseline.txt في نفس الـPR.
set -u
BASELINE_FILE="tool/test_count_baseline.txt"
if [ ! -f "$BASELINE_FILE" ]; then
  echo "FAIL: baseline file missing: $BASELINE_FILE"
  exit 1
fi
BASELINE=$(tr -d '[:space:]' < "$BASELINE_FILE")
case "$BASELINE" in
  ''|*[!0-9]*) echo "FAIL: baseline is not a number: '$BASELINE'"; exit 1 ;;
esac
LOG=$(mktemp)
flutter test --reporter=json >"$LOG" 2>/dev/null
STATUS=$?
if [ "$STATUS" -ne 0 ]; then
  echo "FAIL: flutter test failed (exit $STATUS)"
  cat "$LOG"
  rm -f "$LOG"
  exit 1
fi
CURRENT=$(grep -o '"testID":[0-9]*' "$LOG" | sort -u | wc -l | tr -d '[:space:]')
rm -f "$LOG"
if [ -z "$CURRENT" ]; then CURRENT=0; fi
if [ "$CURRENT" -lt "$BASELINE" ]; then
  echo "FAIL: Test count dropped from $BASELINE to $CURRENT"
  exit 1
fi
if [ "$CURRENT" -gt "$BASELINE" ]; then
  echo "WARN: $CURRENT tests > baseline $BASELINE — حدّث tool/test_count_baseline.txt في نفس الـPR"
fi
echo "OK: $CURRENT tests (baseline $BASELINE)"
exit 0
