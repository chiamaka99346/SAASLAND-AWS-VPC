# /*
#   Application Load Balancer resources moved from 08-ec2.tf into this file.
#   Contains:
#    - ALB security group
#    - ALB
#    - Target group
#    - Listener
#    - Target group attachment for the haproxy instance
#    - ALB DNS output
# */

# resource "aws_security_group" "sg_alb" {
#   name        = "${var.main-vpc}-sg-alb"
#   description = "Security group for ALB"
#   vpc_id      = aws_vpc.main-vpc.id

#   ingress {
#     description = "HTTP"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "HTTPS"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = { Name = "${var.main-vpc}-sg-alb" }
# }

# resource "aws_lb" "app_alb" {
#   name               = "${var.main-vpc}-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.sg_alb.id]
#   subnets            = aws_subnet.public-subnet[*].id

#   tags = { Name = "${var.main-vpc}-alb" }
# }

# resource "aws_lb_target_group" "app_tg" {
#   name     = "${var.main-vpc}-tg"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.main-vpc.id

#   health_check {
#     path                = "/"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }
# }

# resource "aws_lb_listener" "http_listener" {
#   load_balancer_arn = aws_lb.app_alb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app_tg.arn
#   }
# }

# # Register HAProxy instance as target so ALB forwards to it
# resource "aws_lb_target_group_attachment" "haproxy_attach" {
#   target_group_arn = aws_lb_target_group.app_tg.arn
#   target_id        = aws_instance.haproxy.id
#   port             = 80
# }

# output "alb_dns_name" {
#   description = "ALB DNS name"
#   value       = aws_lb.app_alb.dns_name
# }
