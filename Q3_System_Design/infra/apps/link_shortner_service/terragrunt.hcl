terraform {

    source = "../../modules//AWS"
  }
  
  inputs = {
    aws_ecr_repo = "139871335590.dkr.ecr.us-east-1.amazonaws.com/link-shortener-app:latest"
  }