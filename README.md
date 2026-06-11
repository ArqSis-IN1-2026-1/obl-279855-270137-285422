# Proyecto IEN1 - OBL 2

Este repositorio contiene una solución completa con infraestructura en AWS y una aplicación Node.js para publicar y visualizar artículos con imágenes.

## Resumen

La arquitectura quedó dividida en tres partes:

1. **Sitio institucional estático**: se publica en un bucket S3 desde Terraform y sirve como cara pública del proyecto.
2. **Aplicación Node.js**: corre en una EC2, guarda artículos en RDS MySQL, sube imágenes a S3 y envía mensajes a SQS.
3. **Servicios AWS de soporte**: EC2, RDS, SQS y Lambda para el flujo asincrónico.

## Estructura del repositorio

- `node-app/`: aplicación Express con formularios, carga de imágenes, persistencia en RDS y envío a SQS.
- `terraform-in1/`: infraestructura como código para AWS.
- `terraform-in1/modules/static_site/`: sitio institucional estático publicado en S3.
- `terraform-in1/modules/ec2/`: instancia EC2 donde corre la app.
- `terraform-in1/modules/rds/`: base de datos MySQL administrada.
- `terraform-in1/modules/sqs/`: cola para desacoplar eventos.
- `terraform-in1/modules/lambda/`: consumidor asincrónico de la cola.
- `terraform-in1/modules/ec2_iam/`: permisos IAM para la instancia.

## Cómo funciona

### 1. Sitio institucional estático

El contenido público del sitio se genera con archivos simples:

- `index.html`
- `style.css`
- `assets/`

Terraform publica estos archivos en el bucket S3 del módulo `static_site`, dejando el sitio accesible por la URL del bucket website.

### 2. Aplicación Node.js

La app vive en `node-app/app.js` y hace tres cosas principales:

- Renderiza una vista HTML con artículos leídos desde RDS.
- Permite crear artículos con título, contenido e imagen.
- Sube la imagen a S3 y guarda la referencia en la base de datos.

Además, cuando se publica un artículo, la app envía un mensaje a SQS para mantener el flujo asincrónico.

### 3. Base de datos RDS

La instancia RDS usa MySQL y se inicializa con la tabla `articles`:

- `id`
- `title`
- `content`
- `image`

El servidor intenta crear la tabla al arrancar para asegurar que el esquema exista antes de procesar solicitudes.

### 4. Imágenes en S3

Las imágenes ya no se guardan en disco local:

- Se cargan en S3 dentro de la ruta `images/`.
- La app guarda la key del objeto en RDS.
- Al listar artículos, la app genera una URL firmada para mostrar la imagen.

## Flujo de publicación

1. El usuario completa el formulario del sitio.
2. La app recibe el archivo con `multer` en memoria.
3. La imagen se sube a S3.
4. El artículo se inserta en RDS.
5. Se envía un mensaje a SQS.
6. La vista principal vuelve a consultar la base para mostrar el contenido publicado.

## Infraestructura desplegada

Terraform administra estos recursos:

- `EC2` para correr la app.
- `RDS MySQL` para persistencia.
- `SQS` para mensajería.
- `Lambda` como consumidor del evento.
- `S3` para el sitio institucional y para las imágenes.
- `Security Groups` para controlar acceso entre componentes.

## Configuración importante

### Variables usadas por la app

- `DB_HOST`
- `DB_USER`
- `DB_PASSWORD`
- `DB_NAME`
- `S3_BUCKET_NAME`
- `AWS_REGION`

En la EC2, `S3_BUCKET_NAME` se exporta automáticamente mediante `user_data` en Terraform.

### Outputs útiles de Terraform

- `public_ip`: IP pública de la EC2.
- `queue_url`: URL de la cola SQS.
- `rds_endpoint`: endpoint de la base MySQL.
- `images_bucket_name`: bucket donde se guardan las imágenes.
- `website_url`: URL pública del sitio institucional.

## Sitio institucional

El sitio estático incluye estas secciones:

- Inicio / Hero
- Nosotros
- Servicios
- Contacto

También incluye meta tags para SEO y Open Graph, y un diseño responsive mobile-first sin frameworks pesados.

## Rendimiento y diseño

- CSS liviano, sin Bootstrap ni dependencias front pesadas.
- Layout con Grid y Flexbox.
- Imágenes SVG para mantener el peso bajo.
- Estructura clara y reusable para facilitar mantenimiento.

## Cómo desplegar

1. Ir a `terraform-in1`.
2. Ejecutar `terraform init`.
3. Ejecutar `terraform apply`.
4. Tomar los outputs para conectar la app y abrir el sitio.

## Notas finales

La solución quedó pensada para una entrega académica con foco en:

- infraestructura reproducible,
- persistencia real en base de datos,
- separación entre sitio público y aplicación,
- y un flujo simple de publicación de contenido.
