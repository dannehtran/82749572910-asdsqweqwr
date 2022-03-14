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
