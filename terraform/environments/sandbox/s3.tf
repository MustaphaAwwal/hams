resource "aws_s3_bucket" "loki_logs" {
  bucket = "loki-logs-bucket-sandbox"

  tags = {
    Name        = "LokiLogs"
    Environment = "sandbox"
  }
}


# LiveKit Egress S3 Bucket
resource "aws_s3_bucket" "livekit_egress" {
  bucket = "livekit-eggress-bucket"

  tags = {
    Environment = "sandbox"
    Terraform   = "true"
  }
}

resource "aws_s3_bucket_versioning" "livekit_egress_versioning" {
  bucket = aws_s3_bucket.livekit_egress.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "livekit_egress_encryption" {
  bucket = aws_s3_bucket.livekit_egress.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "livekit_egress_block" {
  bucket                  = aws_s3_bucket.livekit_egress.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
