resource "aws_instance" "this" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.security_group_id]
  iam_instance_profile        = var.instance_profile_name
  user_data                   = var.user_data
  user_data_replace_on_change = true

  tags = {
    Name        = var.name
    Project     = "IEN1-Obl2"
    Environment = "Dev"
    ManagedBy   = "Terraform"
    Team        = "Grupo-IEN1"
  }
}
