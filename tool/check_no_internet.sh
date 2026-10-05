#!/bin/bash
# CI-015 — لا صلاحية INTERNET في manifest التطبيق الرئيسي.
# الاستثناءات تُقرأ من legal/policy.yaml (ci.exemptions.ci_015_internet).
POLICY="legal/policy.yaml"
EXEMPTIONS=$(grep 'ci_015_internet:' "$POLICY" 2>/dev/null | grep -oE '"[^"]+"' | tr '\n' ' ' || true)
echo "info: ci_015_internet exemptions (policy.yaml) = ${EXEMPTIONS:-none}"
MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ ! -f "$MANIFEST" ]; then
  echo "SKIP: Manifest not found"
  exit 0
fi
if grep -q 'android.permission.INTERNET' "$MANIFEST"; then
  echo "FAIL: INTERNET permission found in $MANIFEST"
  echo "Network forbidden until Phase 07 (recitation exception)"
  exit 1
fi
echo "OK: no INTERNET permission"
exit 0
