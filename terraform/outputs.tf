output "vpc_id" {
  description = "ID da VPC principal"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "DNS público do Application Load Balancer"
  value       = aws_lb.frontend.dns_name
}

output "frontend_instance_ids" {
  description = "IDs das instâncias de aplicação"
  value       = aws_instance.frontend[*].id
}

output "rds_endpoint" {
  description = "Endpoint do banco RDS MySQL"
  value       = aws_db_instance.mysql.endpoint
}

output "s3_raw_bucket_name" {
  description = "Nome do bucket S3 raw"
  value       = aws_s3_bucket.raw.bucket
}

output "s3_trusted_bucket_name" {
  description = "Nome do bucket S3 trusted"
  value       = aws_s3_bucket.trusted.bucket
}

output "s3_refined_bucket_name" {
  description = "Nome do bucket S3 refined"
  value       = aws_s3_bucket.refined.bucket
}
