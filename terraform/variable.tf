variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefixo para nomear recursos"
  type        = string
  default     = "arquitetura-encanto"
}

variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.0.0.0/25"
}

variable "public_subnet_cidrs" {
  description = "Sub-redes públicas para ALB/EC2"
  type        = list(string)
  default     = ["10.0.0.0/27", "10.0.0.64/27"]
}

variable "private_db_subnet_cidrs" {
  description = "Sub-redes privadas de banco"
  type        = list(string)
  default     = ["10.0.0.32/27", "10.0.0.96/27"]
}

variable "porta_ssh" {
  description = "Porta para acesso SSH"
  type        = number
  default     = 22
}

variable "porta_http" {
  description = "Porta HTTP"
  type        = number
  default     = 80
}

variable "ips_qualquer_lugar_v4" {
  description = "CIDR IPv4 de qualquer lugar"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ips_qualquer_lugar_v6" {
  description = "CIDR IPv6 de qualquer lugar"
  type        = list(string)
  default     = ["::/0"]
}

variable "instance_type_frontend" {
  description = "Tipo da instância EC2 front-end"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nome do par de chaves EC2 para SSH"
  type        = string
  default     = null
}

variable "db_name" {
  description = "Nome do banco MySQL"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Usuário do banco MySQL"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Senha do banco MySQL"
  type        = string
  default     = "Encanto2026"
  sensitive   = true
}

variable "db_instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro"
}
