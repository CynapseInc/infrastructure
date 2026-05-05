# 1. Zip dos arquivos Python
data "archive_file" "lambda_raw_trusted_zip" {
  type        = "zip"
  source_file = "${path.module}/lambdas/lambda_function.py"
  output_path = "${path.module}/lambdas/lambda_raw_trusted.zip"
}

data "archive_file" "lambda_trusted_refined_zip" {
  type        = "zip"
  source_file = "${path.module}/lambdas/lambda_trusted_refined.py"
  output_path = "${path.module}/lambdas/lambda_trusted_refined.zip"
}

# 2. Busca a LabRole existente na conta da AWS (Laboratório)
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# 3. Lambda: Raw -> Trusted
resource "aws_lambda_function" "raw_to_trusted" {
  filename         = data.archive_file.lambda_raw_trusted_zip.output_path
  function_name    = "${var.project_name}-raw-to-trusted"
  
  # Usando a LabRole existente
  role             = data.aws_iam_role.lab_role.arn
  
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_raw_trusted_zip.output_base64sha256
  
  memory_size = 256
  timeout     = 60

  # Layer do Pandas atualizada para Python 3.12
  layers = ["arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python312:8"]

  environment {
    variables = {
      BUCKET_RAW     = aws_s3_bucket.raw.bucket
      BUCKET_TRUSTED = aws_s3_bucket.trusted.bucket
    }
  }
}

# 4. Lambda: Trusted -> Refined
resource "aws_lambda_function" "trusted_to_refined" {
  filename         = data.archive_file.lambda_trusted_refined_zip.output_path
  function_name    = "${var.project_name}-trusted-to-refined"
  
  # Usando a LabRole existente
  role             = data.aws_iam_role.lab_role.arn
  
  handler          = "lambda_trusted_refined.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_trusted_refined_zip.output_base64sha256
  
  memory_size = 1024
  timeout     = 300 

  # Layer do Pandas atualizada para Python 3.12
  layers = ["arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python312:8"]

  environment {
    variables = {
      BUCKET_TRUSTED = aws_s3_bucket.trusted.bucket
      BUCKET_REFINED = aws_s3_bucket.refined.bucket
    }
  }
}

# 5. Configuração dos Gatilhos S3 (Event Notifications)
resource "aws_lambda_permission" "allow_bucket_raw" {
  statement_id  = "AllowExecutionFromS3BucketRaw"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.raw_to_trusted.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw.arn
}

resource "aws_s3_bucket_notification" "raw_trigger" {
  bucket = aws_s3_bucket.raw.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.raw_to_trusted.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }
  depends_on = [aws_lambda_permission.allow_bucket_raw]
}

resource "aws_lambda_permission" "allow_bucket_trusted" {
  statement_id  = "AllowExecutionFromS3BucketTrusted"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trusted_to_refined.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.trusted.arn
}

resource "aws_s3_bucket_notification" "trusted_trigger" {
  bucket = aws_s3_bucket.trusted.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.trusted_to_refined.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }
  depends_on = [aws_lambda_permission.allow_bucket_trusted]
}