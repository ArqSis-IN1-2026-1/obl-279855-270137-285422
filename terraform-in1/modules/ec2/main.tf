resource "aws_instance" "this" {

  ami = var.ami

  instance_type = var.instance_type

  vpc_security_group_ids = [
    var.security_group_id
  ]

  iam_instance_profile = var.instance_profile_name

  key_name = var.key_name

  user_data = <<-EOF
#!/bin/bash
echo "export S3_BUCKET_NAME=articles-images-obl2-735234196682" >> /etc/environment
EOF

  tags = {
    Name        = var.name
    Project     = "IEN1-Obl2"
    Environment = "Dev"
    ManagedBy   = "Terraform"
    Team        = "Grupo-IEN1"
  }
}