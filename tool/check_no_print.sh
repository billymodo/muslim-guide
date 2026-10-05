#!/bin/bash
# CI-014 — لا print في lib/ أو test/، ولا // ignore بلا سبب مكتوب.
FAIL=0
if grep -rn "print(" lib/ test/ 2>/dev/null; then
  echo "FAIL: print() found in lib/ or test/"
  FAIL=1
fi
while IFS= read -r line; do
  if ! printf '%s' "$line" | grep -qE "// ignore: [A-Za-z0-9_]+"; then
    echo "FAIL: ignore without reason: $line"
    FAIL=1
  fi
done < <(grep -rn "// ignore" lib/ test/ 2>/dev/null || true)
if [ "$FAIL" -eq 0 ]; then
  echo "OK: no print / undocumented ignore"
fi
exit "$FAIL"
