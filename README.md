# OBL2 — Infraestructura en la Nube 1

**Grupo:** 279855 - 270137 - 285422

## Prerequisitos

- Terraform >= 1.5
- AWS CLI configurado con credenciales (`aws configure`)
- Key Pair `in1-key` creado en AWS (región us-east-1)
- Archivo `lambda.zip` en `terraform-in1/` (contiene el código de la función Lambda)
- Archivo node-app.zip en la raíz del proyecto (contiene la aplicación Node.js)

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

Conexión al bastion:
```bash
ssh -i in1-key.pem ubuntu@<BASTION_IP>
```
Conexión al node-app desde el bastion:
```bash
ssh -i ~/in1-key.pem ubuntu@<NODE_PRIVATE_IP>
```

Las IPs aparecen en los outputs de `terraform apply`.

### Verificación del despliegue
Una vez finalizado terraform apply, esperar aproximadamente 2 o 3 minutos para que termine la ejecución del script de inicialización de la EC2.

### Verificar PM2
Dentro de la instancia node-app ejecutar:
pm2 list

El proceso node-app debe aparecer con estado online.

### Acceso desde navegador
La aplicación queda disponible en:

http://<NODE-APP_PUBLIC_IP>:3000

## Integración SQS + Lambda
Acceder a:
http://<NODE_PUBLIC_IP>:3000/generate

Esto envía un mensaje a SQS y dispara la ejecución de la función Lambda.

Las ejecuciones pueden verificarse desde CloudWatch Logs.

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
