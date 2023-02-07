locals {
  required_tags = {
    project     = "three-tier-architecture"
    environment = "dev"
  }

  ingress_rules = [{
    port        = 8080
    description = "Allow HTTP access"
    },
    {
      port        = 443
      description = "Allow HTTPS access"
    },
    {
      port        = 22
      description = "Allow SSH access"
  }]

  egress_rules = [{
    port        = 0
    description = "All all Egress traffic"
  }]

  rds_ingress_rules = [{
    port            = 3306
    description     = "Allow MySQL access"
  }]
}

################################################################################
# VPC
################################################################################
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge(local.tags, { Name = "VPC" })
}

#Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  for_each                = var.public_subnet
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = "true" #makes this a public subnet

  tags = merge(local.required_tags, { Name = "Public-Subnet" })
}

#Private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  for_each          = var.private_subnet
  availability_zone = each.key
  cidr_block        = each.value

  tags = merge(local.required_tags, { Name = "Private-Subnet" })
}

#Database Subnet
resource "aws_subnet" "database_subnet" {
  vpc_id            = aws_vpc.vpc.id
  for_each          = var.database_subnet
  availability_zone = each.key
  cidr_block        = each.value

  tags = merge(local.tags, { Name = "Database-Subnet" })
}

#Internet Gateway for the Public Subnet
resource "aws_internet_gateway" "main" {
  vpc_id = var.vpc_id

  tags = merge(local.required_tags, { Name = "Internet-Gateway" })
}

#Route Table for the Internet Gateway / Public Subnet
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.vpc.id
  for_each = var.public_subnet

  route {
    cidr_block             = var.cidr_block
    gateway_id             = var.gateway_id 
  }

  tags = merge(local.tags, { Name = "Public-Route-Table" })
}

#Route table associations - Public
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.public_subnet[each.key].id
  for_each       = var.public_subnet
  route_table_id = var.route_table_id 
}

#Application Load Balancer
resource "aws_lb" "main" {
  name               = var.app_alb
  internal           = var.alb_internal
  load_balancer_type = var.load_balancer_type
  security_groups    = [var.security_group_alb_sg]
  subnets            = [for value in aws_subnet.public_subnet : value.id] #######NEEDS REVIEWING

  tags = merge(local.required_tags, { Name = "Application-ALB" })
}

#Application Load Balancer Listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = var.load_balancer_arn
  port              = var.alb_listener_port
  protocol          = var.alb_listener_protocol

  default_action {
    type             = var.alb_listener_type
    target_group_arn = var.alb_target_group_arn
  }
}

#Application Load Balancer Target Group
resource "aws_lb_target_group" "main" {
  name     = var.alb_target_group
  port     = var.alb_target_group_port
  protocol = var.alb_target_group_protocol
  vpc_id   = var.vpc_id

  health_check {
    port     = var.alb_target_group_port
    protocol = var.alb_target_group_protocol
  }
}

#Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                = var.app_autoscaling_group
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  target_group_arns   = [aws_lb_target_group.main.arn]
  vpc_zone_identifier = [for value in aws_subnet.public_subnet : value.id]##### NEEDS REVIEWING

  launch_template {
    id      = var.id_app
    version = "$Latest"
  }
}

# Database Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = var.database_subnet_group
  subnet_ids = [for value in aws_subnet.database_subnet : value.id]

  tags = merge(local.required_tags, { Name = "Database-Subnet-Group" })
}

################################################################################
# ALB - Security Group
################################################################################
resource "aws_security_group" "alb_sg" {
  name        = var.alb_app_security_group
  description = "Security Group for Application Load Balancer"
  vpc_id      = var.vpc_id

    dynamic "ingress" {
    for_each = local.ingress_rules

    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = [var.cidr_block]

    }
  }

  dynamic "egress" {
    for_each = local.egress_rules

    content {
      description = egress.value.description
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = "tcp"
      cidr_blocks = [var.cidr_block]

    }
  }

  tags = merge(local.required_tags, { Name = "ALB-Security-Group" })
}

################################################################################
# EC2 - Security Group 
################################################################################
resource "aws_security_group" "app_sg" {
  name        = var.app_security_group
  description = "Security Group for EC2 Host"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.ingress_rules

    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = [var.cidr_block]

    }
  }

  dynamic "egress" {
    for_each = local.egress_rules

    content {
      description = egress.value.description
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = "tcp"
      cidr_blocks = [var.cidr_block]

    }
  }

  tags = merge(local.required_tags, { Name = "EC2-Security-Group" })
}

################################################################################
# RDS - Security Group
################################################################################

resource "aws_security_group" "db_sg" {
  name        = var.db_security_group
  description = "Security Group for RDS MySQL Database"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.ingress_rules

    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      security_groups = [aws_security_group.app_instance_sg.id]

    }
  }

  dynamic "egress" {
    for_each = local.egress_rules

    content {
      description = egress.value.description
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = "tcp"
      cidr_blocks = [var.cidr_block]

    }
  }

  tags = merge(local.required_tags, { Name = "RDS-Security-Group" })
}