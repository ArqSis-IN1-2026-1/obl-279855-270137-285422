# Log groups para los logs de la app y del sistema.
# El de Lambda lo crea AWS solo, no hace falta declararlo.

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
