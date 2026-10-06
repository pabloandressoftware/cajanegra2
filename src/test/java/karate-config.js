function fn() {
    var config = {
        env: karate.env || 'dev',
        // API de los ejercicios de caja negra (transición de estados y tablas de decisión)
        baseUrl: 'https://taller-de-tecnicas-de-prueba-de-caja.onrender.com/api/'
    };

    // Simplifica y formatea el JSON/XML de los Requests y Responses en la consola
    karate.configure('logPrettyRequest', true);
    karate.configure('logPrettyResponse', true);

    // El servidor está en Render (plan gratuito): si estaba dormido, la primera
    // petición puede tardar ~1 minuto, por eso los timeouts son amplios.
    karate.configure('connectTimeout', 90000);
    karate.configure('readTimeout', 90000);

    // "Despierta" el servidor una sola vez antes de toda la suite
    karate.callSingle('classpath:features/warmup.feature', config);

    return config;
}
