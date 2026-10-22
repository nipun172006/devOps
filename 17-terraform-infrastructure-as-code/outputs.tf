output "bucket_name" {
  description = "Generated name of the S3 bucket."
  value       = aws_s3_bucket.lab.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket."
  value       = aws_s3_bucket.lab.arn
}

output "bucket_region" {
  description = "AWS region containing the bucket."
  value       = var.aws_region
}

output "security_controls" {
  description = "Security controls configured for the bucket."
  value = {
    encryption         = "AES256"
    public_access      = "blocked"
    object_ownership   = "BucketOwnerEnforced"
    versioning         = "Enabled"
    force_destroy_demo = true
  }
}
