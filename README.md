# OBL2 — Infraestructura en la Nube 1

**Grupo:** 279855 - 270137 - 285422

## Prerequisitos

- Terraform >= 1.5
- AWS CLI configurado con credenciales (`aws configure`)
- Key Pair `in1-key` creado en AWS (región us-east-1)
- Archivo `lambda.zip` en `terraform-in1/` (contiene el código de la función Lambda)

## Despliegue

```bash
cd terraform-in1

# Inicializar providers y módulos
terraform init

# Validar sintaxis
terraform validate

# Ver qué se va a crear
terraform plan

# Crear toda la infraestructura
terraform apply
```

Terraform muestra al final las IPs y las instrucciones de conexión SSH.

## Configuración

Para cambiar instancias, región, o parámetros, editar **solo** `terraform.tfvars`:

```hcl
instance_type = "t3.small"       # Escalar el servidor
allowed_ssh_cidr = "190.64.X.X/32"  # Restringir SSH a una IP
log_retention_days = 30          # Más retención de logs
```

## Conexión SSH (via Bastion)

```bash
# Al bastion:
ssh -i in1-key.pem ubuntu@<BASTION_IP>

# Al node-app (via bastion con ProxyJump):
ssh -i in1-key.pem -J ubuntu@<BASTION_IP> ubuntu@<NODE_PRIVATE_IP>
```

Las IPs aparecen en los outputs de `terraform apply`.

## Arrancar la aplicación

Después del deploy, conectarse al node-app via bastion y correr:

```bash
git clone https://github.com/ArqSis-IN1-2026-1/obl-279855-270137-285422.git
cd obl-279855-270137-285422/node-app
npm install
bash ~/start-app.sh
```

La app queda en `http://<NODE_PUBLIC_IP>:3000`

## Destruir la infraestructura

```bash
terraform destroy
```

## Estructura de módulos

| Módulo | Requisito | Qué hace |
|--------|-----------|----------|
| `ec2` | 1, 2 | Instancia del servidor node-app |
| `security` | 8 | Security Groups (puertos 3000 y 22) |
| `sqs` | 3 | Cola de mensajes para artículos |
| `lambda` | 3 | Función serverless que procesa artículos |
| `ec2_iam` | 8 | Roles y políticas IAM para EC2 |
| `bastion` | 9 | Bastion host para SSH sin exposición directa |
| `logging` | 7 | Log groups de CloudWatch |
