resource "aws_instance" "this" {

  ami = var.ami

  instance_type = var.instance_type

  key_name = var.key_name

  vpc_security_group_ids = [
    var.security_group_id
  ]

  iam_instance_profile = var.instance_profile_name

  tags = {
    Name = var.name
  }
}