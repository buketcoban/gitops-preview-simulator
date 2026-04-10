output "preview_artifacts_bucket" {
  value = aws_s3_bucket.preview_artifacts.bucket
}

output "preview_logs_bucket" {
  value = aws_s3_bucket.preview_logs.bucket
}
