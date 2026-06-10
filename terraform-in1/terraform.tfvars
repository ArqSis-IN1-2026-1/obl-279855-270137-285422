# ============================================================
# Archivo de configuración principal
# Para escalar o cambiar la infra, solo modificar estos valores.
# No es necesario tocar main.tf ni los módulos.
# ============================================================

aws_region         = "us-east-1"
ami_id             = "ami-091138d0f0d41ff90" # Ubuntu 26.04 LTS x86_64 us-east-1
instance_type      = "t3.micro"              # Cambiar a t3.small/t3.medium si se necesita más
key_name           = "in1-key"
sqs_queue_name     = "articles-queue"
allowed_ssh_cidr   = "0.0.0.0/0" # Para producción: poner IP del developer "X.X.X.X/32"
log_retention_days = 14
