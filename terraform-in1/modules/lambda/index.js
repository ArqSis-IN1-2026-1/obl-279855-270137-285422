    exports.handler = async (event) => {
    const webhookUrl = "https://discord.com/api/webhooks/1496828429767544852/rz6gJEH-Yg9OwGIyLfy45SjW32lcXUYlyLM3SaTKF272GstA3ULWqPeoXZ3LnBpfrje_";

    const articles = [
        { title: "Cloud Computing", content: "La computación en la nube..." },
    ];

    for (const record of event.Records) {
        const randomArticle = articles[Math.floor(Math.random() * articles.length)];
        console.log(`Procesando artículo simulado: ${randomArticle.title}`);

        const discordMessage = {
            content: `**La nube ha generado un nuevo artículo**\n**Título:** ${randomArticle.title}`
        };

        try {
            await fetch(webhookUrl, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(discordMessage)
            });
        } catch (error) {
            console.error("Falló el envío a Discord:", error);
        }
    }

    return { statusCode: 200 };
};