#!/bin/bash
set -euo pipefail

NAMESPACE="${1:-}"
LOCAL_PORT="${2:-8001}"

if [ -z "$NAMESPACE" ]; then
  echo "Usage: $0 <namespace> [local-port]"
  exit 1
fi

TMP_DIR="$(mktemp -d)"
METADATA_FILE="$TMP_DIR/metadata.json"
REPORT_FILE="$TMP_DIR/smoke-test-report.json"

kubectl port-forward -n "$NAMESPACE" svc/preview-demo ${LOCAL_PORT}:8000 >/tmp/preview-port-forward.log 2>&1 &
PF_PID=$!

cleanup() {
  kill "$PF_PID" >/dev/null 2>&1 || true
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

sleep 3

curl -s "http://localhost:${LOCAL_PORT}/health" > /dev/null
curl -s "http://localhost:${LOCAL_PORT}/metadata" > "$METADATA_FILE"

BRANCH=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["branch"])' "$METADATA_FILE")
COMMIT=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["commit"])' "$METADATA_FILE")
ENV_NAME=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["environment"])' "$METADATA_FILE")

cat > "$REPORT_FILE" <<JSON
{
  "status": "passed",
  "namespace": "$NAMESPACE",
  "branch": "$BRANCH",
  "commit": "$COMMIT",
  "environment": "$ENV_NAME",
  "tested_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
JSON

cp "$REPORT_FILE" "./smoke-test-report.json"
echo "Smoke test passed. Report saved to ./smoke-test-report.json"
cat "$REPORT_FILE"
