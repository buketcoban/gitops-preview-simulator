#!/bin/bash
set -euo pipefail

NAMESPACE="${1:-}"

if [ -z "$NAMESPACE" ]; then
  echo "Usage: $0 <namespace>"
  exit 1
fi

source ~/Documents/gitops-preview-simulator/scripts/aws-local-env.sh

if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  echo "Namespace not found: $NAMESPACE"
  exit 1
fi

TMP_FILE="$(mktemp)"

cat > "$TMP_FILE" <<JSON
{
  "namespace": "$NAMESPACE",
  "status": "cleanup-triggered",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
JSON

aws --endpoint-url="$AWS_ENDPOINT_URL" s3 cp "$TMP_FILE" "s3://preview-artifacts/${NAMESPACE}/cleanup-report.json"

kubectl delete namespace "$NAMESPACE"

rm -f "$TMP_FILE"

echo "Cleanup completed for namespace: $NAMESPACE"
