#!/usr/bin/env bash
set -euo pipefail

# gen_excludes.sh
# Usage:
#   ./gen_excludes.sh [output_file]
# Writes git-ignored paths (one per line) to output_file or stdout.

OUT="${1:-}"

# Ensure we're in a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: not inside a git repository." >&2
  exit 1
fi

# List git-ignored files/paths (null-separated), convert to newline-separated
if [ -n "$OUT" ]; then
  git ls-files -z -i --exclude-standard | tr '\0' '\n' > "$OUT"
  echo "Wrote git-ignored list to: $OUT"
else
  git ls-files -z -i --exclude-standard | tr '\0' '\n'
fi
