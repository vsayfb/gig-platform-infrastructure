resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "ALB - allows inbound HTTP/HTTPS from the internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
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

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
  })
}

resource "aws_security_group_rule" "alb_egress_to_private_services" {
  description              = "App traffic to Core/Chat"
  type                     = "egress"
  from_port                = var.app_port_range.from
  to_port                  = var.app_port_range.to
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.private_services.id
}

resource "aws_security_group" "nat" {
  name        = "${local.name_prefix}-nat-sg"
  description = "NAT instance - forwards private services outbound traffic, allows SSH from admin IP only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "All traffic from private application services"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    # security_groups = [aws_security_group.private_services.id]
  }

  ingress {
    description = "SSH from admin IP for tunnelling into the private subnet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    description = "Unrestricted outbound - forwards traffic to the internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-sg"
  })
}

resource "aws_security_group" "private_services" {
  name        = "${local.name_prefix}-private-services-sg"
  description = "Core/Chat/Categorization worker - reachable from ALB and via SSH tunnel through NAT instance only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "App traffic from ALB"
    from_port       = var.app_port_range.from
    to_port         = var.app_port_range.to
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "SSH tunnelled in from the NAT instance"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.nat.id]
  }

  egress {
    description = "Postgres to RDS"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # security_groups = [aws_security_group.rds.id]
  }

  egress {
    description = "HTTPS out - SQS API, Groq, MongoDB Atlas, Grafana Cloud"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-services-sg"
  })
}

resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-rds-sg"
  description = "RDS Postgres - reachable only from Core/Chat/Worker"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Postgres from Core/Chat/Worker"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # security_groups = [aws_security_group.private_services.id]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rds-sg"
  })
}
