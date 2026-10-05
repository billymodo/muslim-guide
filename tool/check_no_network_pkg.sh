#!/bin/bash
# CI-016 — لا حزمة شبكة في pubspec.yaml الرئيسي.
# spike/pubspec.yaml مستثنى (legal/policy.yaml ci.exemptions.ci_016_network_pkg).
POLICY="legal/policy.yaml"
EXEMPTIONS=$(grep 'ci_016_network_pkg:' "$POLICY" 2>/dev/null | grep -oE '"[^"]+"' | tr '\n' ' ' || true)
echo "info: ci_016_network_pkg exemptions (policy.yaml) = ${EXEMPTIONS:-none}"
FORBIDDEN="dio http http_client web_socket_channel grpc retrofit"
FAIL=0
for pkg in $FORBIDDEN; do
  if grep -qE "^[[:space:]]+$pkg:" pubspec.yaml; then
    echo "FAIL: network package '$pkg' in pubspec.yaml"
    FAIL=1
  fi
done
if [ "$FAIL" -eq 0 ]; then
  echo "OK: no network packages"
fi
exit "$FAIL"
