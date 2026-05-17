# --- INSTÂNCIA FRONTEND (Carga dividida em 2) ---
resource "aws_instance" "frontend" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_frontend
  key_name               = var.key_name
  subnet_id              = aws_subnet.public[count.index % length(aws_subnet.public)].id
  vpc_security_group_ids = [aws_security_group.frontend.id]
  iam_instance_profile   = "LabInstanceProfile"

  user_data = templatefile("${path.module}/scripts/frontend_userdata.sh.tftpl", {
    backend_ip = aws_instance.backend_private.private_ip
  })

  tags = {
    Name = "${var.project_name}-app-${count.index + 1}"
    Role = "app"
  }
}

# --- INSTÂNCIA BACKEND ---
resource "aws_instance" "backend_private" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_frontend
  key_name               = var.key_name
  subnet_id              = aws_subnet.private_db[0].id
  vpc_security_group_ids = [aws_security_group.backend.id]
  iam_instance_profile   = "LabInstanceProfile"

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/scripts/backend_userdata.sh.tftpl", {
  bucket_deploy = aws_s3_bucket.deploy.bucket
})

  depends_on = [
    aws_nat_gateway.nat,
    aws_route_table_association.private_db
  ]

  tags = {
    Name = "${var.project_name}-backend-private"
    Role = "backend-private"
  }
}