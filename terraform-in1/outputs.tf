output "public_ip" {

  value = module.ec2.public_ip
}

output "queue_url" {

  value = module.sqs.queue_url
}