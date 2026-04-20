#!/usr/bin/env bash
set -euo pipefail

SKILL_REPO="batuhan/stattic-skill"
SKILL_NAME="stattic"
DEFAULT_ARGS=(add "$SKILL_REPO" --skill "$SKILL_NAME" -g)

run() {
  printf '==> %s\n' "$*" >&2
  "$@"
}

if command -v skills >/dev/null 2>&1; then
  run skills "${DEFAULT_ARGS[@]}" "$@"
  exit 0
fi

if command -v npx >/dev/null 2>&1; then
  run npx --yes skills "${DEFAULT_ARGS[@]}" "$@"
  exit 0
fi

if command -v npm >/dev/null 2>&1; then
  run npm exec --yes --package=skills@latest -- \
    skills "${DEFAULT_ARGS[@]}" "$@"
  exit 0
fi

cat >&2 <<'EOF'
error: Stattic install currently requires Node.js with npm.

Install Node.js, then re-run:
  curl -fsSL https://stattic.net/install.sh | bash

Or install directly with:
  npx skills add batuhan/stattic-skill --skill stattic -g
EOF
exit 1
