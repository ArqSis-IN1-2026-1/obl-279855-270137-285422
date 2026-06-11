const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const mysql = require('mysql2/promise');

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

const { SQSClient, SendMessageCommand } = require("@aws-sdk/client-sqs");

const sqs = new SQSClient({ region: "us-east-1" });

async function initDB() {
    try {
        const connection = await mysql.createConnection(dbConfig);
        await connection.query(`
            CREATE TABLE IF NOT EXISTS articles (
                id INT AUTO_INCREMENT PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                content TEXT,
                image VARCHAR(255)
            )
        `);
        await connection.end();
        console.log('Conexion a RDS exitosa y tabla verificada.');
    } catch (error) {
        console.error('No se pudo conectar a la base de datos RDS:', error.message);
    }
}

initDB();

app.get("/generate", async (req, res) => {
    try {
        await sqs.send(new SendMessageCommand({
            QueueUrl: "https://sqs.us-east-1.amazonaws.com/735234196682/articles-queue",
            MessageBody: JSON.stringify({
                title: "Artículo automático desde /generate"
            })
        }));
        res.send("Solicitud enviada a Lambda exitosamente");
    } catch (error) {
        console.error("Error en /generate:", error);
        res.status(500).send("Falló el envío a SQS");
    }
});


const uploadDir = './data/images';
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}
const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, uploadDir),
    filename: (req, file, cb) => cb(null, Date.now() + path.extname(file.originalname))
});
const upload = multer({ storage });

app.use(express.urlencoded({ extended: true }));
app.use('/images', express.static(uploadDir));

// Página principal HTML
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

        rows.forEach(a => {
            html += `<h2>${a.title}</h2><p>${a.content || ''}</p>`;
            if (a.image) html += `<img src="/images/${a.image}" width="200"/>`;
        });
    } catch (error) {
        html += '<p style="color:red;">Error al cargar articulos desde la base de datos.</p>';
        console.error('Error leyendo articulos de RDS:', error.message);
    }

    res.send(html);
});

// publicar del HTML

app.post('/add', upload.single('image'), async (req, res) => {
    const { title, content } = req.body;
    const image = req.file ? req.file.filename : null;

    try {
        const connection = await mysql.createConnection(dbConfig);
        await connection.query(
            'INSERT INTO articles (title, content, image) VALUES (?, ?, ?)',
            [title, content, image]
        );
        await connection.end();

        await sqs.send(new SendMessageCommand({
            QueueUrl: "https://sqs.us-east-1.amazonaws.com/735234196682/articles-queue",
            MessageBody: JSON.stringify({
                title: title,
                content: content
            })
        }));
        console.log(`Articulo "${title}" guardado en RDS y enviado a SQS.`);
    } catch (error) {
        console.error('Error en el proceso de publicacion:', error.message);
    }

    res.redirect('/');
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});