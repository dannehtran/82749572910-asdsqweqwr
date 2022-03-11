
module "dynamodb" {
    source = "./dynamodb"
    name = "short-my-url-tf"
}

module "networking" {
    source = "./networking"
}

module "sg" {
    source = "./sg"
    vpc_id = module.networking.vpc_id
}

module "iam" {
    source = "./iam"
}

module "loadbalancer" {
    source = "./loadbalancer"
    aws_private_subnets = [module.networking.priv_1_subnet, module.networking.priv_2_subnet]
    security_groups = [module.sg.service_sg, module.sg.lb_sg]  
    vpc_id = module.networking.vpc_id  
}

module "ecs" {
    source = "./ecs"
    aws_ecr_image = "139871335590.dkr.ecr.us-east-1.amazonaws.com/link-shortener-app:latest"
    iam_role_arn = module.iam.iam_arn
    aws_private_subnets = [module.networking.priv_1_subnet, module.networking.priv_2_subnet]
    security_groups = [module.sg.service_sg, module.sg.lb_sg]
    lb_target_arn = module.loadbalancer.lb_target_group_arn
    lb_listener = module.loadbalancer.lb_listener
}

module "autoscaling" {
    source = "./autoscaling"
    ecs_cluster_name = module.ecs.ecs_cluster_name
    ecs_service_name = module.ecs.ecs_service_name
}