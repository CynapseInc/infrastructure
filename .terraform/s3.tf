data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "raw" {
  bucket = "${var.project_name}-s3-raw-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.project_name}-s3-raw"
  }
}

resource "aws_s3_bucket" "trusted" {
  bucket = "${var.project_name}-s3-trusted-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.project_name}-s3-trusted"
  }
}

resource "aws_s3_bucket" "refined" {
  bucket = "${var.project_name}-s3-refined-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.project_name}-s3-refined"
  }
}

resource "aws_s3_bucket_versioning" "raw" {
  bucket = aws_s3_bucket.raw.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "trusted" {
  bucket = aws_s3_bucket.trusted.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "refined" {
  bucket = aws_s3_bucket.refined.id

  versioning_configuration {
    status = "Enabled"
  }
}
