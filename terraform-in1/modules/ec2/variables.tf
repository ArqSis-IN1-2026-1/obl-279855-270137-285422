variable "ami" {}
variable "instance_type" {}
variable "security_group_id" {}
variable "name" {}
variable "instance_profile_name" {}
variable "key_name" {}

variable "user_data" {
  type    = string
  default = null
}
