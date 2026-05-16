output "vpc_id" {
  description = "ID da VPC principal"
  value       = aws_vpc.main.id
}

output "frontend_public_dns" {
  description = "DNS publico da EC2 frontend"
  value       = aws_instance.frontend[0].public_dns
}

output "frontend_public_ip" {
  description = "IP publico da EC2 frontend"
  value       = aws_instance.frontend[0].public_ip
}

output "frontend_instance_ids" {
  description = "IDs das instancias de aplicacao"
  value       = aws_instance.frontend[*].id
}

output "backend_private_instance_id" {
  description = "ID da instancia privada do backend"
  value       = aws_instance.backend_private.id
}

output "backend_private_ip" {
  description = "IP privado da instancia do backend"
  value       = aws_instance.backend_private.private_ip
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

output "s3_deploy_bucket_name" {
  description = "Nome do bucket S3 de artefatos FE/BE"
  value       = aws_s3_bucket.deploy.bucket
}

output "alb_dns_name" {
  description = "DNS do Application Load Balancer"
  value       = aws_lb.frontend.dns_name
}

output "grafana_access_url" {
  description = "URL para acessar o Grafana (aguarde ~2 min para inicializar)"
  value       = "http://${aws_lb.frontend.dns_name}:3000"
}

output "grafana_direct_url" {
  description = "URL direta para o Grafana (sem ALB)"
  value       = "http://${aws_instance.grafana.public_ip}:3000"
}

output "grafana_instance_id" {
  description = "ID da instância Grafana"
  value       = aws_instance.grafana.id
}

output "grafana_instance_ip" {
  description = "IP público da instância Grafana"
  value       = aws_instance.grafana.public_ip
}
