# S3 Bucket para armazenar resultados do Athena
resource "aws_s3_bucket" "athena_results" {
  bucket = "${var.project_name}-athena-results-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.project_name}-athena-results"
  }
}

# Athena Database
resource "aws_athena_database" "main" {
  name   = replace("${var.project_name}_database", "-", "_")
  bucket = aws_s3_bucket.athena_results.id

  properties = {
    classification = "csv"
  }
}

# Athena Workgroup (para executar queries)
resource "aws_athena_workgroup" "main" {
  name = "${var.project_name}-workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/results/"
    }
  }
}

# Tabela Athena para ler CSV do S3 Trusted
# Estrutura: ID, Title, Year, Age, Netflix, Hulu, Prime Video, Disney+, imdb_100, rottenTomatoes_100
resource "aws_athena_named_query" "create_csv_table" {
  name            = "${var.project_name}-create-csv-table"
  database        = aws_athena_database.main.name
  workgroup       = aws_athena_workgroup.main.name
  query           = <<-EOT
    CREATE EXTERNAL TABLE IF NOT EXISTS ${replace("${var.project_name}_tv_shows", "-", "_")} (
      id INT,
      title STRING,
      year INT,
      age STRING,
      netflix STRING,
      hulu STRING,
      prime_video STRING,
      disney_plus STRING,
      imdb_100 DOUBLE,
      rotten_tomatoes_100 INT
    )
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
    WITH SERDEPROPERTIES (
      'field.delim' = ','
    )
    STORED AS TEXTFILE
    LOCATION 's3://${aws_s3_bucket.trusted.bucket}/'
    TBLPROPERTIES ('skip.header.line.count'='1')
  EOT

  description = "Tabela para ler CSVs de TV Shows gerados pelo Lambda no S3 Trusted"
}

# Output para usar no Grafana
output "athena_database_name" {
  description = "Nome do database Athena"
  value       = aws_athena_database.main.name
}

output "athena_workgroup_name" {
  description = "Nome do workgroup Athena"
  value       = aws_athena_workgroup.main.name
}

output "athena_results_bucket" {
  description = "Bucket S3 para resultados do Athena"
  value       = aws_s3_bucket.athena_results.bucket
}

output "athena_setup_guide" {
  description = "Passos para configurar Athena no Grafana"
  value       = <<-EOT
    1. Execute a query nomeada no Athena: ${aws_athena_named_query.create_csv_table.name}
    2. No Grafana, vá em Connections → Athena
    3. Configure:
       - Database: ${aws_athena_database.main.name}
       - Workgroup: ${aws_athena_workgroup.main.name}
       - Region: ${var.aws_region}
    4. Teste a conexão
    5. Use queries como: 
       SELECT title, year, netflix, imdb_100, rotten_tomatoes_100 FROM ${replace("${var.project_name}_tv_shows", "-", "_")}
       WHERE netflix = 'SIM'
       ORDER BY imdb_100 DESC
  EOT
}
