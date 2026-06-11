const express = require('express');
const multer = require('multer');
const path = require('path');
const mysql = require('mysql2/promise');
const { S3Client, PutObjectCommand, GetObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const { SQSClient, SendMessageCommand } = require('@aws-sdk/client-sqs');

const app = express();
const PORT = 3000;

const dbHostInput = process.env.DB_HOST || 'terraform-20260610110030931700000001.c8zmm4w621rn.us-east-1.rds.amazonaws.com';
const [dbHost, dbPort] = dbHostInput.split(':');

const dbConfig = {
    host: dbHost,
    port: dbPort ? Number(dbPort) : 3306,
    user: process.env.DB_USER || 'admin',
    password: process.env.DB_PASSWORD || 'PasswordSeguraIEN1',
    database: process.env.DB_NAME || 'obligatorio_db'
};

const awsRegion = process.env.AWS_REGION || 'us-east-1';
const s3 = new S3Client({ region: awsRegion });
const sqs = new SQSClient({ region: awsRegion });
const imageBucketName = process.env.S3_BUCKET_NAME || '';
const queueUrl = process.env.QUEUE_URL || 'https://sqs.us-east-1.amazonaws.com/735234196682/articles-queue';

async function initDB() {
    try {
        const connection = await mysql.createConnection(dbConfig);
        await connection.query(`
            CREATE TABLE IF NOT EXISTS articles (
                id INT AUTO_INCREMENT PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                content TEXT,
                image VARCHAR(512)
            )
        `);
        await connection.end();
        console.log('Conexion a RDS exitosa y tabla verificada.');
    } catch (error) {
        console.error('No se pudo conectar a la base de datos RDS:', error.message);
    }
}

async function uploadImageToS3(file) {
    if (!file) {
        return null;
    }

    if (!imageBucketName) {
        throw new Error('S3_BUCKET_NAME no esta configurada');
    }

    const objectKey = `images/${Date.now()}${path.extname(file.originalname)}`;

    await s3.send(new PutObjectCommand({
        Bucket: imageBucketName,
        Key: objectKey,
        Body: file.buffer,
        ContentType: file.mimetype
    }));

    return objectKey;
}

async function resolveImageUrl(imageValue) {
    if (!imageValue) {
        return null;
    }

    if (imageValue.startsWith('http://') || imageValue.startsWith('https://')) {
        return imageValue;
    }

    if (!imageBucketName) {
        return imageValue;
    }

    return getSignedUrl(
        s3,
        new GetObjectCommand({
            Bucket: imageBucketName,
            Key: imageValue
        }),
        { expiresIn: 3600 }
    );
}

const upload = multer({ storage: multer.memoryStorage() });

app.use(express.urlencoded({ extended: true }));

app.get('/generate', async (req, res) => {
    try {
        await sqs.send(new SendMessageCommand({
            QueueUrl: queueUrl,
            MessageBody: JSON.stringify({
                title: 'Artículo automático desde /generate'
            })
        }));
        res.send('Solicitud enviada a Lambda exitosamente');
    } catch (error) {
        console.error('Error en /generate:', error);
        res.status(500).send('Falló el envío a SQS');
    }
});

app.get('/', async (req, res) => {
    let html = `
        <h1>Artículos</h1>
        <form method="POST" action="/add" enctype="multipart/form-data">
            <input type="text" name="title" placeholder="Título" required />
            <textarea name="content" placeholder="Contenido"></textarea>
            <input type="file" name="image" />
            <button type="submit">Publicar</button>
        </form>
        <hr/>
    `;

    try {
        const connection = await mysql.createConnection(dbConfig);
        const [rows] = await connection.query('SELECT * FROM articles ORDER BY id DESC');
        await connection.end();

        const renderedRows = await Promise.all(rows.map(async (article) => ({
            ...article,
            imageUrl: await resolveImageUrl(article.image)
        })));

        renderedRows.forEach((article) => {
            html += `<h2>${article.title}</h2><p>${article.content || ''}</p>`;
            if (article.imageUrl) {
                html += `<img src="${article.imageUrl}" width="200"/>`;
            }
        });
    } catch (error) {
        html += '<p style="color:red;">Error al cargar articulos desde la base de datos.</p>';
        console.error('Error leyendo articulos de RDS:', error.message);
    }

    res.send(html);
});

app.post('/add', upload.single('image'), async (req, res) => {
    const { title, content } = req.body;
    const image = req.file ? await uploadImageToS3(req.file) : null;

    try {
        const connection = await mysql.createConnection(dbConfig);
        await connection.query(
            'INSERT INTO articles (title, content, image) VALUES (?, ?, ?)',
            [title, content, image]
        );
        await connection.end();

        await sqs.send(new SendMessageCommand({
            QueueUrl: queueUrl,
            MessageBody: JSON.stringify({
                title,
                content
            })
        }));

        console.log(`Articulo "${title}" guardado en RDS y enviado a SQS.`);
    } catch (error) {
        console.error('Error en el proceso de publicacion:', error.message);
    }

    res.redirect('/');
});

initDB();

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
