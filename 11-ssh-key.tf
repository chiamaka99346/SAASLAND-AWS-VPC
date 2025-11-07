resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "terraform-generated-key"
  public_key = tls_private_key.this.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content              = tls_private_key.this.private_key_pem
  filename             = "${path.module}/terraform-generated-key.pem"
  file_permission      = "0600"
  directory_permission = "0700"
}

resource "aws_instance" "server" {
  ami                    = var.ami
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.this.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.instance.id]
}
