# 1. Nginx Security Group (The Gatekeeper)
resource "aws_security_group" "nginx-sg" {
  name   = "${var.env_prefix}-nginx-sg"
  vpc_id = var.vpc_id

  # Allow SSH from YOUR IP ONLY
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Backend Security Group (The Private Room)
resource "aws_security_group" "backend-sg" {
  name   = "${var.env_prefix}-backend-sg"
  vpc_id = var.vpc_id

  # Allow SSH from YOUR IP ONLY
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # ONLY allow HTTP traffic if it comes from the Nginx Security Group
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.nginx-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}