# Para escalar o cambiar la infra alcanza con editar este archivo,
# no hace falta tocar main.tf ni los módulos.

aws_region         = "us-east-1"
ami_id             = "ami-091138d0f0d41ff90" # Ubuntu 26.04 LTS x86_64
instance_type      = "t3.micro"              # subir a t3.small si hace falta
bastion_instance_type = "t3.micro"
key_name           = "in1-key"
sqs_queue_name     = "articles-queue"
allowed_ssh_cidr   = "0.0.0.0/0" # en producción iría la IP del developer
log_retention_days = 14
