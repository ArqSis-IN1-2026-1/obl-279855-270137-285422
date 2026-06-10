variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI Ubuntu para las instancias EC2"
  type        = string
  default     = "ami-091138d0f0d41ff90"

  validation {
    condition     = can(regex("^ami-[a-f0-9]{8,17}$", var.ami_id))
    error_message = "Formato de AMI inválido."
  }
}

variable "instance_type" {
  description = "Tipo de instancia para node-app"
  type        = string
  default     = "t3.micro"
}

variable "bastion_instance_type" {
  description = "Tipo de instancia para el bastion"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key Pair de AWS para SSH"
  type        = string
  default     = "in1-key"

  validation {
    condition     = length(var.key_name) > 0
    error_message = "key_name no puede estar vacío."
  }
}

variable "sqs_queue_name" {
  description = "Nombre de la cola SQS"
  type        = string
  default     = "articles-queue"
}

variable "allowed_ssh_cidr" {
  description = "CIDR permitido para SSH al bastion"
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "CIDR inválido."
  }
}

variable "log_retention_days" {
  description = "Retención de logs en CloudWatch (días)"
  type        = number
  default     = 14

  validation {
    condition     = var.log_retention_days >= 1 && var.log_retention_days <= 365
    error_message = "Debe estar entre 1 y 365."
  }
}
