#!/bin/sh
# Fails if signing identity values are set in tracked project files, or if the
# developer's local team ID appears in anything about to be committed.
# Run from the pre-commit hook (scripts/hooks/pre-commit) or CI.
set -eu
cd "$(dirname "$0")/.."
fail=0

# 1. Project + scheme files: any non-empty signing key, including conditional
#    variants like "DEVELOPMENT_TEAM[sdk=macosx*]".
files="Devops-monitor.xcodeproj/project.xcproj $(find Devops-monitor.xcodeproj/xcshareddata -type f 2>/dev/null | tr '\n' ' ')"
# shellcheck disable=SC2086
if grep -nE '"(DEVELOPMENT_TEAM|CODE_SIGN_IDENTITY|PROVISIONING_PROFILE(_SPECIFIER)?)[^"]*" *: *"[^"]+"' $files; then
  echo "error: signing values found in project files. Put them in Config/Signing.local.xcconfig." >&2
  fail=1
fi

# 2. Entitlements must not hard-code a team identifier.
if find . -name '*.entitlements' -not -path './.git/*' -not -path '*/.build/*' -print0 \
   | xargs -0 grep -nE 'team-identifier|DEVELOPMENT_TEAM' 2>/dev/null; then
  echo "error: team identifier found in an entitlements file." >&2
  fail=1
fi

# 3. The local team ID must not appear in any tracked or staged file.
local_cfg=Config/Signing.local.xcconfig
if [ -f "$local_cfg" ]; then
  team=$(sed -nE 's/^[[:space:]]*DEVELOPMENT_TEAM[[:space:]]*=[[:space:]]*([A-Z0-9]{10}).*/\1/p' "$local_cfg" | head -n1)
  if [ -n "$team" ] && [ "$team" != "YOURTEAMID" ]; then
    if git grep -nI -e "$team" -- . ':!Config/Signing.local.xcconfig' 2>/dev/null \
       || git grep -nI --cached -e "$team" -- . 2>/dev/null; then
      echo "error: local team ID appears in a tracked/staged file." >&2
      fail=1
    fi
  fi
fi

exit $fail
