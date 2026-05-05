data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "raw" {
  bucket = "${var.project_name}-s3-raw-${data.aws_caller_identity.current.account_id}"
  tags = {
    Name = "${var.project_name}-s3-raw"
  }
  force_destroy = true
}

resource "aws_s3_bucket" "trusted" {
  bucket = "${var.project_name}-s3-trusted-${data.aws_caller_identity.current.account_id}"
  tags = {
    Name = "${var.project_name}-s3-trusted"
  }
  force_destroy = true
}

resource "aws_s3_bucket" "refined" {
  bucket = "${var.project_name}-s3-refined-${data.aws_caller_identity.current.account_id}"
  tags = {
    Name = "${var.project_name}-s3-refined"
  }
  force_destroy = true
}

resource "aws_s3_bucket" "deploy" {
  bucket = "${var.project_name}-s3-deploy-${data.aws_caller_identity.current.account_id}"
  tags = {
    Name = "${var.project_name}-s3-deploy"
  }
}
resource "aws_s3_object" "imagens_iniciais" {
  bucket = aws_s3_bucket.deploy.bucket
  key    = "backend/imagens-iniciais.zip"
  source = "${path.module}/assets/imagens-iniciais.zip" 
  etag   = filemd5("${path.module}/assets/imagens-iniciais.zip")
}