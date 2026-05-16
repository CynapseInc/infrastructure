# Security Group para o ALB
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-sg-alb"
  description = "Security Group para Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.ips_qualquer_lugar_v4
    ipv6_cidr_blocks = var.ips_qualquer_lugar_v6
  }

  ingress {
    description      = "Grafana"
    from_port        = 3000
    to_port          = 3000
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
    description      = "HTTP de qualquer lugar"
    from_port        = var.porta_http
    to_port          = var.porta_http
    protocol         = "tcp"
    cidr_blocks      = var.ips_qualquer_lugar_v4
    ipv6_cidr_blocks = var.ips_qualquer_lugar_v6
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

resource "aws_security_group" "backend" {
  name        = "${var.project_name}-sg-backend"
  description = "Permite trafego da camada frontend para API privada"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "API vindo da camada frontend"
    from_port       = var.backend_port
    to_port         = var.backend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }

  ingress {
    description     = "SSH vindo da camada frontend"
    from_port       = var.porta_ssh
    to_port         = var.porta_ssh
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
    Name = "${var.project_name}-sg-backend"
  }
}

resource "aws_security_group" "grafana" {
  name        = "${var.project_name}-sg-grafana"
  description = "Security Group para Grafana - porta 3000"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP para Grafana"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = var.ips_qualquer_lugar_v4
    ipv6_cidr_blocks = var.ips_qualquer_lugar_v6
  }

  ingress {
    description      = "SSH"
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
    Name = "${var.project_name}-sg-grafana"
  }
}

