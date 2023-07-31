resource "aws_s3_bucket" "codepipeline_artifact" {
  bucket = "${local.name_prefix}-codepipeline-artifact"
  # サンプルのため後で消しやすいように
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline_artifact" {
  bucket = aws_s3_bucket.codepipeline_artifact.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_public_access_block" "codepipeline_artifact" {
  bucket = aws_s3_bucket.codepipeline_artifact.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}