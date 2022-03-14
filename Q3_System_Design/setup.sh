#! /bin/sh

region=$1
aws_account_id=$2
repo_name="link-shortener-app"

echo -e "\n Authenticating to AWS ECR with Docker \n"
aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $aws_account_id.dkr.ecr.$region.amazonaws.com

echo -e "\n Creating ECR Private Repository to push image \n"
aws ecr create-repository --repository-name $repo_name &> /dev/null

echo -e "\n Creating docker image to push to AWS ECR $aws_account_id.dkr.ecr.$region.amazonaws.com/$repo_name:latest \n"
cd build/link_shortner_service
docker buildx build . --platform=linux/amd64 -t $aws_account_id.dkr.ecr.$region.amazonaws.com/$repo_name:latest
cd ../../

echo -e "\n Pushing image to AWS ECR $aws_account_id.dkr.ecr.$region.amazonaws.com/$repo_name:latest \n"
docker push $aws_account_id.dkr.ecr.$region.amazonaws.com/$repo_name:latest

echo -e "\n Creating infrastructure using Terragrunt/Terraform \n"
cd infra/apps/link_shortner_service
terragrunt apply --auto-approve