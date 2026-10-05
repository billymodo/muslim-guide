#!/bin/bash
# CI-017 — لا placeholder في الكود الرئيسي (lib/, assets/).
# النمط يُقرأ من legal/policy.yaml → development_mode.placeholders_pattern.
# الاستثناءات: ci.exemptions.ci_017_placeholder.
POLICY="legal/policy.yaml"
EXEMPTIONS=$(grep 'ci_017_placeholder:' "$POLICY" 2>/dev/null | grep -oE '"[^"]+"' | tr '\n' ' ' || true)
echo "info: ci_017_placeholder exemptions (policy.yaml) = ${EXEMPTIONS:-none}"
RAW=$(grep -E 'placeholders_pattern:' "$POLICY" | head -n 1 | sed -E 's/.*placeholders_pattern:[[:space:]]*"?([^"]*)"?.*/\1/')
if [ -z "$RAW" ]; then
  echo "FAIL: placeholders_pattern not found in $POLICY"
  exit 1
fi
PATTERN=$(printf '%b' "$RAW")
echo "info: pattern = $PATTERN"
HITS=$(grep -rnE "$PATTERN" lib/ assets/ 2>/dev/null || true)
if [ -n "$HITS" ]; then
  echo "FAIL: placeholder found in main code"
  printf '%s\n' "$HITS"
  exit 1
fi
echo "OK: no placeholders in main"
exit 0
