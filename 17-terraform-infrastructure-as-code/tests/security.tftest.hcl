mock_provider "aws" {}

run "secure_s3_plan" {
  command = plan

  assert {
    condition     = aws_s3_bucket_public_access_block.lab.block_public_acls && aws_s3_bucket_public_access_block.lab.block_public_policy && aws_s3_bucket_public_access_block.lab.ignore_public_acls && aws_s3_bucket_public_access_block.lab.restrict_public_buckets
    error_message = "Every S3 public-access-block control must be enabled."
  }

  assert {
    condition     = one(one(aws_s3_bucket_server_side_encryption_configuration.lab.rule).apply_server_side_encryption_by_default).sse_algorithm == "AES256"
    error_message = "The bucket must use explicit AES256 server-side encryption."
  }

  assert {
    condition     = one(aws_s3_bucket_versioning.lab.versioning_configuration).status == "Enabled"
    error_message = "Bucket versioning must be enabled."
  }

  assert {
    condition     = one(aws_s3_bucket_ownership_controls.lab.rule).object_ownership == "BucketOwnerEnforced"
    error_message = "BucketOwnerEnforced ownership must disable object ACLs."
  }

  assert {
    condition     = one(one(aws_s3_bucket_lifecycle_configuration.lab.rule).abort_incomplete_multipart_upload).days_after_initiation == 7
    error_message = "Incomplete multipart uploads must expire after seven days."
  }
}
