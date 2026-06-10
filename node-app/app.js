const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3000;

const {
    SQSClient,
    SendMessageCommand
} = require("@aws-sdk/client-sqs");

const sqs = new SQSClient({
    region: process.env.AWS_REGION || "us-east-1"
});

const QUEUE_URL = process.env.QUEUE_URL || "https://sqs.us-east-1.amazonaws.com/717221858869/articles-queue";

app.get("/generate", async (req, res) => {
    await sqs.send(new SendMessageCommand({
        QueueUrl: QUEUE_URL,
        MessageBody: JSON.stringify({
            title: "Artículo automático"
        })
    }));

    res.send("Solicitud enviada a Lambda");
});

// Carpeta de imágenes
const uploadDir = './data/images';
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// Configuración de multer
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ storage });

app.use(express.urlencoded({ extended: true }));
app.use('/images', express.static(uploadDir));

let articles = [];

// Página principal
app.get('/', (req, res) => {
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

    articles.forEach(a => {
        html += `<h2>${a.title}</h2><p>${a.content}</p>`;
        if (a.image) {
            html += `<img src="/images/${a.image}" width="200"/>`;
        }
    });

    res.send(html);
});

// Crear artículo
app.post('/add', upload.single('image'), (req, res) => {
    const { title, content } = req.body;
    const image = req.file ? req.file.filename : null;

    articles.push({ title, content, image });
    res.redirect('/');
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
