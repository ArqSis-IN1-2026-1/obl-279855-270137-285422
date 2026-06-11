resource "aws_sqs_queue" "this" {
  name = var.queue_name

  tags = {
    Project     = "IEN1-Obl2"
    Environment = "Dev"
    ManagedBy   = "Terraform"
    Team        = "Grupo-IEN1"
  }
}
