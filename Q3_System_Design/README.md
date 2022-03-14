## Requirements
Must install all of the following tools:
- `terraform`
- `terragrunt`
- `AWS SDK CLI`
    - `default` profile set
- `docker`
- `python3`
- `pip3`

## How to install infrastructure
- Make sure you have set up your `aws configure`
- Make sure you install all of the required softwares above
- Run the `./setup.sh` script by passing the region you want it deployed on and the `AWS_ACCOUNT_ID`
    - Example: `./setup.sh us-east-1 1234567890`

## What does the script do?
- The script will do the following:
    - Logins to docker and authenticates with AWS ECR
    - Build docker image from `../apps` and push the ECR
    - Run `terragrunt` and build the infrastructure
        - The following will be deployed:
            1. 1 x VPC
            2. 1 x ALB
            3. 2 x Public subnets (in two AZ's)
            4. 1 x Internet Gateway
            5. 2 x Routes
            6. 1 x Route Table
            7. 1 x IAM Role
            8. 2 x Security Groups (For LB and ECS Service)
            9. 1 x ECS Cluster
            10. 1 x Autoscaling for ECS Cluster
            11. 1 x Cloudwatch Logging
            12. 1 x DynamoDB Table (For apps DB)

## Brief Explanation of System Implementation
This system implementation focuses on using AWS modern technologies to scale and make docker containers highly available and scalable using ECS Fargate. Using ECS Fargate as our docker orchestration tool, we do not need to rely on any code changes or manual interventions when we need to scale nodes as it will automatically provision extra nodes when there is high load or demand.

We have an ALB to direct traffic from the internet to our docker containers using security groups that only allow connections betweent he loadbalancer and the ECS cluster. This allows traffic between the service and the loadbalancer and nothing else.

## Assumptions
- This system implementation is assuming we are only deploying one service (if we had multiple we would move to kubernetes)
- We are assuming that we will only use docker images as our packaging and deployment process
- Cost is not an issue as we priortize scalability and high availabilty


## Limitations
- Costly due to ECS is managing our infrastructure for nodes and we do not provision them on our side
- We do not manage the EC2 instance type as Fargate does the provisioning for us
- Only scales when CPU or Memory reaches 70% of its capacity
