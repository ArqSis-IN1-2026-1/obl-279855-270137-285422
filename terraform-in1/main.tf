provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "IN1-OBL2"
      ManagedBy = "Terraform"
      Course    = "IN1-ORT-2026"
      Repo      = "ArqSis-IN1-2026-1/obl-279855-270137-285422"
    }
  }
}

module "bastion" {
  source = "./modules/bastion"

  ami              = var.ami_id
  instance_type    = var.bastion_instance_type
  key_name         = var.key_name
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

module "security_ec2" {
  source = "./modules/security"

  name          = "node-sg"
  port          = 3000
  bastion_sg_id = module.bastion.security_group_id
}

module "ec2" {
  source = "./modules/ec2"

  ami                   = var.ami_id
  instance_type         = var.instance_type
  key_name              = var.key_name
  security_group_id     = module.security_ec2.security_group_id
  instance_profile_name = module.ec2_iam.instance_profile_name
  name                  = "node-app"

  user_data = <<-EOF
    #!/bin/bash
    set -e
    exec > /var/log/userdata.log 2>&1

    # node y pm2
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
    npm install -g pm2

    # carpeta para los logs de la app (la lee el agente de cloudwatch)
    mkdir -p /var/log/node-app
    chown ubuntu:ubuntu /var/log/node-app
    chmod 755 /var/log/node-app

    # cloudwatch agent
    ARCH=$(dpkg --print-architecture)
    wget -q "https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/$${ARCH}/latest/amazon-cloudwatch-agent.deb"
    dpkg -i amazon-cloudwatch-agent.deb
    rm amazon-cloudwatch-agent.deb

    cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'CWCONFIG'
    {
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/var/log/node-app/out.log",
                "log_group_name": "/in1-obl2/node-app",
                "log_stream_name": "{instance_id}-stdout",
                "timezone": "UTC"
              },
              {
                "file_path": "/var/log/node-app/error.log",
                "log_group_name": "/in1-obl2/node-app",
                "log_stream_name": "{instance_id}-stderr",
                "timezone": "UTC"
              },
              {
                "file_path": "/var/log/syslog",
                "log_group_name": "/in1-obl2/system",
                "log_stream_name": "{instance_id}-syslog",
                "timezone": "UTC"
              },
              {
                "file_path": "/var/log/auth.log",
                "log_group_name": "/in1-obl2/system",
                "log_stream_name": "{instance_id}-auth",
                "timezone": "UTC"
              }
            ]
          }
        }
      },
      "metrics": {
        "namespace": "IN1-OBL2/EC2",
        "metrics_collected": {
          "cpu": {
            "measurement": ["cpu_usage_idle", "cpu_usage_user"],
            "metrics_collection_interval": 60
          },
          "mem": {
            "measurement": ["mem_used_percent"],
            "metrics_collection_interval": 60
          }
        }
      }
    }
    CWCONFIG

    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config -m ec2 -s \
      -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

    systemctl enable amazon-cloudwatch-agent
    systemctl start amazon-cloudwatch-agent

    # script para arrancar la app (se corre a mano despues de clonar el repo)
    cat > /home/ubuntu/start-app.sh << 'STARTSCRIPT'
    #!/bin/bash
    APP_DIR=""
    for dir in /home/ubuntu/obl-279855-270137-285422/node-app /home/ubuntu/node-app /home/ubuntu/app; do
      if [ -f "$dir/app.js" ]; then
        APP_DIR="$dir"
        break
      fi
    done

    if [ -z "$APP_DIR" ]; then
      echo "ERROR: No se encontró app.js. Clonar el repo primero."
      exit 1
    fi

    cd "$APP_DIR"
    QUEUE_URL="$${QUEUE_URL:-}" pm2 start app.js \
      --name node-app \
      --output /var/log/node-app/out.log \
      --error /var/log/node-app/error.log
    pm2 save
    STARTSCRIPT

    chmod +x /home/ubuntu/start-app.sh
    chown ubuntu:ubuntu /home/ubuntu/start-app.sh

    echo "setup listo"
  EOF
}

module "sqs" {
  source = "./modules/sqs"

  queue_name = var.sqs_queue_name
}

module "lambda" {
  source = "./modules/lambda"

  queue_arn = module.sqs.queue_arn
}

module "ec2_iam" {
  source = "./modules/ec2_iam"

  queue_arn = module.sqs.queue_arn
}

module "logging" {
  source = "./modules/logging"

  retention_days = var.log_retention_days
}
