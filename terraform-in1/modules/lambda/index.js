exports.handler = async (event) => {

    for (const record of event.Records) {

        console.log("Mensaje recibido:");

        console.log(record.body);
    }

    console.log("Artículo generado automáticamente");

    return {
        statusCode: 200
    };
};