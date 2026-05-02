# --- INSTÂNCIA FRONTEND ---

resource "aws_instance" "frontend" {
  count                  = 1
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type_frontend
  key_name               = var.key_name
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.frontend.id]

  # Usando a string direta para o perfil do laboratório
  iam_instance_profile = "LabInstanceProfile"

  user_data = templatefile("${path.module}/scripts/frontend_userdata.sh.tftpl", {
    deploy_bucket = aws_s3_bucket.deploy.bucket
    aws_region    = var.aws_region
  })

  tags = {
    Name = "frontend"
    Role = "app"
  }

  # REMOVIDO: aws_iam_instance_profile.ec2_profile daqui
  depends_on = [
    aws_s3_object.frontend_dist
  ]
}

# --- INSTÂNCIA BACKEND ---

resource "aws_instance" "backend_private" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type_frontend
  key_name               = var.key_name
  subnet_id              = aws_subnet.private_db[0].id
  vpc_security_group_ids = [aws_security_group.backend.id]
  iam_instance_profile   = "LabInstanceProfile"

  # ADICIONE ESTE BLOCO AQUI:
  root_block_device {
    volume_size           = 20    # 20GB costuma ser o ideal para rodar Docker com folga
    volume_type           = "gp3" # Tipo de volume mais moderno e performático
    delete_on_termination = true  # Garante que o disco suma se você destruir a instância
  }

  user_data = templatefile("${path.module}/scripts/backend_userdata.sh.tftpl", {
    deploy_bucket = aws_s3_bucket.deploy.bucket
    jar_key       = aws_s3_object.backend_jar.key
    backend_port  = var.backend_port
  })

  tags = {
    Name = "${var.project_name}-backend-private"
    Role = "backend-private"
  }

  depends_on = [
    aws_s3_object.backend_jar,
    aws_s3_object.docker_compose,
    aws_s3_object.whatsapp_env,
    aws_s3_object.gerar_inserts_py
  ]
}