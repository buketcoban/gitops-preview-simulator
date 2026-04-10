resource "aws_s3_bucket" "preview_artifacts" {
  bucket = "preview-artifacts"

  tags = {
    Project     = "gitops-preview-simulator"
    Environment = "local"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket" "preview_logs" {
  bucket = "preview-logs"

  tags = {
    Project     = "gitops-preview-simulator"
    Environment = "local"
    ManagedBy   = "terraform"
  }
}
