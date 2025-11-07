/*
  Creates two EC2 instances (app server + haproxy) and an Application Load Balancer.
  - server instance placed in the first private subnet
  - haproxy instance placed in the first public subnet (has public ip)
  - ALB in public subnets forwards to the haproxy instance

  Assumptions:
  - There are existing `aws_subnet.public-subnet` and `aws_subnet.private-subnet` resources defined elsewhere (this repo provides them).
  - A key pair name is provided in `var.key_name` and the key exists in the AWS account.
  - For AMI we fetch the latest Amazon Linux 2 in the configured region.
*/

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

/* HAProxy and server security groups moved to 10-security-groups.tf */

/* ALB security group moved to 09-alb.tf */

# App server (private subnet)
resource "aws_instance" "server" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private-subnet[0].id
  vpc_security_group_ids      = [aws_security_group.sg_server.id]
  associate_public_ip_address = false
  

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              cat > /var/www/html/index.html <<HTML
              <html><body><h1>App server</h1></body></html>
              HTML
              systemctl enable httpd
              systemctl start httpd
              EOF

  tags = {
    Name = "${var.main-vpc}-server"
  }
}

# HAProxy instance (public subnet)
resource "aws_instance" "haproxy" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public-subnet[0].id
  vpc_security_group_ids      = [aws_security_group.sg_haproxy.id]
  associate_public_ip_address = true
  

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
    Name = "${var.main-vpc}-haproxy"
  }
}

/* instance outputs moved to outputs.tf */
