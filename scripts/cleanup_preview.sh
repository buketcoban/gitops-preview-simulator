#!/bin/bash
set -euo pipefail

NAMESPACE="${1:-}"

if [ -z "$NAMESPACE" ]; then
  echo "Usage: $0 <namespace>"
  exit 1
fi

if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  echo "Namespace not found: $NAMESPACE"
  exit 1
fi

kubectl delete namespace "$NAMESPACE"

echo "Cleanup triggered for namespace: $NAMESPACE"
