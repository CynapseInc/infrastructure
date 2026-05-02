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

resource "aws_s3_bucket" "deploy" {
  bucket = "${var.project_name}-s3-deploy-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.project_name}-s3-deploy"
  }
}

locals {
  frontend_dist_files = fileset(var.frontend_dist_path, "**/*")
}

resource "aws_s3_object" "frontend_dist" {
  for_each = { for file in local.frontend_dist_files : file => file }

  bucket       = aws_s3_bucket.deploy.id
  key          = "frontend/${each.value}"
  source       = "${var.frontend_dist_path}/${each.value}"
  etag         = filemd5("${var.frontend_dist_path}/${each.value}")
  content_type = lookup(local.mime_types, regex("[^.]+$", each.value), "application/octet-stream")
}

resource "aws_s3_object" "backend_jar" {
  bucket = aws_s3_bucket.deploy.id
  key    = "backend/app.jar"
  source = var.backend_jar_path
  etag   = filemd5(var.backend_jar_path)
}

resource "aws_s3_object" "docker_compose" {
  bucket = aws_s3_bucket.deploy.id
  key    = "backend/docker-compose.yml"                # Caminho dentro do S3
  source = "${path.module}/scripts/docker-compose.yml" # Caminho no seu PC
  etag   = filemd5("${path.module}/scripts/docker-compose.yml")
}

resource "aws_s3_object" "gerar_inserts_py" {
  bucket = aws_s3_bucket.deploy.id
  key    = "backend/gerarInserts2.py"
  source = "../backend/EncantoPersonalizados/gerarInserts2.py"
  etag   = filemd5("../backend/EncantoPersonalizados/gerarInserts2.py")
}

resource "aws_s3_object" "whatsapp_env" {
  bucket = aws_s3_bucket.deploy.id
  key    = "backend/whatsapp.env"
  source = "../backend/EncantoPersonalizados/API WHATSAPP/.env"
  etag   = filemd5("../backend/EncantoPersonalizados/API WHATSAPP/.env")
}

locals {
  mime_types = {
    css   = "text/css"
    html  = "text/html"
    ico   = "image/x-icon"
    js    = "application/javascript"
    json  = "application/json"
    png   = "image/png"
    svg   = "image/svg+xml"
    txt   = "text/plain"
    webp  = "image/webp"
    woff  = "font/woff"
    woff2 = "font/woff2"
  }
}
