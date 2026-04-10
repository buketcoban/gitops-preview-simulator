from fastapi import FastAPI
import os
from datetime import datetime, timezone

app = FastAPI()

APP_NAME = os.getenv("APP_NAME", "preview-demo")
BRANCH_NAME = os.getenv("BRANCH_NAME", "unknown-branch")
COMMIT_SHA = os.getenv("COMMIT_SHA", "unknown-commit")
ENVIRONMENT_NAME = os.getenv("ENVIRONMENT_NAME", "local-dev")
DEPLOYED_AT = os.getenv("DEPLOYED_AT", datetime.now(timezone.utc).isoformat())

@app.get("/")
def root():
    return {
        "message": "GitOps Preview Environment Demo",
        "app": APP_NAME,
        "branch": BRANCH_NAME,
        "commit": COMMIT_SHA,
        "environment": ENVIRONMENT_NAME,
        "deployed_at": DEPLOYED_AT
    }

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/metadata")
def metadata():
    return {
        "app": APP_NAME,
        "branch": BRANCH_NAME,
        "commit": COMMIT_SHA,
        "environment": ENVIRONMENT_NAME,
        "deployed_at": DEPLOYED_AT
    }