#!/bin/sh
# One-time per clone: use the tracked hooks in scripts/hooks.
set -eu
cd "$(dirname "$0")/.."
chmod +x scripts/check-no-signing.sh scripts/hooks/*
git config core.hooksPath scripts/hooks
echo "Git hooks enabled (core.hooksPath=scripts/hooks)."
