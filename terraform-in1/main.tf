provider "aws" {

  region = "us-east-1"
}

module "security_ec2" {

  source = "./modules/security"

  name = "node-sg"

  port = 3000
}

module "ec2" {

  source = "./modules/ec2"

  ami = "ami-091138d0f0d41ff90"

  instance_type = "t3.micro"

  key_name = "in1-key"

  security_group_id = module.security_ec2.security_group_id

  name = "node-app"
}

module "sqs" {

  source = "./modules/sqs"

  queue_name = "articles-queue"
}

module "lambda" {

  source = "./modules/lambda"

  queue_arn = module.sqs.queue_arn
}