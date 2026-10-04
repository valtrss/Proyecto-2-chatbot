# La Dispensa: chatbot de productos y cocina italiana

Proyecto 2 de Fundamentos de Inteligencia Artificial (UNAB): *Diseño de un agente inteligente que usa conocimiento*.

Es un chatbot que responde preguntas sobre productos y cocina italiana a partir del catálogo de [gourmitalia.cl](https://gourmitalia.cl). El conocimiento está modelado en lógica de primer orden con Prolog.

La explicación del dominio y del modelo está en [docs/dominio.md](docs/dominio.md), y el informe de desempeño con las 20 preguntas en [docs/informe.md](docs/informe.md).

**Versión web:** <https://valtrss.github.io/Proyecto-2-chatbot/>. Prolog se ejecuta dentro del navegador con [swipl-wasm](https://www.npmjs.com/package/swipl-wasm), SWI-Prolog compilado a WebAssembly, así que no necesita servidor. La primera carga tarda unos segundos mientras se descarga Prolog.

## Estructura

```
prolog/
  base/                 hechos (lo que se edita para cambiar el conocimiento)
    productos.pl        75 productos: precio, región, sello, leche, uva, etc.
    taxonomia.pl        jerarquía de tipos (subtipo/2)
    regiones.pl         regiones de Italia y significado de los sellos
    recetas.pl          11 recetas con sus ingredientes
    maridajes.pl        reglas de vino por perfil de plato y tipo de producto
    combinaciones.pl    productos que se comen juntos (relación simétrica)
    sinonimos.pl        otras formas de nombrar productos, recetas, etc.
  base.pl               carga todos los hechos y las reglas
  reglas.pl             reglas de inferencia
  lenguaje.pl           normalización, entidades e intenciones
  respuestas.pl         armado de las respuestas
  chatbot.pl            responder/2 y modo consola
  cli.pl                responde una pregunta (lo usa el backend)
  tests.pl              pruebas automáticas (plunit)
web/                    interfaz del chat; ejecuta Prolog en el navegador
backend/                servidor Flask
  app.py                sirve la web y la API /api/chat
  motor_prolog.py       puente Python → SWI-Prolog (por consola)
index.html              redirige a web/ (para GitHub Pages)
docs/                   documentación e informe
```

## Integrantes

- Carlos León Gómez
- Nicolás Salas Villarroel
- Simón Saavedra Avello
