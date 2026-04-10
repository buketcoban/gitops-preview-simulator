#!/bin/bash
set -euo pipefail

BRANCH_NAME="${1:-}"
COMMIT_SHA="${2:-local-dev}"

if [ -z "$BRANCH_NAME" ]; then
  echo "Usage: $0 <branch-name> [commit-sha]"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SANITIZED_BRANCH="$("$SCRIPT_DIR/sanitize_branch.sh" "$BRANCH_NAME")"
NAMESPACE="preview-$SANITIZED_BRANCH"
DEPLOYED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

kubectl annotate namespace "$NAMESPACE" \
  preview.created_at="$DEPLOYED_AT" \
  preview.ttl_hours="24" \
  --overwrite

cat <<MANIFEST | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: preview-demo
  namespace: $NAMESPACE
  labels:
    app: preview-demo
    branch: $SANITIZED_BRANCH
spec:
  replicas: 1
  selector:
    matchLabels:
      app: preview-demo
  template:
    metadata:
      labels:
        app: preview-demo
        branch: $SANITIZED_BRANCH
    spec:
      containers:
        - name: preview-demo
          image: preview-demo:local
          imagePullPolicy: Never
          ports:
            - containerPort: 8000
          env:
            - name: APP_NAME
              value: "preview-demo"
            - name: BRANCH_NAME
              value: "$BRANCH_NAME"
            - name: COMMIT_SHA
              value: "$COMMIT_SHA"
            - name: ENVIRONMENT_NAME
              value: "$NAMESPACE"
            - name: DEPLOYED_AT
              value: "$DEPLOYED_AT"
---
apiVersion: v1
kind: Service
metadata:
  name: preview-demo
  namespace: $NAMESPACE
spec:
  selector:
    app: preview-demo
  ports:
    - protocol: TCP
      port: 8000
      targetPort: 8000
  type: ClusterIP
MANIFEST

echo "Deployed branch '$BRANCH_NAME' into namespace '$NAMESPACE'"