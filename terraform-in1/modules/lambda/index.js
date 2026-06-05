exports.handler = async (event) => {

    const articles = [

        {
            title: "Cloud Computing",

            content:
              "La computación en la nube permite acceder a recursos tecnológicos de forma remota."
        },

        {
            title: "Inteligencia Artificial",

            content:
              "La inteligencia artificial permite automatizar procesos y analizar grandes volúmenes de información."
        },

        {
            title: "Ciberseguridad",

            content:
              "La ciberseguridad protege sistemas y datos frente a amenazas digitales."
        },

        {
            title: "Desarrollo Web",

            content:
              "El desarrollo web permite crear aplicaciones accesibles desde internet."
        }
    ];

    console.log("Artículos generados automáticamente:");

    for (const article of articles) {

        console.log("====================");

        console.log(article.title);

        console.log(article.content);
    }

    return {

        statusCode: 200
    };
};