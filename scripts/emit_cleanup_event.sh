#!/bin/bash
set -euo pipefail

NAMESPACE="${1:-}"

if [ -z "$NAMESPACE" ]; then
  echo "Usage: $0 <namespace>"
  exit 1
fi

cat <<JSON
{
  "event_type": "preview.cleanup",
  "namespace": "$NAMESPACE",
  "emitted_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
JSON
