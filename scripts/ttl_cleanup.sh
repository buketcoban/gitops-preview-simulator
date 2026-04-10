#!/bin/bash
set -euo pipefail

source ~/Documents/gitops-preview-simulator/scripts/aws-local-env.sh

NOW_EPOCH=$(date -u +%s)

for NS in $(kubectl get ns -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep '^preview-'); do
  CREATED_AT=$(kubectl get ns "$NS" -o jsonpath='{.metadata.annotations.preview\.created_at}' 2>/dev/null || true)
  TTL_HOURS=$(kubectl get ns "$NS" -o jsonpath='{.metadata.annotations.preview\.ttl_hours}' 2>/dev/null || true)

  if [ -z "$CREATED_AT" ] || [ -z "$TTL_HOURS" ]; then
    echo "Skipping $NS (missing TTL annotations)"
    continue
  fi

  CREATED_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$CREATED_AT" +%s 2>/dev/null || true)

  if [ -z "$CREATED_EPOCH" ]; then
    echo "Skipping $NS (invalid created_at format: $CREATED_AT)"
    continue
  fi

  TTL_SECONDS=$((TTL_HOURS * 3600))
  AGE_SECONDS=$((NOW_EPOCH - CREATED_EPOCH))

  if [ "$AGE_SECONDS" -ge "$TTL_SECONDS" ]; then
    echo "TTL expired for $NS, cleaning up..."

    TMP_FILE="$(mktemp)"
    cat > "$TMP_FILE" <<JSON
{
  "namespace": "$NS",
  "status": "ttl-cleanup-triggered",
  "created_at": "$CREATED_AT",
  "ttl_hours": "$TTL_HOURS",
  "cleaned_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
JSON

    aws --endpoint-url="$AWS_ENDPOINT_URL" s3 cp "$TMP_FILE" "s3://preview-artifacts/${NS}/ttl-cleanup-report.json"
    kubectl delete namespace "$NS"
    rm -f "$TMP_FILE"
  else
    echo "Keeping $NS (age ${AGE_SECONDS}s < ttl ${TTL_SECONDS}s)"
  fi
done
