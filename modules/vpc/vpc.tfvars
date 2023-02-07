project_name = [
  "three-tier-architecture"
]

environment = [
  "dev"
]

variable "vpc_id" [
  "VPC-Dev"
]

vpc_cidr = [
  "10.0.0.0/16"
]

public_subnet = {
  "eu-west-2a" : "10.0.0.0/24",
  "eu-west-2b" : "10.0.1.0/24",
  "eu-west-2c" : "10.0.2.0/24"
}

private_subnet = {
  "eu-west-2a" : "10.0.101.0/24",
  "eu-west-2b" : "10.0.102.0/24",
  "eu-west-2c" : "10.0.103.0/24"
}

database_subnet = {
  "eu-west-2a" : "10.0.201.0/24",
  "eu-west-2b" : "10.0.202.0/24",
  "eu-west-2c" : "10.0.203.0/24"
}

availability_zones = [
  "eu-west-2a",
  "eu-west-2b",
  "eu-west-2c"
]

cidr_block = [
  "0.0.0.0/0"
]

route_table_id = [
  "aws_route_table.main[each.key].id"
]

gateway_id = [
  "aws_internet_gateway.main.id"
]

subnet_id = [
  "aws_subnet.public_subnet.id"
]

load_balancer_type = [
  "application"
]

security_group_alb_sg = [
  "aws_security_group.alb_sg.id"
]

app_alb = [
  "app-alb"
]

alb_internal = [
  "false"
]

load_balancer_arn = [
  "aws_lb.main.arn"
]

alb_listener_port = [
  "80"
]

alb_listener_protocol = [
  "HTTP"
]

alb_listener_type = [
  "forward"
]

alb_target_group_arn = [
  "aws_lb_target_group.main.arn"
]

alb_target_group = [
  "alb-target-group"
]

 alb_target_group_port = [
  "80"
]

alb_target_group_protocol = [
  "HTTP"
]

app_autoscaling_group = [
  "app-autoscaling-group"
]

desired_capacity = [
  "1"
]

max_size = [
  "1"
]

min_size = [
  "1"
]

database_subnet_group = [
  "database-subnet-group"
]

alb_app_security_group = [
  "alb-app-security-group"
]

app_instance_security_group = [
  "app-instance-security-group"
]

db_security_group = [
  "db-security-group"
]

