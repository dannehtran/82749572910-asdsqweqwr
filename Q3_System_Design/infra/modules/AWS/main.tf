# Creates DYNAMODB table
module "dynamodb" {
    source = "./dynamodb"
    name = "short-my-url-tf"
}

# Creates, VPC, Routes, Route Tables, Subnets, NAT Gateways, Internet Gateways, EIPs for NAT Gateway
module "networking" {
    source = "./networking"
}

# Creates security_groups for ECS
module "sg" {
    source = "./sg"
    vpc_id = module.networking.vpc_id
}

# Creates IAM role for ECS
module "iam" {
    source = "./iam"
}

# Creates ALB for ECS
module "loadbalancer" {
    source = "./loadbalancer"
    aws_public_subnets = [module.networking.pub_1_subnet, module.networking.pub_2_subnet]
    security_groups = [module.sg.service_sg, module.sg.lb_sg]  
    vpc_id = module.networking.vpc_id  
}

# Creates ECS cluster
module "ecs" {
    source = "./ecs"
    aws_ecr_image = "139871335590.dkr.ecr.us-east-1.amazonaws.com/link-shortener-app:latest"
    iam_role_arn = module.iam.iam_arn
    aws_public_subnets = [module.networking.pub_1_subnet, module.networking.pub_2_subnet]
    security_groups = [module.sg.service_sg, module.sg.lb_sg]
    lb_target_arn = module.loadbalancer.lb_target_group_arn
    lb_listener = module.loadbalancer.lb_listener
    cloudwatch_lg = module.logging.log_group_name
}

# Creates autoscaling for ECS
module "autoscaling" {
    source = "./autoscaling"
    ecs_cluster_name = module.ecs.ecs_cluster_name
    ecs_service_name = module.ecs.ecs_service_name
}

# Cloudwatch logging

module "logging" {
    source = "./cloudwatch"
}