##########################
# Grafana EC2 + IAM + SG
##########################

// Security Group para Grafana
resource "aws_security_group" "grafana" {
  name        = "${var.project_name}-sg-grafana"
  description = "Permite acesso ao Grafana (porta 3000) e SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Grafana (HTTP) de qualquer lugar (ajuste se necessario)"
    from_port        = 3000
    to_port          = 3000
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
    Name = "${var.project_name}-sg-grafana"
  }
}

// Reutiliza o `LabInstanceProfile` existente em ambientes acadêmicos
data "aws_iam_instance_profile" "lab" {
  name = "LabInstanceProfile"
}

// Instância EC2 para Grafana
resource "aws_instance" "grafana" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_frontend
  key_name               = var.key_name
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.grafana.id]
  iam_instance_profile   = data.aws_iam_instance_profile.lab.name

  user_data = templatefile("${path.module}/scripts/grafana_userdata.sh.tftpl", {})

  tags = {
    Name = "${var.project_name}-grafana"
    Role = "grafana"
  }
}

// Output com IP público do Grafana
output "grafana_public_ip" {
  value       = aws_instance.grafana.public_ip
  description = "IP público do servidor Grafana"
}
