/*
  Security groups for HAProxy and application server.
  These were moved out of `08-ec2.tf` for separation of concerns.
*/

resource "aws_security_group" "sg_haproxy" {
  name        = "${var.main-vpc}-sg-haproxy"
  description = "Security group for HAProxy instance"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    description = "HTTP from ALB / internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH for admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.main-vpc}-sg-haproxy" }
}

resource "aws_security_group" "sg_server" {
  name        = "${var.main-vpc}-sg-server"
  description = "Security group for application server"
  vpc_id      = aws_vpc.main-vpc.id

  # Allow traffic from HAProxy (instance security group reference)
  ingress {
    description     = "Allow app traffic from HAProxy"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_haproxy.id]
  }

  ingress {
    description = "SSH for admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.main-vpc}-sg-server" }
}
