output "node_app_log_group" {
  value = aws_cloudwatch_log_group.node_app.name
}
