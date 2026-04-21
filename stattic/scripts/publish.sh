#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/publish.sh <file-or-dir> [stattic publish options]

Examples:
  ./scripts/publish.sh ./dist
  ./scripts/publish.sh ./dist --project my-project
  ./scripts/publish.sh ./dist --access-token stat_123
USAGE
  exit 1
}

die() {
  echo "error: $1" >&2
  exit 1
}

[[ $# -gt 0 ]] || usage
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  usage
fi

TARGET="$1"
shift

[[ -e "$TARGET" ]] || die "path does not exist: $TARGET"

CLI_CMD=()
if [[ -n "${STATTIC_CLI_BIN:-}" ]]; then
  CLI_CMD=("$STATTIC_CLI_BIN")
elif [[ -f "$(dirname "$0")/stattic-cli.js" ]] && command -v node >/dev/null 2>&1; then
  CLI_CMD=(node "$(dirname "$0")/stattic-cli.js")
elif command -v stattic >/dev/null 2>&1; then
  CLI_CMD=("$(command -v stattic)")
elif command -v npx >/dev/null 2>&1; then
  CLI_CMD=(npx --yes @bi/stattic-cli)
elif command -v npm >/dev/null 2>&1; then
  CLI_CMD=(npm exec --yes --package=@bi/stattic-cli -- stattic)
else
  die "unable to find the Stattic CLI in this environment. Re-run curl -fsSL https://stattic.net/install.sh | bash"
fi

CLIENT_VALUE="${STATTIC_PUBLISH_CLIENT:-skills.sh/publish-sh}"
HAS_CLIENT_FLAG=0
for arg in "$@"; do
  if [[ "$arg" == "--client" || "$arg" == --client=* ]]; then
    HAS_CLIENT_FLAG=1
    break
  fi
done

EXTRA_ARGS=("$@")
if [[ "$HAS_CLIENT_FLAG" -eq 0 ]]; then
  EXTRA_ARGS=(--client "$CLIENT_VALUE" "${EXTRA_ARGS[@]}")
fi

exec "${CLI_CMD[@]}" publish "$TARGET" "${EXTRA_ARGS[@]}"
