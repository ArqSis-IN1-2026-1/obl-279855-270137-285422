variable "name" {}
variable "port" {}

variable "bastion_sg_id" {
  description = "SG del bastion — único origen permitido para SSH"
  type        = string
}
