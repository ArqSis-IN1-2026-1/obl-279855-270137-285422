output "public_ip" {
  value = module.ec2.public_ip
}

output "queue_url" {
  value = module.sqs.queue_url
}
output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "images_bucket_name" {
  value = module.static_site.bucket_name
}

output "website_url" {
  value = module.static_site.website_url
}

output "bastion_ip" {
  description = "IP pública del bastion"
  value       = module.bastion.public_ip
}

output "ssh_instrucciones" {
  description = "Conexión SSH via bastion"
  value       = <<-EOT

    Bastion:
      ssh -i in1-key.pem ubuntu@${module.bastion.public_ip}

    Node-app via bastion:
      ssh -i in1-key.pem -J ubuntu@${module.bastion.public_ip} ubuntu@${module.ec2.private_ip}

    SSH directo al node-app (debe dar timeout):
      ssh -i in1-key.pem ubuntu@${module.ec2.public_ip}

  EOT
}
