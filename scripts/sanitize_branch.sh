#!/bin/bash
set -euo pipefail

BRANCH_NAME="${1:-}"

if [ -z "$BRANCH_NAME" ]; then
  echo "Usage: $0 <branch-name>"
  exit 1
fi

SANITIZED=$(echo "$BRANCH_NAME" \
  | tr '[:upper:]' '[:lower:]' \
  | sed 's#[/_]#-#g' \
  | sed 's/[^a-z0-9-]//g' \
  | sed 's/--*/-/g' \
  | sed 's/^-//' \
  | sed 's/-$//')

echo "$SANITIZED"
