# Grupo de Seguridad 
resource "aws_security_group" "rds_sg" {
  name        = "rds-private-sg"
  description = "Permitir trafico entrante UNICAMENTE desde la EC2"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ec2_security_group_id] #  solo entra lo de EC2
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# instancia de base de datos 
resource "aws_db_instance" "this" {
  allocated_storage = 20
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro" # Tamaño pequeño, ideal para la entrega
  db_name           = "obligatorio_db"
  username          = "admin"
  password          = "PasswordSeguraIEN1"

  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  #  Bloquea el acceso desde el exterior de la VPC
  publicly_accessible = false

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

variable "ec2_security_group_id" {}

output "rds_endpoint" {
  value = aws_db_instance.this.endpoint
}