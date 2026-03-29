resource "aws_security_group" "alb" {
  name        = "${var.project_name}-sg-alb"
  description = "Permite HTTP da internet para o ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP de qualquer lugar"
    from_port        = var.porta_http
    to_port          = var.porta_http
    protocol         = "tcp"
    cidr_blocks      = var.ips_qualquer_lugar_v4
    ipv6_cidr_blocks = var.ips_qualquer_lugar_v6
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = var.ips_qualquer_lugar_v4
    ipv6_cidr_blocks = var.ips_qualquer_lugar_v6
  }

  tags = {
    Name = "${var.project_name}-sg-alb"
  }
}

resource "aws_security_group" "frontend" {
  name        = "${var.project_name}-sg-frontend"
  description = "Permite trafego HTTP do ALB e SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP vindo do ALB"
    from_port       = var.porta_http
    to_port         = var.porta_http
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description      = "SSH de qualquer lugar"
    from_port        = var.porta_ssh
    to_port          = var.porta_ssh
    protocol         = "tcp"
    cidr_blocks      = var.ips_qualquer_lugar_v4
    ipv6_cidr_blocks = var.ips_qualquer_lugar_v6
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = var.ips_qualquer_lugar_v4
    ipv6_cidr_blocks = var.ips_qualquer_lugar_v6
  }

  tags = {
    Name = "${var.project_name}-sg-frontend"
  }
}

resource "aws_security_group" "database" {
  name        = "${var.project_name}-sg-database"
  description = "Permite MySQL das instancias de aplicacao"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL vindo da camada de aplicacao"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = var.ips_qualquer_lugar_v4
    ipv6_cidr_blocks = var.ips_qualquer_lugar_v6
  }

  tags = {
    Name = "${var.project_name}-sg-database"
  }
}
