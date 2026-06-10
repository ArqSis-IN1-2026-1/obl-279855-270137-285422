resource "aws_iam_role" "ec2_role" {
  name = "ec2-sqs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# EC2 puede enviar mensajes a SQS
resource "aws_iam_role_policy" "sqs_policy" {
  name = "ec2-sqs-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sqs:SendMessage"]
      Resource = var.queue_arn
    }]
  })
}

# EC2 puede escribir logs a CloudWatch (solo /in1-obl2/*)
resource "aws_iam_role_policy" "cloudwatch_policy" {
  name = "ec2-cloudwatch-write-only"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:*:*:log-group:/in1-obl2/*",
          "arn:aws:logs:*:*:log-group:/in1-obl2/*:log-stream:*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["cloudwatch:PutMetricData"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "this" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}
