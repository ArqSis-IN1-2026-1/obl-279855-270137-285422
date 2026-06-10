const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3000;

const { SQSClient, SendMessageCommand } = require("@aws-sdk/client-sqs");

const sqs = new SQSClient({ region: "us-east-1" });

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

let articles = [];

// Página principal HTML
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
        if (a.image) html += `<img src="/images/${a.image}" width="200"/>`;
    });
    res.send(html);
});

// publicar del HTML

app.post('/add', upload.single('image'), async (req, res) => {
    const { title, content } = req.body;
    const image = req.file ? req.file.filename : null;

    articles.push({ title, content, image });

    try {
        await sqs.send(new SendMessageCommand({
            QueueUrl: "https://sqs.us-east-1.amazonaws.com/735234196682/articles-queue",
            MessageBody: JSON.stringify({
                title: title,
                content: content
            })
        }));
        console.log(`Mensaje de "${title}" enviado a SQS correctamente.`);
    } catch (error) {
        console.error("Falló el envío a SQS desde el formulario:", error);
    }

    res.redirect('/');
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});