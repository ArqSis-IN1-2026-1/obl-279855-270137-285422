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

  security_group_id = module.security_ec2.security_group_id

  instance_profile_name = module.ec2_iam.instance_profile_name

  name = "node-app"
}

module "sqs" {

  source = "./modules/sqs"

  queue_name = "articles-queue"
}


module "ec2_iam" {

  source = "./modules/ec2_iam"

  queue_arn = module.sqs.queue_arn
}


module "lambda" {
  source = "./modules/lambda"
  queue_arn = module.sqs.queue_arn
  
  discord_webhook_url = "https://discord.com/api/webhooks/1496828429767544852/rz6gJEH-Yg9OwGIyLfy45SjW32lcXUYlyLM3SaTKF272GstA3ULWqPeoXZ3LnBpfrje_"
}

module "rds" {
  source                = "./modules/rds"
  ec2_security_group_id = module.security_ec2.security_group_id 
}
