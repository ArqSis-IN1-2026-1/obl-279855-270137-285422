variable "queue_arn" {}

variable "discord_webhook_url" {
  description = "URL del webhook de Discord usado por la función Lambda"
  type        = string
  default     = ""
}
