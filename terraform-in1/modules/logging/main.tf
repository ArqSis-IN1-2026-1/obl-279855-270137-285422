# Log groups de CloudWatch — logs centralizados e independientes de los servidores.
# Lambda crea su propio log group automáticamente; no lo gestionamos acá.

resource "aws_cloudwatch_log_group" "node_app" {
  name              = "/in1-obl2/node-app"
  retention_in_days = var.retention_days

  tags = {
    Name    = "node-app-logs"
    Service = "node-app"
  }
}

resource "aws_cloudwatch_log_group" "system" {
  name              = "/in1-obl2/system"
  retention_in_days = var.retention_days

  tags = {
    Name    = "system-logs"
    Service = "system"
  }
}
