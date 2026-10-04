# Informe de desempeño del chatbot

Proyecto 2: *Diseño de un agente inteligente que usa conocimiento*. Fundamentos de Inteligencia Artificial, UNAB.

## 1. Dominio

Chatbot de **productos y cocina italiana** con datos de gourmitalia.cl. La explicación del dominio y del modelo en lógica de primer orden está en [dominio.md](dominio.md).

## 2. Metodología

Se eligieron 20 preguntas en tres grupos:

| Grupo | Preguntas | Qué evalúa |
|---|---|---|
| Consultas directas | 1–5 | recuperar un dato que está escrito en los hechos |
| Inferencia | 6–15 | deducir conocimiento nuevo con reglas (taxonomía, gluten, maridaje, recetas, razonamiento por defecto, simetría) |
| Fuera de la BC y lenguaje natural | 16–20 | preguntas sobre cosas que la BC no conoce, preguntas abiertas y formas de hablar difíciles (negación, "por qué") |

El tercer grupo se incluyó a propósito para encontrar los límites del chatbot.

Cada respuesta se clasifica como:

- **Correcta:** responde lo pedido y el contenido es verdadero según la fuente.
- **Parcial:** responde algo relacionado y verdadero, pero incompleto o poco útil.
- **Incorrecta:** responde algo falso o algo distinto de lo pedido.
- **No responde:** reconoce que no sabe o no entiende.

Las respuestas de Prolog se generaron con `swipl prolog/cli.pl "<pregunta>"` el 04-10-2026.

## 3. Resumen de resultados

| # | Pregunta | Grupo | Resultado |
|---|---|---|---|
| 1 | ¿Cuánto cuesta el parmigiano reggiano? | Consulta directa | Correcta |
| 2 | ¿De qué región es la 'nduja? | Consulta directa | Correcta |
| 3 | ¿Qué quesos son de leche de oveja? | Consulta directa | Correcta |
| 4 | ¿Qué significa D.O.P.? | Consulta directa | Correcta |
| 5 | ¿Cuánto tiempo de cocción tienen los paccheri? | Consulta directa | Correcta |
| 6 | ¿El gorgonzola tiene lactosa? | Inferencia | Correcta |
| 7 | ¿Qué vino va con la carbonara? | Inferencia | Correcta |
| 8 | ¿Puedo hacer carbonara sin gluten? | Inferencia | Correcta |
| 9 | ¿Cuánto cuesta preparar un tiramisú? | Inferencia | Parcial |
| 10 | ¿Puedo comprar todo para la pasta e patate? | Inferencia | Correcta |
| 11 | ¿Qué recetas son vegetarianas? | Inferencia | Correcta |
| 12 | ¿De qué animal es la bresaola? | Inferencia | Correcta |
| 13 | ¿Qué embutidos hay del sur? | Inferencia | Correcta |
| 14 | ¿Qué diferencia hay entre el pecorino romano y el pecorino sardo? | Inferencia | Parcial |
| 15 | ¿Con qué combina el parmigiano? | Inferencia | Correcta |
| 16 | ¿Qué vino va con la pizza? | Fuera de la BC | No responde |
| 17 | ¿Qué me recomiendas para una cena romántica? | Fuera de la BC | No responde |
| 18 | ¿Por qué el prosciutto San Daniele es tan caro? | Lenguaje natural | Incorrecta |
| 19 | ¿Tienen algún queso de cabra? | Lenguaje natural | Incorrecta |
| 20 | ¿Qué puedo cocinar si no como carne? | Lenguaje natural | Incorrecta |

**Versión Prolog:** 13 correctas, 2 parciales, 3 incorrectas y 2 sin respuesta.

| Grupo | Correctas |
|---|---|
| Consultas directas (1–5) | 5 de 5 |
| Inferencia (6–15) | 8 de 10 (2 parciales) |
| Fuera de la BC y lenguaje natural (16–20) | 0 de 5 |

## 4. Preguntas y respuestas

### 1. ¿Cuánto cuesta el parmigiano reggiano?

*Grupo: Consulta directa*

**Prolog** (Correcta):

```text
Precio (gourmitalia.cl, octubre 2026):
• Parmigiano Reggiano D.O.P. 18 meses (Boni): $20.900, 360 g aprox.
```

Dato tomado directamente de los hechos (`producto/5`). El sinónimo "parmigiano reggiano" se reconoce sin problemas.

### 2. ¿De qué región es la 'nduja?

*Grupo: Consulta directa*

**Prolog** (Correcta):

```text
• 'Nduja Piccante viene de Calabria, en el sur de Italia.
```

Combina `region/2` con `region_italiana/4` para agregar la zona (sur).

### 3. ¿Qué quesos son de leche de oveja?

*Grupo: Consulta directa*

**Prolog** (Correcta):

```text
Productos de leche de oveja (2):
• Pecorino Romano D.O.P. (Pinna): $8.365, 200 g
• Pecorino 100% Sardo Barone (Maoddi): $10.800, 200 g aprox.
```

Recorre todos los quesos con `leche(Q, oveja)`. Es una consulta con variable que devuelve todas las soluciones.

### 4. ¿Qué significa D.O.P.?

*Grupo: Consulta directa*

**Prolog** (Correcta):

```text
D.O.P. = Denominación de Origen Protegida: todo el proceso (producción, elaboración y maduración) ocurre en una zona geográfica delimitada y sigue un reglamento oficial.
```

Respuesta desde `significado_sello/3`. Entiende la sigla escrita con puntos.

### 5. ¿Cuánto tiempo de cocción tienen los paccheri?

*Grupo: Consulta directa*

**Prolog** (Correcta):

```text
Tiempo de cocción:
• Paccheri I.G.P. (Pasta di Gragnano): 13 minutos
```

Dato directo de `coccion/2`.

### 6. ¿El gorgonzola tiene lactosa?

*Grupo: Inferencia*

**Prolog** (Correcta):

```text
• Gorgonzola Dolce D.O.P.: no es apto para intolerantes a la lactosa, porque es un lácteo.
• Gorgonzola Piccante D.O.P.: no es apto para intolerantes a la lactosa, porque es un lácteo.
```

"Gorgonzola" es ambiguo (dolce y piccante), así que responde por ambos. Explica el motivo: la regla deduce que es lácteo por la taxonomía (`gorgonzola → queso_azul → queso → lacteo`).

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

Inferencia en varios pasos: perfil del plato → clase de vino → vinos del catálogo de esa clase, ordenados por región, stock y precio. Incluye la razón de cada sugerencia.

### 8. ¿Puedo hacer carbonara sin gluten?

*Grupo: Inferencia*

**Prolog** (Correcta):

```text
Sí, puedes preparar Spaghetti alla Carbonara sin gluten con productos de la tienda:
• spaghetti → Spaghetti Sin Gluten
• Guanciale Stagionato → reemplazar por Pancetta Delicattesse, que sí es apto
• Pecorino Romano D.O.P. (apto)
```

La regla busca un producto apto para cada ingrediente y, si no lo hay, usa un sustituto (guanciale → pancetta). Es la respuesta que mejor muestra el razonamiento.

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

El cálculo es correcto según la regla, pero suma envases completos: el café de 1 kg ($34.200) infla el total, aunque la receta usa solo 300 ml de café.

### 10. ¿Puedo comprar todo para la pasta e patate?

*Grupo: Inferencia*

**Prolog** (Correcta):

```text
No todo: para Pasta e Patate alla Napoletana falta Pasta Mista Dedicato Nº48 en la tienda.
```

Detecta que la pasta mista está agotada usando la negación por fallo (`\+ agotado(P)`).

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

Usa `receta_vegetariana/1`. Se considera correcta, aunque la regla no toma en cuenta el cuajo animal de los quesos.

### 12. ¿De qué animal es la bresaola?

*Grupo: Inferencia*

**Prolog** (Correcta):

```text
• Fior di Bresaola della Valtellina: carne de vacuno
```

Razonamiento por defecto: los embutidos son de cerdo salvo excepción, y la bresaola tiene el hecho `carne(bresaola, vacuno)`.

### 13. ¿Qué embutidos hay del sur?

*Grupo: Inferencia*

**Prolog** (Correcta):

```text
Productos del sur de Italia (embutidos) (2):
• 'Nduja Piccante (Corte Buona): $12.600, 400 g
• Salame Spianata Piccante (Negrini): $5.550, 100 g laminado
```

Cruza dos condiciones: tipo (embutido, por taxonomía) y zona (sur, a través de la región).

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

Muestra la ficha de cada queso, pero no resume las diferencias. El usuario tiene que compararlas por su cuenta (D.O.P. vs. sin sello, duro vs. semicurado).

### 15. ¿Con qué combina el parmigiano?

*Grupo: Inferencia*

**Prolog** (Correcta):

```text
Parmigiano Reggiano D.O.P. 18 meses combina bien con:
• Aceto Balsamico di Modena I.G.P. Invecchiato 3 Anni (Monari Federzoni): $15.950, 250 ml
```

La BC solo tiene `combina(parmigiano_reggiano, balsamico)`. La regla simétrica `se_combinan/2` permite responder en ambos sentidos.

### 16. ¿Qué vino va con la pizza?

*Grupo: Fuera de la BC*

**Prolog** (No responde):

```text
No conozco ese plato. Puedo sugerir vino para estas recetas: Spaghetti alla Carbonara, Bucatini all'Amatriciana, Risotto ai Funghi Porcini, Pasta e Patate alla Napoletana, Orecchiette al Pesto Trapanese, Pesto alla Genovese casero, Trofie al Pesto Genovese, Pasta en ensalada de pesto y tomates cherry, Linguine con Anchoas y Piñones, Linguine Integrales con Pecorino y Nueces y Tiramisù. También para quesos, embutidos y postres del catálogo, por ejemplo «¿qué vino va con el gorgonzola?».
```

La pizza no está en la BC. El bot lo reconoce y ofrece las alternativas que sí conoce, sin inventar.

### 17. ¿Qué me recomiendas para una cena romántica?

*Grupo: Fuera de la BC*

**Prolog** (No responde):

```text
Perdón, no entendí la pregunta.
Prueba nombrando un producto, una receta o una región, por ejemplo: «¿Qué vino va con la carbonara?» o «¿Qué quesos son D.O.P.?». Escribe «ayuda» para ver más ejemplos.
```

Pregunta abierta, sin productos ni recetas mencionados. El bot no tiene cómo interpretarla.

### 18. ¿Por qué el prosciutto San Daniele es tan caro?

*Grupo: Lenguaje natural*

**Prolog** (Incorrecta):

```text
El prosciutto más caro disponible es:
• Prosciutto Crudo San Daniele D.O.P. 16 meses (Principe): $450.000, pieza entera de 7,5 kg
```

Detecta "caro" y responde cuál es el prosciutto más caro, pero no explica el *porqué* (16 meses de maduración, D.O.P., pieza entera de 7,5 kg). La BC no tiene conocimiento causal sobre precios.

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

No hay quesos de cabra en la BC, pero el bot lista todos los quesos sin decir que ninguno es de cabra. "Cabra" no es una palabra conocida, así que la ignora.

### 20. ¿Qué puedo cocinar si no como carne?

*Grupo: Lenguaje natural*

**Prolog** (Incorrecta):

```text
Con esos productos puedes preparar:
• Bucatini all'Amatriciana
• Spaghetti alla Carbonara
• Pasta e Patate alla Napoletana
```

Error grave: no entiende la negación "no como carne". Detecta "carne" y responde recetas **con** carne, justo lo contrario de lo pedido.

## 5. Análisis de la versión Prolog

### Fortalezas

- **Exactitud en lo que sabe.** Las 15 preguntas sobre conocimiento modelado (grupos 1 y 2) se respondieron sin datos falsos. Prolog solo concluye lo que se deduce de la BC, así que no inventa precios ni productos.
- **Inferencia real.** Las respuestas más valiosas no están escritas en ningún hecho. Se deducen encadenando reglas: si un producto es lácteo (por la taxonomía), si una receta se puede hacer sin gluten (con sustitución de ingredientes), qué vino conviene (perfil → clase → vino) o si un embutido es de cerdo (razonamiento por defecto).
- **Explica sus conclusiones.** Cada respuesta de inferencia dice *por qué*, por ejemplo "porque es un lácteo" o "porque el lambrusco es el compañero clásico del cerdo".
- **Reconoce lo que no sabe.** Ante algo que no conoce (la pizza), lo dice y no inventa una respuesta.
- **Fácil de actualizar y verificar.** Cambiar un precio o agregar un producto es editar un hecho, y las pruebas automáticas comprueban que las reglas siguen funcionando.

### Debilidades

- **Lenguaje natural limitado.** El bot reconoce palabras clave y nombres conocidos, no el significado de la frase. Por eso falla con la negación (pregunta 20, la más grave), con "por qué" (18) y con palabras que no están en la BC (19).
- **No sabe decir "no hay".** Si se pregunta por algo que no existe (queso de cabra), ignora la palabra desconocida y responde algo más general en vez de decir que no hay.
- **Conocimiento cerrado.** Solo conoce 75 productos y 11 recetas. Las preguntas abiertas ("cena romántica") quedan fuera.
- **Respuestas rígidas.** Las comparaciones muestran fichas en vez de resumir diferencias (14), y los cálculos siguen la regla al pie de la letra aunque el resultado no sea útil (9).
- **Mantención manual.** Los precios y el stock son una foto del 02-10-2026, y cada sinónimo nuevo hay que escribirlo a mano.

## 6. Conclusiones

La versión Prolog es **confiable dentro de su dominio**: en las consultas directas y de inferencia no da datos falsos y explica sus conclusiones. Su punto débil es la **comprensión del lenguaje**, no el razonamiento. Las 5 preguntas sin una respuesta correcta tienen que ver con la forma de preguntar o con conocimiento que no está en la BC.

## 7. Propuestas de mejora

1. **Entender la negación:** detectar "no", "sin" y "excepto" antes de una entidad e invertir el filtro. Así, "no como carne" se convertiría en recetas vegetarianas.
2. **Avisar de palabras desconocidas:** si una palabra parece un producto pero no está en la BC ("cabra"), responder "no tengo productos de cabra" en vez de ignorarla.
3. **Comparaciones explícitas:** una regla `diferencia(P1, P2, Atributo)` que liste solo los atributos que cambian (sello, maduración, precio).
4. **Costo proporcional:** guardar la cantidad de cada envase para calcular el costo según lo que usa la receta, no por envase completo.
5. **Conocimiento causal:** hechos como `motivo_precio(P, Razon)` para responder preguntas de tipo "por qué".
6. **Actualizar el catálogo automáticamente:** generar `productos.pl` desde la API pública de la tienda (`/products.json`) para mantener precios y stock al día.
7. **Apoyarse en un modelo de lenguaje:** usar un LLM solo para traducir la pregunta a una consulta Prolog y dejar que Prolog responda. Así se juntaría la comprensión del lenguaje del LLM con la exactitud de la BC.
