#!/bin/sh
# Submits a file (zip, dmg, pkg) to Apple's notary service and waits for the verdict.
# Used by .github/workflows/release.yml.
# Needs NOTARY_KEY_PATH, NOTARY_KEY_ID and NOTARY_ISSUER_ID (App Store Connect API key).
set -eu

[ $# -eq 1 ] || { echo "usage: $0 <file>" >&2; exit 64; }

out=$(xcrun notarytool submit "$1" \
  --key "$NOTARY_KEY_PATH" --key-id "$NOTARY_KEY_ID" --issuer "$NOTARY_ISSUER_ID" \
  --wait --timeout 30m --output-format json)
echo "$out"

status=$(echo "$out" | jq -r '.status')
if [ "$status" != "Accepted" ]; then
  id=$(echo "$out" | jq -r '.id')
  echo "error: notarization status is '$status'. Log:" >&2
  xcrun notarytool log "$id" \
    --key "$NOTARY_KEY_PATH" --key-id "$NOTARY_KEY_ID" --issuer "$NOTARY_ISSUER_ID" >&2 || true
  exit 1
fi
