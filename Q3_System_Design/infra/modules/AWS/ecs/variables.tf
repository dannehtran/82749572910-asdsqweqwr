variable aws_ecr_image {
    type = string
    description = "The AWS ECR repo where the registry is contained"
}

variable iam_role_arn {
    type = string
    description = "The AWS Role to run ECS tasks"
}

variable aws_private_subnets {
}

variable security_groups {
}

variable lb_target_arn {
}

variable lb_listener {
    
}