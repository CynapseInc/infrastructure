resource "aws_instance" "frontend" {
  count                  = length(aws_subnet.public)
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type_frontend
  key_name               = var.key_name
  subnet_id              = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.frontend.id]
  user_data              = file("${path.module}/scripts/instalar_java.sh")

  tags = {
    Name = "${var.project_name}-app-${count.index + 1}"
    Role = "app"
  }
}
