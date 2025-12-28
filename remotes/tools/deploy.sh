#!/usr/bin/env bash
set -euo pipefail

# deploy.sh
# Usage:
#   ./deploy.sh user@host /remote/path ["remote command"]
#
# Example:
#   ./deploy.sh user@server /var/www/myapp "systemctl restart myapp"
#   ./deploy.sh user@server /var/www/myapp

if [ $# -lt 2 ]; then
  echo "Usage: $0 user@host /remote/path [\"remote command\"]" >&2
  exit 1
fi

# Get args
REMOTE="$1"
REMOTE_PATH="$2"
shift 2
REMOTE_COMMAND="$@"

# Ensure remote dir exists
ssh "$REMOTE" "mkdir -p -- '$REMOTE_PATH'"

# Run rsync: include everything except excluded
RSYNC_CMD=(rsync -avz --delete ./ "${REMOTE}:${REMOTE_PATH%/}/" --exclude-from=".gitignore" )

echo "Running rsync..."
echo "${RSYNC_CMD[@]}"
"${RSYNC_CMD[@]}"

# Run remote command (in the deployed directory), if provided
if [ $# -gt 0 ]; then
  echo "Running remote command: $REMOTE_COMMAND"
  echo ssh -t "$REMOTE" "cd '$REMOTE_PATH' && ${REMOTE_COMMAND[*]}"
  ssh -t "$REMOTE" "cd '$REMOTE_PATH' && ${REMOTE_COMMAND[*]}"
fi

echo "Deploy finished."
