# La Dispensa: chatbot de productos y cocina italiana

Proyecto 2 de Fundamentos de Inteligencia Artificial (UNAB): *Diseño de un agente inteligente que usa conocimiento*.

Es un chatbot que responde preguntas sobre productos y cocina italiana a partir del catálogo de [gourmitalia.cl](https://gourmitalia.cl). Tiene dos versiones que usan el mismo conocimiento:

1. **Prolog:** el conocimiento está modelado en lógica de primer orden y las respuestas se deducen con reglas.
2. **LLM (Python + Gemini):** el modelo recibe los mismos hechos como contexto y responde en lenguaje natural.

**Versión web:** <https://valtrss.github.io/Proyecto-2-chatbot/> (solo la versión Prolog; ver abajo).

## Documentación

- **[Dominio y modelo del conocimiento](docs/dominio.md):** por qué elegimos el dominio y cómo está representado el conocimiento. Incluye las constantes y predicados con su aridad, las reglas escritas en lógica de primer orden y cómo Prolog demuestra una consulta.
- **[Informe de desempeño](docs/informe.md):** las 20 preguntas de prueba con las respuestas de ambas versiones (Prolog y LLM), la comparación de sus fortalezas y debilidades, las conclusiones y las propuestas de mejora.

## Cómo usarlo

**Versión Prolog:** funciona directo en la [versión web](https://valtrss.github.io/Proyecto-2-chatbot/), sin instalar nada.

**Versión LLM:** necesita ejecutarse en el computador, porque usa una API key de Gemini que no puede quedar en una página pública.

1. Crear una API key gratis en <https://aistudio.google.com/apikey>.
2. Crear un archivo `.env` en la raíz del proyecto con la línea `GEMINI_API_KEY=tu_key`. Este archivo no se sube a GitHub.
3. Instalar las dependencias y levantar el servidor:

   ```bash
   python3 -m venv .venv
   .venv/bin/pip install -r requirements.txt
   .venv/bin/python backend/app.py
   ```

4. Abrir <http://localhost:5000> y elegir **LLM** en el selector de arriba a la derecha.

El plan gratis de Gemini limita las consultas por minuto y por día. Si aparece "cuota excedida", hay que esperar un rato.

## Integrantes

- Carlos León Gómez
- Nicolás Salas Villarroel
- Simón Saavedra Avello

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
backend/                versión LLM y servidor
  motor_llm.py          chatbot con LLM (Gemini) usando la misma base de conocimiento
  motor_prolog.py       puente Python → SWI-Prolog (por consola)
  app.py                servidor Flask: sirve la web y la API /api/chat
  responder_preguntas.py  responde las preguntas del informe con ambos motores
index.html              redirige a web/ (para GitHub Pages)
docs/                   documentación, informe y preguntas de prueba
```
