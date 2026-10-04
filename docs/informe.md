# Informe de desempeño del chatbot

Proyecto 2: *Diseño de un agente inteligente que usa conocimiento*. Fundamentos de Inteligencia Artificial, UNAB.

## 1. Las dos versiones

Las dos versiones usan **el mismo conocimiento**: los hechos de `prolog/base/` (productos, taxonomía, regiones, recetas, maridajes y combinaciones). El dominio y el modelo en lógica de primer orden se explican en [dominio.md](dominio.md).

| | Versión Prolog | Versión LLM |
|---|---|---|
| Cómo usa el conocimiento | consulta los hechos y deduce con reglas (`reglas.pl`) | recibe los hechos como contexto y redacta la respuesta |
| Cómo entiende la pregunta | palabras clave, sinónimos e intenciones (`lenguaje.pl`) | el modelo entiende el lenguaje natural |
| Implementación | SWI-Prolog | Python + Gemini (`gemini-3.5-flash-lite`), `backend/motor_llm.py` |
| Instrucciones | — | responder solo con la base, no inventar productos ni precios, decir "No tengo esa información en el catálogo" si no está |

## 2. Metodología

Se eligieron 20 preguntas en tres grupos:

| Grupo | Preguntas | Qué evalúa |
|---|---|---|
| Consultas directas | 1–5 | recuperar un dato que está escrito en los hechos |
| Inferencia | 6–15 | deducir conocimiento que no está escrito, combinando hechos y reglas |
| Fuera de la BC y lenguaje natural | 16–20 | preguntas sobre cosas que la BC no conoce, preguntas abiertas y formas de hablar difíciles (negación, "por qué") |

El tercer grupo se incluyó a propósito para encontrar los límites de cada versión.

Cada respuesta se clasifica como:

- **Correcta:** responde lo pedido y el contenido es verdadero según la base.
- **Parcial:** responde algo relacionado, pero incompleto, poco útil o con algún error menor.
- **Incorrecta:** responde algo falso o algo distinto de lo pedido.
- **No responde:** reconoce que no sabe o no entiende.

Las respuestas se generaron el 04-10-2026 con `backend/responder_preguntas.py`, que pasa las preguntas de `docs/preguntas.txt` por ambos motores. El detalle sin editar está en [respuestas_generadas.md](respuestas_generadas.md).

## 3. Resumen de resultados

| # | Pregunta | Grupo | Prolog | LLM |
|---|---|---|---|---|
| 1 | ¿Cuánto cuesta el parmigiano reggiano? | Consulta directa | Correcta | Correcta |
| 2 | ¿De qué región es la 'nduja? | Consulta directa | Correcta | Correcta |
| 3 | ¿Qué quesos son de leche de oveja? | Consulta directa | Correcta | Correcta |
| 4 | ¿Qué significa D.O.P.? | Consulta directa | Correcta | Correcta |
| 5 | ¿Cuánto tiempo de cocción tienen los paccheri? | Consulta directa | Correcta | Correcta |
| 6 | ¿El gorgonzola tiene lactosa? | Inferencia | Correcta | No responde |
| 7 | ¿Qué vino va con la carbonara? | Inferencia | Correcta | Correcta |
| 8 | ¿Puedo hacer carbonara sin gluten? | Inferencia | Correcta | Parcial |
| 9 | ¿Cuánto cuesta preparar un tiramisú? | Inferencia | Parcial | Parcial |
| 10 | ¿Puedo comprar todo para la pasta e patate? | Inferencia | Correcta | Parcial |
| 11 | ¿Qué recetas son vegetarianas? | Inferencia | Correcta | No responde |
| 12 | ¿De qué animal es la bresaola? | Inferencia | Correcta | Correcta |
| 13 | ¿Qué embutidos hay del sur? | Inferencia | Correcta | Correcta |
| 14 | ¿Qué diferencia hay entre el pecorino romano y el pecorino sardo? | Inferencia | Parcial | Correcta |
| 15 | ¿Con qué combina el parmigiano? | Inferencia | Correcta | Correcta |
| 16 | ¿Qué vino va con la pizza? | Fuera de la BC | No responde | No responde |
| 17 | ¿Qué me recomiendas para una cena romántica? | Fuera de la BC | No responde | No responde |
| 18 | ¿Por qué el prosciutto San Daniele es tan caro? | Lenguaje natural | Incorrecta | Correcta |
| 19 | ¿Tienen algún queso de cabra? | Lenguaje natural | Incorrecta | Parcial |
| 20 | ¿Qué puedo cocinar si no como carne? | Lenguaje natural | Incorrecta | Correcta |

| Resultado | Prolog | LLM |
|---|---|---|
| Correcta | 13 | 12 |
| Parcial | 2 | 4 |
| Incorrecta | 3 | 0 |
| No responde | 2 | 4 |

| Grupo | Correctas Prolog | Correctas LLM |
|---|---|---|
| Consultas directas (1–5) | 5 de 5 | 5 de 5 |
| Inferencia (6–15) | 8 de 10 | 5 de 10 |
| Fuera de la BC y lenguaje natural (16–20) | 0 de 5 | 2 de 5 |

## 4. Preguntas y respuestas

### 1. ¿Cuánto cuesta el parmigiano reggiano?

*Grupo: Consulta directa*

**Prolog** (Correcta):

```text
Precio (gourmitalia.cl, octubre 2026):
• Parmigiano Reggiano D.O.P. 18 meses (Boni): $20.900, 360 g aprox.
```

Dato tomado directamente de los hechos (`producto/5`).

**LLM** (Correcta):

```text
El Parmigiano Reggiano D.O.P. 18 meses cuesta $20.900.
```

Correcta y directa.

### 2. ¿De qué región es la 'nduja?

*Grupo: Consulta directa*

**Prolog** (Correcta):

```text
• 'Nduja Piccante viene de Calabria, en el sur de Italia.
```

Combina `region/2` con `region_italiana/4` para agregar la zona.

**LLM** (Correcta):

```text
La 'nduja es originaria de la región de Calabria.
```

Correcta.

### 3. ¿Qué quesos son de leche de oveja?

*Grupo: Consulta directa*

**Prolog** (Correcta):

```text
Productos de leche de oveja (2):
• Pecorino Romano D.O.P. (Pinna): $8.365, 200 g
• Pecorino 100% Sardo Barone (Maoddi): $10.800, 200 g aprox.
```

Consulta con variable que devuelve todas las soluciones de `leche(Q, oveja)`.

**LLM** (Correcta):

```text
• Pecorino Romano D.O.P.
• Pecorino 100% Sardo Barone
```

Correcta, aunque sin precios.

### 4. ¿Qué significa D.O.P.?

*Grupo: Consulta directa*

**Prolog** (Correcta):

```text
D.O.P. = Denominación de Origen Protegida: todo el proceso (producción, elaboración y maduración) ocurre en una zona geográfica delimitada y sigue un reglamento oficial.
```

Respuesta desde `significado_sello/3`. Entiende la sigla escrita con puntos.

**LLM** (Correcta):

```text
D.O.P. significa Denominación de Origen Protegida. Todo el proceso (producción, elaboración y maduración) ocurre en una zona geográfica delimitada y sigue un reglamento oficial.
```

Correcta; reproduce el texto de la base.

### 5. ¿Cuánto tiempo de cocción tienen los paccheri?

*Grupo: Consulta directa*

**Prolog** (Correcta):

```text
Tiempo de cocción:
• Paccheri I.G.P. (Pasta di Gragnano): 13 minutos
```

Dato directo de `coccion/2`.

**LLM** (Correcta):

```text
Los paccheri tienen un tiempo de cocción de 13 minutos.
```

Correcta.

### 6. ¿El gorgonzola tiene lactosa?

*Grupo: Inferencia*

**Prolog** (Correcta):

```text
• Gorgonzola Dolce D.O.P.: no es apto para intolerantes a la lactosa, porque es un lácteo.
• Gorgonzola Piccante D.O.P.: no es apto para intolerantes a la lactosa, porque es un lácteo.
```

"Gorgonzola" es ambiguo (dolce y piccante), así que responde por ambos. Deduce que es lácteo por la taxonomía (`gorgonzola → queso_azul → queso → lacteo`) y lo explica.

**LLM** (No responde):

```text
No tengo esa información en el catálogo
```

No hace la inferencia: el dato "es lácteo" no está escrito para el gorgonzola, solo se deduce de la taxonomía, y el modelo prefiere decir que no sabe.

### 7. ¿Qué vino va con la carbonara?

*Grupo: Inferencia*

**Prolog** (Correcta):

```text
Para Spaghetti alla Carbonara te sugiero:
• Lambrusco Grasparossa di Castelvetro D.O.C. Secco (Cavicchioli): $10.050, 750 ml
   porque el lambrusco es el compañero clásico del cerdo y los embutidos.
• Prosecco Extra Dry D.O.C. (Cavicchioli): $18.800, 750 ml
   porque la burbuja y la acidez limpian la grasa del plato.
```

Inferencia en varios pasos (perfil del plato → clase de vino → vinos del catálogo). Da productos concretos con precio y la razón de cada sugerencia.

**LLM** (Correcta):

```text
Para acompañar la carbonara, las opciones sugeridas son:

• Vino espumante: porque la burbuja y la acidez limpian la grasa del plato.
• Lambrusco: porque es el compañero clásico del cerdo y los embutidos.
```

Usa bien las reglas de maridaje, pero responde con clases de vino ("espumante", "lambrusco") y no con productos concretos ni precios.

### 8. ¿Puedo hacer carbonara sin gluten?

*Grupo: Inferencia*

**Prolog** (Correcta):

```text
Sí, puedes preparar Spaghetti alla Carbonara sin gluten con productos de la tienda:
• spaghetti → Spaghetti Sin Gluten
• Guanciale Stagionato → reemplazar por Pancetta Delicattesse, que sí es apto
• Pecorino Romano D.O.P. (apto)
```

Busca un producto apto para cada ingrediente y, si no lo hay, usa un sustituto (guanciale → pancetta). Es la respuesta que mejor muestra el razonamiento.

**LLM** (Parcial):

```text
Sí, puedes hacer una carbonara sin gluten usando los siguientes productos del catálogo:

• Spaghetti Sin Gluten ($4.650)

También puedes usar guanciale y pecorino romano, que son los ingredientes tradicionales para la salsa carbonara. No tengo esa información en el catálogo sobre si el guanciale tiene certificación sin gluten, pero el catálogo incluye el Prosciutto Crudo Classico Friuli y el Speck que sí indican explícitamente ser sin gluten (aunque la receta clásica lleva guanciale).
```

Sugiere los spaghetti sin gluten, pero no resuelve el guanciale: no aplica la sustitución por pancetta y termina proponiendo prosciutto, que no es parte de la receta.

### 9. ¿Cuánto cuesta preparar un tiramisú?

*Grupo: Inferencia*

**Prolog** (Parcial):

```text
Comprando la opción más barata de cada ingrediente, Tiramisù cuesta $49.050:
• Mascarpone Fresco UHT: $11.450
• Savoiardi: $3.400
• Caffè en Grano Borbone Classica: $34.200
(No incluye ingredientes básicos como huevos, sal o ajo.)
```

El total es correcto según la regla, pero suma envases completos: el café de 1 kg infla el resultado y no se da cuenta de que faltan savoiardi (la receta pide 300 g y el paquete trae 200 g).

**LLM** (Parcial):

```text
Para preparar un tiramisú según la receta tradicional, los ingredientes que ofrece la tienda y sus precios son:

• Mascarpone Fresco UHT (500 g): $11.450
• Savoiardi (200 g): $3.400 (se necesitan 300 g, por lo que requeriría más de un paquete)
• Caffè en Grano Borbone Classica (1 kg): $34.200 (se usan 300 ml de café espresso)

Los ingredientes básicos como huevos, azúcar, cacao amargo y el resto del café no se venden en la tienda.
```

Mejor que Prolog en sentido común (nota que faltan savoiardi y que el café se usa en parte), pero no entrega el costo total que se pidió.

### 10. ¿Puedo comprar todo para la pasta e patate?

*Grupo: Inferencia*

**Prolog** (Correcta):

```text
No todo: para Pasta e Patate alla Napoletana falta Pasta Mista Dedicato Nº48 en la tienda.
```

Detecta que la pasta mista está agotada usando la negación por fallo (`\+ agotado(P)`).

**LLM** (Parcial):

```text
Para preparar la receta de Pasta e Patate alla Napoletana, necesitarás los siguientes ingredientes:

• Pasta mista: Está agotada en este momento.
• Papas, apio, zanahoria, cebolla morada, hierbas y sal: Son ingredientes básicos que la tienda no vende.
• Aceite de oliva: Disponible por $10.550 (500 ml).
• Concentrado de tomate: Disponible por $3.950 (200 g).
• Pancetta: Disponible por $10.650 (300 g aprox.).
• Parmigiano Reggiano (para la corteza a gusto): Disponible por $20.900 (360 g aprox.).
• Provola (en este caso tenemos la Provola dei Monti Affumicata): Disponible por $20.950 (780 g), aunque se encuentra congelada.

No puedes comprar todo en la tienda porque la pasta mista está agotada y varios vegetales y condimentos son ingredientes básicos que no se venden en gourmitalia.cl.
```

La conclusión es correcta (falta la pasta mista), pero **inventa un error**: dice que la receta usa Parmigiano Reggiano, cuando la base indica Grana Padano.

### 11. ¿Qué recetas son vegetarianas?

*Grupo: Inferencia*

**Prolog** (Correcta):

```text
Recetas vegetarianas:
• Risotto ai Funghi Porcini
• Orecchiette al Pesto Trapanese
• Pesto alla Genovese casero
• Trofie al Pesto Genovese
• Pasta en ensalada de pesto y tomates cherry
• Linguine Integrales con Pecorino y Nueces
• Tiramisù
```

Usa `receta_vegetariana/1`, que revisa que ningún ingrediente sea carne o pescado.

**LLM** (No responde):

```text
No tengo esa información en el catálogo
```

No responde aunque la información está en la base. Para contestar tendría que revisar los ingredientes de cada receta, y no lo hace.

### 12. ¿De qué animal es la bresaola?

*Grupo: Inferencia*

**Prolog** (Correcta):

```text
• Fior di Bresaola della Valtellina: carne de vacuno
```

Razonamiento por defecto: los embutidos son de cerdo salvo excepción (`carne(bresaola, vacuno)`).

**LLM** (Correcta):

```text
La bresaola es de vacuno.
```

Correcta; el dato `carne(bresaola, vacuno)` está explícito.

### 13. ¿Qué embutidos hay del sur?

*Grupo: Inferencia*

**Prolog** (Correcta):

```text
Productos del sur de Italia (embutidos) (2):
• 'Nduja Piccante (Corte Buona): $12.600, 400 g
• Salame Spianata Piccante (Negrini): $5.550, 100 g laminado
```

Cruza dos condiciones: tipo (embutido, por taxonomía) y zona (sur, a través de la región).

**LLM** (Correcta):

```text
• 'Nduja Piccante (Calabria), $12.600
• Salame Spianata Piccante (Calabria), $5.550 (laminado 100 g)
```

Correcta: cruza tipo y región sin problemas.

### 14. ¿Qué diferencia hay entre el pecorino romano y el pecorino sardo?

*Grupo: Inferencia*

**Prolog** (Parcial):

```text
Comparación:

• Pecorino Romano D.O.P. (Pinna): $8.365, 200 g
Tipo: pecorino. Origen: Cerdeña (las islas). Sello D.O.P. Leche de oveja. Queso salado de leche entera de oveja; pese a su nombre hoy se produce sobre todo en Cerdeña. Es el queso de la carbonara.

• Pecorino 100% Sardo Barone (Maoddi): $10.800, 200 g aprox.
Tipo: pecorino. Origen: Cerdeña (las islas). Leche de oveja. Maduración: 60 días. Queso de mesa semicurado de leche pura de oveja, de sabor dulce y sabroso.
```

Muestra la ficha de cada queso, pero no resume las diferencias.

**LLM** (Correcta):

```text
El Pecorino Romano D.O.P. es un queso salado de leche entera de oveja que se produce principalmente en Cerdeña y es el queso tradicional de la carbonara. 

El Pecorino 100% Sardo Barone es un queso de mesa semicurado con una maduración de 60 días, elaborado también con leche pura de oveja, pero de sabor dulce y sabroso.
```

Mejor que Prolog: redacta las diferencias (salado vs. dulce, D.O.P., maduración) en vez de mostrar dos fichas.

### 15. ¿Con qué combina el parmigiano?

*Grupo: Inferencia*

**Prolog** (Correcta):

```text
Parmigiano Reggiano D.O.P. 18 meses combina bien con:
• Aceto Balsamico di Modena I.G.P. Invecchiato 3 Anni (Monari Federzoni): $15.950, 250 ml
```

La regla simétrica `se_combinan/2` permite responder aunque el hecho esté escrito en el otro sentido.

**LLM** (Correcta):

```text
El Parmigiano Reggiano D.O.P. 18 meses combina con:

• Aceto Balsamico di Modena I.G.P. Invecchiato 3 Anni (es un clásico de Emilia-Romaña).
```

Correcta.

### 16. ¿Qué vino va con la pizza?

*Grupo: Fuera de la BC*

**Prolog** (No responde):

```text
No conozco ese plato. Puedo sugerir vino para estas recetas: Spaghetti alla Carbonara, Bucatini all'Amatriciana, Risotto ai Funghi Porcini, Pasta e Patate alla Napoletana, Orecchiette al Pesto Trapanese, Pesto alla Genovese casero, Trofie al Pesto Genovese, Pasta en ensalada de pesto y tomates cherry, Linguine con Anchoas y Piñones, Linguine Integrales con Pecorino y Nueces y Tiramisù. También para quesos, embutidos y postres del catálogo, por ejemplo «¿qué vino va con el gorgonzola?».
```

Reconoce que la pizza no está en la BC y ofrece las recetas que sí conoce.

**LLM** (No responde):

```text
No tengo esa información en el catálogo
```

Dice que no tiene la información, sin ofrecer alternativas.

### 17. ¿Qué me recomiendas para una cena romántica?

*Grupo: Fuera de la BC*

**Prolog** (No responde):

```text
Perdón, no entendí la pregunta.
Prueba nombrando un producto, una receta o una región, por ejemplo: «¿Qué vino va con la carbonara?» o «¿Qué quesos son D.O.P.?». Escribe «ayuda» para ver más ejemplos.
```

Pregunta abierta, sin productos ni recetas mencionados: no la puede interpretar.

**LLM** (No responde):

```text
No tengo esa información en el catálogo
```

Igual que Prolog, no responde. Las instrucciones le piden no salir del catálogo, y no intenta armar una recomendación con los productos que conoce.

### 18. ¿Por qué el prosciutto San Daniele es tan caro?

*Grupo: Lenguaje natural*

**Prolog** (Incorrecta):

```text
El prosciutto más caro disponible es:
• Prosciutto Crudo San Daniele D.O.P. 16 meses (Principe): $450.000, pieza entera de 7,5 kg
```

Detecta "caro" y responde cuál es el prosciutto más caro, pero no explica el porqué.

**LLM** (Correcta):

```text
El Prosciutto Crudo San Daniele D.O.P. 16 meses es una pieza entera de 7,5 kg y cuenta con la Denominación de Origen Protegida (D.O.P.), lo que significa que todo su proceso de producción, elaboración y maduración ocurre en una zona geográfica delimitada y sigue un riguroso reglamento oficial. Además, tiene una maduración de 16 meses que le otorga notas de corteza de pan, frutos secos y malta.
```

Mucho mejor que Prolog: explica el precio con datos de la base (D.O.P., 16 meses de maduración, pieza entera de 7,5 kg).

### 19. ¿Tienen algún queso de cabra?

*Grupo: Lenguaje natural*

**Prolog** (Incorrecta):

```text
Tenemos 14 quesos:
• Parmigiano Reggiano D.O.P. 18 meses (Boni): $20.900, 360 g aprox.
• Grana Padano D.O.P. (Albiero): $43.800, 1 kg
• Pecorino Romano D.O.P. (Pinna): $8.365, 200 g
• Pecorino 100% Sardo Barone (Maoddi): $10.800, 200 g aprox.
• Gorgonzola Dolce D.O.P. (Ghidetti): $11.390, 150 g
• Gorgonzola Piccante D.O.P. (Ghidetti): $11.390, vaschetta
• Formaggio Asiago D.O.P. (Albiero): $9.850, 300 g aprox.
• Formaggio Taleggio D.O.P. (Albiero): $10.350, 200 g (agotado)
• Provolone Valpadana D.O.P. Piccante (Albiero): $7.500, 200 g
• Mozzarella di Bufala Campana (congelada) (Corvino): $4.550, 125 g
• Burrata Murgella (congelada) (Murgella): $4.060, 120 g
• Mascarpone Fresco UHT (Virgilio): $11.450, 500 ml
• Ricotta Fresca (Ghidetti): $5.300, 295 g
• Provola dei Monti Affumicata (Latteria Sorrentina): $20.950, 780 g
```

Ignora la palabra desconocida "cabra" y lista todos los quesos sin decir que ninguno es de cabra.

**LLM** (Parcial):

```text
No tengo esa información en el catálogo
```

No inventa, pero tampoco dice claramente "no hay quesos de cabra"; responde que no tiene la información.

### 20. ¿Qué puedo cocinar si no como carne?

*Grupo: Lenguaje natural*

**Prolog** (Incorrecta):

```text
Con esos productos puedes preparar:
• Bucatini all'Amatriciana
• Spaghetti alla Carbonara
• Pasta e Patate alla Napoletana
```

No entiende la negación "no como carne": detecta "carne" y responde recetas **con** carne, lo contrario de lo pedido.

**LLM** (Correcta):

```text
Para preparar platos sin carne, tienes varias opciones de recetas en la base de conocimiento que no incluyen carnes ni embutidos:

• Risotto ai Funghi Porcini (Risotto de hongos porcini)
• Orecchiette al Pesto Trapanese (Orecchiette con pesto trapanese)
• Pesto alla Genovese casero
• Trofie al Pesto Genovese
• Pasta en ensalada de pesto y tomates cherry
• Linguine con Anchoas y Piñones
• Linguine Integrales con Pecorino y Nueces
• Tiramisù (Postre)
```

Entiende la negación y lista las recetas sin carne. Incluye la de anchoas, lo que es válido si "carne" no incluye pescado.

## 5. Análisis de desempeño

### 5.1 Versión Prolog

**Fortalezas**
- **Mejor en inferencia:** 8 de 10 correctas en el grupo de inferencia, y las otras 2 parciales. Las respuestas más valiosas no están escritas en ningún hecho: se deducen encadenando reglas (taxonomía, gluten con sustitución, maridaje, razonamiento por defecto).
- **Exacta y verificable:** nunca da un dato que no esté en la BC ni confunde un producto con otro, y cada conclusión se puede rastrear hasta los hechos y reglas que la producen.
- **Explica sus conclusiones:** "no es apto porque es un lácteo", "porque el lambrusco es el compañero clásico del cerdo".
- **Respuestas concretas:** nombra productos del catálogo con precio y formato.
- **Rápida, gratis y sin conexión:** responde al instante y no depende de un servicio externo.

**Debilidades**
- **Lenguaje natural limitado:** reconoce palabras clave, no el significado. Falla con la negación (20), con "por qué" (18) y con palabras desconocidas (19).
- **Respuestas rígidas:** muestra fichas en vez de redactar comparaciones (14) y aplica las reglas al pie de la letra aunque el resultado no tenga sentido práctico (9).
- **Todo debe escribirse a mano:** cada sinónimo, regla y tipo de pregunta nuevo requiere programarlo.

### 5.2 Versión LLM

**Fortalezas**
- **Entiende el lenguaje natural:** resolvió la negación (20) y el "por qué" (18), justo donde Prolog falla.
- **Redacta mejor:** las comparaciones (14) y explicaciones (18) se leen como las daría una persona.
- **Sentido común:** en el tiramisú (9) notó que un paquete de savoiardi no alcanza y que el café de 1 kg no se usa completo.
- **Desarrollo mínimo:** con unas 100 líneas de Python responde preguntas que en Prolog requerirían escribir intenciones nuevas.

**Debilidades**
- **Inferencia débil:** solo 5 de 10 correctas en inferencia. No dedujo que el gorgonzola es lácteo (6), no revisó los ingredientes para encontrar recetas vegetarianas (11) y no aplicó la sustitución sin gluten (8). Cuando la respuesta exige encadenar varios hechos, prefiere decir que no sabe.
- **Puede inventar:** en la 10 cambió el Grana Padano por Parmigiano Reggiano. Es un error difícil de detectar, porque la respuesta suena segura.
- **Respuestas menos concretas:** a veces habla de clases de vino en vez de productos con precio (7) o no entrega el dato pedido (el total en la 9).
- **No es reproducible:** la misma pregunta puede dar respuestas distintas en otro momento.
- **Depende de un servicio externo:** necesita conexión y una API key, y el plan gratuito tiene límites de uso. Durante las pruebas el modelo `gemini-3.8-flash` agotó su cuota diaria y hubo que usar `gemini-3.5-flash-lite`.

### 5.3 Comparación

Las dos versiones obtuvieron un número parecido de respuestas correctas, pero **fallan en cosas distintas**:

- **Prolog** razona bien y falla en **entender la pregunta**.
- **El LLM** entiende bien la pregunta y falla en **razonar sobre los datos**, y cuando falla puede hacerlo con seguridad (pregunta 10).

Ninguna de las dos responde la pregunta abierta (17). Ante algo que no está en la BC (16), ambas evitan inventar, pero Prolog además ofrece alternativas.

## 6. Conclusiones

1. **Prolog es más confiable dentro de su dominio.** Cuando responde, la respuesta se deduce de la BC y se puede explicar. Es la mejor opción cuando importa la exactitud: precios, stock, restricciones alimentarias.
2. **El LLM es más flexible con el lenguaje.** Entiende negaciones, preguntas de "por qué" y frases que nadie programó, pero no garantiza que la respuesta sea correcta, aunque tenga los datos delante.
3. **La calidad del conocimiento importa en ambas.** Las dos usaron los mismos hechos. Lo que cambia es cómo se usan: Prolog los combina con reglas explícitas, mientras que el LLM los "lee" y a veces no los conecta.
4. **Son complementarias.** Los puntos débiles de una son los fuertes de la otra, lo que motiva la propuesta 1 de la sección siguiente.

## 7. Propuestas de mejora

1. **Combinar ambas versiones:** usar el LLM solo para traducir la pregunta a una consulta Prolog y dejar que Prolog la responda. Se juntaría la comprensión del lenguaje del LLM con la exactitud y la explicación de Prolog.
2. **Entender la negación en Prolog:** detectar "no", "sin" y "excepto" antes de una entidad e invertir el filtro ("no como carne" → recetas vegetarianas).
3. **Avisar de palabras desconocidas:** si una palabra parece un producto pero no está en la BC ("cabra"), responder "no tengo productos de cabra" en vez de ignorarla.
4. **Dar las reglas al LLM:** además de los hechos, entregarle las reglas de inferencia (`reglas.pl`) o una explicación de ellas, para que pueda deducir lo que hoy no ve (lácteos, recetas vegetarianas).
5. **Validar las respuestas del LLM:** comprobar con Prolog que los productos y precios que menciona existen en la BC antes de mostrarlos.
6. **Comparaciones y costos más útiles en Prolog:** una regla `diferencia/3` que liste solo los atributos que cambian, y guardar la cantidad de cada envase para calcular el costo según lo que usa la receta.
7. **Actualizar el catálogo automáticamente:** generar `productos.pl` desde la API pública de la tienda (`/products.json`) para mantener precios y stock al día en ambas versiones.
