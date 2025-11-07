data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-*"] # allows gp2/gp3
  }
}

# App server (private subnet)
resource "aws_instance" "server" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private_subnet[0].id   # was private-subnet
  vpc_security_group_ids      = [aws_security_group.sg_server.id]
  associate_public_ip_address = false
  key_name                    = aws_key_pair.this.key_name        # use the generated key

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              echo "<html><body><h1>App server</h1></body></html>" > /var/www/html/index.html
              systemctl enable httpd
              systemctl start httpd
              EOF

  tags = {
    Name = "${var.main_vpc}-server"                                # was main-vpc
  }
}

# HAProxy instance (public subnet)
resource "aws_instance" "haproxy" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet[0].id     # was public-subnet
  vpc_security_group_ids      = [aws_security_group.sg_haproxy.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.this.key_name         # same key

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y haproxy
              cat > /etc/haproxy/haproxy.cfg <<CFG
              global
                  daemon
                  maxconn 256
              defaults
                  mode http
                  timeout connect 5000ms
                  timeout client 50000ms
                  timeout server 50000ms
              frontend http_front
                  bind *:80
                  default_backend http_back
              backend http_back
                  server app1 ${aws_instance.server.private_ip}:80 check
              CFG
              systemctl enable haproxy
              systemctl restart haproxy
              EOF

  tags = {
    Name = "${var.main_vpc}-haproxy"
  }
}

