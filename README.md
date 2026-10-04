# La Dispensa: chatbot de productos y cocina italiana

Proyecto 2 de Fundamentos de Inteligencia Artificial (UNAB): *Diseño de un agente inteligente que usa conocimiento*.

Es un chatbot que responde preguntas sobre productos y cocina italiana a partir del catálogo de [gourmitalia.cl](https://gourmitalia.cl). Tiene dos versiones:

1. **Prolog:** el conocimiento está modelado en lógica de primer orden.
2. **LLM + Python:** pendiente para la Entrega 2.

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
backend/                servidor Flask, base para la versión LLM (Entrega 2)
  app.py                sirve la web y la API /api/chat
  motor_prolog.py       puente Python → SWI-Prolog (por consola)
index.html              redirige a web/ (para GitHub Pages)
docs/                   documentación e informe
```

## Requisitos

- [SWI-Prolog](https://www.swi-prolog.org/) 9 o superior (`swipl` en el PATH)
- Python 3.9 o superior

## Uso

### Solo Prolog (consola)

```bash
cd prolog
swipl chatbot.pl
```

```prolog
?- iniciar.                                   % conversación
?- responder("¿Qué vino va con la carbonara?", R).
?- analizar("precio del parmesano").          % muestra palabras e intención
?- es_un(gorgonzola_dolce, X).                % consultas directas a la base
?- costo_receta(carbonara, Total, Detalle).
```

### Consultas directas a la base de conocimiento

Consultas de sí o no:

```prolog
?- es_un(gorgonzola_dolce, queso).            % true (por la taxonomía)
?- apto_celiaco(spaghetti_gragnano).          % false: es pasta de trigo
?- receta_completa(pasta_e_patate).           % false: la pasta mista está agotada
?- se_combinan(balsamico, parmigiano_reggiano). % true (relación simétrica)
```

Consultas con variables (`;` pide la siguiente respuesta):

```prolog
?- region(P, toscana).                        % productos de Toscana
?- es_un(P, queso_azul).                      % quesos azules
?- leche(Q, oveja).                           % quesos de oveja
?- misma_region(nduja, X).                    % otros productos de Calabria
?- recetas_con(guanciale, R).                 % recetas que usan guanciale
?- animal_de(bresaola, A).                    % A = vacuno (excepción a la regla por defecto)
?- mas_barato(vino, V).                       % vino disponible más barato
?- costo_receta(carbonara, Total, Detalle).
?- receta_sin_gluten(carbonara, Plan, Problemas).
?- findall(P, sello(P, dop), L).              % todos los productos D.O.P.
```

### Interfaz web

Está publicada en <https://valtrss.github.io/Proyecto-2-chatbot/>.

Para abrirla en el computador sin publicarla, basta un servidor de archivos desde la raíz del proyecto. Abrir `index.html` con doble clic no funciona, porque el navegador bloquea la descarga de los `.pl`.

```bash
python3 -m http.server 8000
```

Después, abrir <http://localhost:8000/web/>.

### Publicar en GitHub Pages

En el repositorio: **Settings → Pages → Build and deployment**. En *Source* elegir **Deploy from a branch**, rama **main** y carpeta **/ (root)**, y guardar. Cada `git push` actualiza la página en uno o dos minutos.

### Pruebas

```bash
cd prolog
swipl -g run_tests -t halt tests.pl
```

## Cómo modificar el conocimiento

Todos los hechos están en `prolog/base/`, agrupados en bloques. Después de cada cambio, ejecutar `make.` en la consola de Prolog (o reiniciar). En la web basta recargar la página, porque descarga los `.pl` cada vez que se abre.

| Quiero… | Editar |
|---|---|
| agregar un producto | copiar un bloque en `productos.pl` y cambiar los valores |
| cambiar un precio o marcar algo como agotado | `producto/5` o `agotado/1` en `productos.pl` |
| agregar un tipo nuevo | `subtipo/2` y `nombre_tipo/3` en `taxonomia.pl` |
| agregar una receta | `receta/4`, `ingrediente/3` y `perfil/2` en `recetas.pl` |
| cambiar un maridaje | `marida_perfil/3` o `marida_tipo/3` en `maridajes.pl` |
| que el bot entienda otra palabra | `sinonimo/3` en `sinonimos.pl` |

## Integrantes

- _(completar)_
- _(completar)_
- _(completar)_
