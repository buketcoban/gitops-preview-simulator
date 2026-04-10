#!/bin/bash
set -euo pipefail

NAMESPACE="${1:-}"
REPORT_FILE="${2:-smoke-test-report.json}"

if [ -z "$NAMESPACE" ]; then
  echo "Usage: $0 <namespace> [report-file]"
  exit 1
fi

if [ ! -f "$REPORT_FILE" ]; then
  echo "Report file not found: $REPORT_FILE"
  exit 1
fi

source ~/Documents/gitops-preview-simulator/scripts/aws-local-env.sh

ARTIFACT_KEY="${NAMESPACE}/smoke-test-report.json"

aws --endpoint-url="$AWS_ENDPOINT_URL" s3 cp "$REPORT_FILE" "s3://preview-artifacts/${ARTIFACT_KEY}"

echo "Uploaded to s3://preview-artifacts/${ARTIFACT_KEY}"
