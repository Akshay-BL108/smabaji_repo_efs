data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "alb_logs_bucket" {
  region = var.region
}

resource "aws_s3_bucket" "alb_logs_bucket" {
  force_destroy = true
  bucket = format("%v-%v-ou-alb-logs-%v", var.project, var.environment, data.aws_caller_identity.current.account_id)

  tags = {
    Name      = format("%v-%v-alb-logs-bucket", var.project, var.environment)
    CreatedBy = data.aws_caller_identity.current.arn
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3-lifecycle-policy" {
  # Must have bucket versioning enabled first
  bucket = aws_s3_bucket.alb_logs_bucket.id

  rule {
    id = "config"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs_bucket" {
  bucket = aws_s3_bucket.alb_logs_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.alb_logs_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "alb_bucket_policy" {
  bucket = aws_s3_bucket.alb_logs_bucket.id
  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.alb_logs_bucket.arn}/*/AWSLogs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.alb_logs_bucket.arn}"
        ]
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_server_side_encryption_configuration" "kms_encryption" {
  bucket = aws_s3_bucket.alb_logs_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}
