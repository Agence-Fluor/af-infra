#!/usr/bin/env bash
set -euo pipefail

# deploy.sh
# Usage:
#   ./deploy.sh <exclude_file_or_patterns> user@host /remote/path "remote command"
#
# - exclude_file_or_patterns:
#     * if it is an existing filename -> used as rsync --exclude-from file (one pattern per line)
#     * otherwise treated as comma-separated exclude patterns, e.g. "data/,uploads/,*.log"
#
# Example:
#   ./deploy.sh deploy_excludes.txt user@server /var/www/myapp "systemctl restart myapp"
#   ./deploy.sh "data/,uploads/,*.log" user@server /var/www/myapp "ls -la"

if [ $# -lt 4 ]; then
  echo "Usage: $0 <exclude_file_or_patterns> user@host /remote/path \"remote command\"" >&2
  exit 1
fi

EX_ARG="$1"
REMOTE="$2"
REMOTE_PATH="$3"
shift 3
REMOTE_COMMAND="$*"

# Ensure run from repo root
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$REPO_ROOT" ]; then
  echo "Error: not inside a git repository. Run from repo root." >&2
  exit 1
fi
cd "$REPO_ROOT"

# Prepare include list (tracked + untracked non-ignored)
INCLUDE_LIST="$(mktemp)"
git ls-files -z -c -o --exclude-standard | tr '\0' '\n' > "$INCLUDE_LIST"

# Prepare exclude list file
EXCLUDE_FILE="$(mktemp)"
if [ -f "$EX_ARG" ]; then
  # user passed an existing file -> use it directly (copy to tmp to keep behaviour consistent)
  cp -- "$EX_ARG" "$EXCLUDE_FILE"
else
  # treat as comma-separated patterns -> split and write each on its own line
  IFS=',' read -r -a parts <<< "$EX_ARG"
  for p in "${parts[@]}"; do
    # trim spaces
    p_trim="$(echo "$p" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    [ -n "$p_trim" ] && printf '%s\n' "$p_trim" >> "$EXCLUDE_FILE"
  done
fi

# If exclude file is empty, leave it empty (rsync will ignore it)
echo "Include list entries: $(wc -l < "$INCLUDE_LIST")"
echo "Exclude list entries: $(wc -l < "$EXCLUDE_FILE")"

# Ensure remote dir exists
ssh "$REMOTE" "mkdir -p -- '$REMOTE_PATH'"

# Run rsync:
# - --files-from uses only files present in the include list (so only non-gitignored files get considered)
# - --exclude-from ensures anything in the exclude list is not touched/deleted on remote
# - --delete removes remote files not present in the include set (except those excluded)
RSYNC_CMD=( rsync -avz --delete --files-from="$INCLUDE_LIST" ./ "${REMOTE}:${REMOTE_PATH%/}/" --exclude-from="$EXCLUDE_FILE" )

echo "Running rsync..."
"${RSYNC_CMD[@]}"

# Run remote command (in the deployed directory)
if [ -n "$REMOTE_COMMAND" ]; then
  echo "Running remote command: $REMOTE_COMMAND"
  ssh "$REMOTE" bash -lc "set -euo pipefail; cd '$REMOTE_PATH' && $REMOTE_COMMAND"
fi

# Cleanup
rm -f "$INCLUDE_LIST" "$EXCLUDE_FILE"

echo "Deploy finished."
