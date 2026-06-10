output "public_ip" {
  value = module.ec2.public_ip
}

output "queue_url" {
  value = module.sqs.queue_url
}

output "bastion_ip" {
  description = "IP pública del bastion"
  value       = module.bastion.public_ip
}

output "ssh_instrucciones" {
  description = "Conexión SSH via bastion"
  value       = <<-EOT

    === CONEXION SSH ===

    Bastion directo:
      ssh -i in1-key.pem ubuntu@${module.bastion.public_ip}

    Node-app via bastion:
      ssh -i in1-key.pem -J ubuntu@${module.bastion.public_ip} ubuntu@${module.ec2.private_ip}

    Verificar que SSH directo al node-app falla:
      ssh -i in1-key.pem ubuntu@${module.ec2.public_ip}
      (debe dar timeout)

  EOT
}
