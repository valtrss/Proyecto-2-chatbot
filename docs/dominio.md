# Dominio y modelo del conocimiento

## 1. Dominio elegido

**Productos y cocina italiana**, con el catálogo de la tienda chilena
[gourmitalia.cl](https://gourmitalia.cl) como fuente principal.

El chatbot responde preguntas sobre:

- **Productos:** quesos, embutidos, vinos, licores, pastas, tomates, condimentos y dulces. Para cada uno conoce precio, formato, marca, región de origen, sello (D.O.P., I.G.P., D.O.C., …), tipo de leche, uvas, tiempo de cocción y stock.
- **Recetas:** las 9 del blog *Recetas de la Famiglia* del sitio, más dos clásicos (amatriciana y tiramisú).
- **Geografía gastronómica:** regiones de Italia, sus zonas y sus productos típicos.
- **Maridaje y combinaciones:** qué vino acompaña a cada plato o producto y qué productos se comen juntos.
- **Restricciones alimentarias:** gluten, lactosa y dieta vegetariana.

### Por qué lo elegimos

1. **No es un dominio informático** y es fácil de entender para cualquier persona.
2. **Tiene individuos, propiedades y relaciones claras:** un producto *es de* un tipo, *viene de* una región, una receta *lleva* ingredientes, un vino *acompaña* un plato. Esto permite escribir **reglas que infieren conocimiento nuevo**, más allá de consultar datos.
3. **Combina datos concretos** (precios, stock) con **conocimiento experto** (maridajes, sellos, qué alimentos tienen gluten). Así, el informe puede comparar cómo manejan ambos tipos de conocimiento la versión Prolog y la versión LLM.
4. **Hay una fuente real y verificable.** Todas las respuestas se pueden contrastar con el sitio.

> Los precios y el stock son una foto del catálogo tomada el **02-10-2026**.
> El chatbot no está afiliado a Gourmitalia; solo usa su información pública.

## 2. El agente basado en conocimiento

El chatbot es un **agente basado en lógica**:

- **Base de conocimiento (BC):** los hechos de `prolog/base/` (sentencias aceptadas como dadas, es decir, axiomas) más las reglas de `prolog/reglas.pl`.
- **Percepción:** la pregunta del usuario. `lenguaje.pl` la traduce a una consulta.
- **ASK:** el agente consulta la BC. Prolog **infiere** la respuesta por encadenamiento hacia atrás.
- **TELL:** para incorporar conocimiento nuevo se agregan hechos a la BC, por ejemplo un producto nuevo o un `agotado/1`, y se recarga con `make.`.
- **Acción:** se muestra la respuesta en texto.

```
pregunta → lenguaje.pl → ASK(BC, consulta) → inferencia (Prolog) → respuestas.pl → texto
```

## 3. Fase 1: dominio, constantes y predicados

### 3.1 Dominio (individuos)

| Grupo | Cantidad |
|---|---|
| Productos | 75 (de los ~500 del catálogo) |
| Tipos de producto | 76 |
| Regiones de Italia | 15 |
| Zonas | 4 (norte, centro, sur, islas) |
| Sellos de origen | 5 (D.O.P., I.G.P., D.O.C.G., D.O.C., I.G.T.) |
| Recetas | 11 |

Elegimos un subconjunto representativo de cada categoría para que la base sea fácil de leer y de modificar en vivo.

### 3.2 Constantes

Cada individuo se nombra con una constante en minúscula. Algunos ejemplos:

- **Productos:** `parmigiano_reggiano`, `pecorino_romano`, `gorgonzola_dolce`, `guanciale`, `nduja`, `chianti_classico`, `prosecco`, `spaghetti_gragnano`, `spaghetti_sin_gluten`, `pelati_san_marzano`, …
- **Tipos:** `queso`, `queso_azul`, `embutido`, `vino_tinto`, `vino_espumante`, `pasta_larga`, `tomate_en_conserva`, …
- **Regiones:** `lombardia`, `emilia_romana`, `toscana`, `lazio`, `campania`, `puglia`, `calabria`, `sicilia`, `cerdena`, …
- **Zonas:** `norte`, `centro`, `sur`, `islas`.
- **Sellos:** `dop`, `igp`, `docg`, `doc`, `igt`.
- **Recetas:** `carbonara`, `amatriciana`, `risotto_porcini`, `pasta_e_patate`, `tiramisu`, …
- **Ingredientes básicos** (que la tienda no vende): `huevo`, `sal`, `ajo`, `albahaca`, …

### 3.3 Predicados de la base (hechos)

| Predicado | Aridad | Representa |
|---|---|---|
| `producto(P, Nombre, Marca, Precio, Formato)` | 5 | P es un producto del catálogo, con sus datos |
| `tipo(P, T)` | 2 | P es directamente de tipo T |
| `subtipo(T1, T2)` | 2 | todo T1 es también un T2 |
| `region(P, R)` | 2 | P proviene de la región R |
| `region_italiana(R, Nombre, Zona, Capital)` | 4 | datos de la región R |
| `sello(P, S)` | 2 | P tiene el sello de origen S |
| `leche(P, A)` | 2 | el queso P es de leche del animal A |
| `uva(P, U)` | 2 | el vino P usa la uva U |
| `coccion(P, Min)` | 2 | la pasta P se cuece en Min minutos |
| `sin_gluten(P)`, `sin_lactosa(P)` | 1 | el fabricante declara P sin gluten o sin lactosa |
| `picante(P)`, `ahumado(P)`, `congelado(P)` | 1 | propiedades de P |
| `agotado(P)` | 1 | P no tiene stock |
| `carne(P, A)` | 2 | el embutido P es de un animal distinto del cerdo |
| `receta(R, Nombre, Region, Fuente)` | 4 | R es una receta |
| `ingrediente(R, I, Cantidad)` | 3 | la receta R lleva el ingrediente I |
| `basico(I, Nombre)` | 2 | I es un ingrediente que la tienda no vende |
| `sustituto(I, S)` | 2 | en una receta, I se puede reemplazar por S |
| `perfil(R, Perfil)` | 2 | rasgo del plato R (graso, tomate, pescado…) |
| `marida_perfil(Perfil, Clase, Razon)` | 3 | un plato con ese perfil va con esa clase de vino |
| `marida_tipo(T, Clase, Razon)` | 3 | un producto de tipo T va con esa clase de vino |
| `combina(P1, P2)` | 2 | P1 y P2 se comen juntos (escrito en un solo sentido) |

### 3.4 Predicados derivados (reglas)

| Predicado | Aridad | Representa |
|---|---|---|
| `es_un(P, T)` | 2 | P es de tipo T, directa o indirectamente |
| `hereda(T, S)` | 2 | el tipo T está bajo el tipo S en la jerarquía |
| `disponible(P)` | 1 | P está en el catálogo y no está agotado |
| `zona(P, Z)` | 2 | P viene de una región de la zona Z |
| `animal_de(P, A)` | 2 | el embutido P es carne del animal A |
| `apto_celiaco(P)` | 1 | P se puede comer sin gluten |
| `apto_sin_lactosa(P)` | 1 | P no tiene lactosa |
| `vegetariano(P)` | 1 | P no es carne ni pescado |
| `mas_barato(T, P)`, `mas_caro(T, P)` | 2 | P es el producto disponible más barato o más caro del tipo T |
| `alternativa(P, Q)` | 2 | Q es del mismo tipo que P y está disponible |
| `sirve_para(P, I)` | 2 | el producto P cubre el ingrediente I de una receta |
| `costo_receta(R, Total, Detalle)` | 3 | costo de comprar los ingredientes de R |
| `receta_completa(R)` | 1 | todo lo necesario para R está disponible |
| `receta_vegetariana(R)` | 1 | ningún ingrediente de R es carne ni pescado |
| `receta_sin_gluten(R, Plan, Problemas)` | 3 | cómo preparar R sin gluten |
| `vino_para_receta(R, V, Razon)` | 3 | el vino V acompaña la receta R |
| `misma_region(P1, P2)` | 2 | dos productos distintos de la misma región |
| `misma_marca(P1, P2)` | 2 | dos productos distintos de la misma marca |
| `se_combinan(P1, P2)` | 2 | P1 y P2 combinan, en cualquier orden |

## 4. Fase 2: hechos

Los hechos son fórmulas atómicas aplicadas a constantes. Ejemplo del bloque de un producto (`base/productos.pl`):

```prolog
producto(pecorino_romano, "Pecorino Romano D.O.P.", "Pinna", 8365, "200 g").
tipo(pecorino_romano, pecorino).
tipo(pecorino_romano, queso_duro).
region(pecorino_romano, cerdena).
sello(pecorino_romano, dop).
leche(pecorino_romano, oveja).
```

En lógica de primer orden: `Producto(pecorino_romano) ∧ Tipo(pecorino_romano, pecorino) ∧ Region(pecorino_romano, cerdena) ∧ Sello(pecorino_romano, dop) ∧ Leche(pecorino_romano, oveja)`.

## 5. Fase 3: reglas en lógica de primer orden

Cada regla se escribe primero en LPO y después en Prolog. En Prolog, la coma es "y" (∧) y el punto y coma o varias cláusulas son "o" (∨).

**Taxonomía: "todo producto de un tipo es también de sus tipos superiores".**

```
∀t  Hereda(t, t)
∀t ∀s ( ∃m (Subtipo(t, m) ∧ Hereda(m, s)) → Hereda(t, s) )
∀p ∀t ( ∃t0 (Tipo(p, t0) ∧ Hereda(t0, t)) → EsUn(p, t) )
```

```prolog
es_un(P, T) :- tipo(P, T0), hereda(T0, T).
```

Ejemplo: `gorgonzola_dolce → gorgonzola → queso_azul → queso → lacteo`. Hay herencia múltiple: el lambrusco es a la vez `vino_tinto` y `vino_espumante`. La regla lleva una lista de tipos visitados para no entrar en un ciclo infinito si alguien escribe por error `subtipo(a, b)` y `subtipo(b, a)`.

**"Todo producto que no es carne ni pescado es vegetariano".**

```
∀p ( Producto(p) ∧ ¬EsUn(p, carne) ∧ ¬EsUn(p, pescado) → Vegetariano(p) )
```

```prolog
vegetariano(P) :- producto(P, _, _, _, _), \+ es_un(P, carne), \+ es_un(P, pescado).
```

**"Una receta es vegetariana si no existe un ingrediente suyo que sea carne o pescado".**

```
∀r ( Receta(r) ∧ ¬∃i (Ingrediente(r, i) ∧ NoVegetariano(i)) → RecetaVegetariana(r) )
```

**"Dos productos distintos de la misma región"** (patrón "comparten un valor"):

```
∀x ∀y ( ∃r (Region(x, r) ∧ Region(y, r)) ∧ x ≠ y → MismaRegion(x, y) )
```

```prolog
misma_region(P1, P2) :- region(P1, R), region(P2, R), P1 \== P2.
```

Sin la condición `P1 \== P2`, todo producto sería "de la misma región" que sí mismo. La regla sería sintácticamente correcta, pero representaría mal el conocimiento.

**Relación simétrica: "si x combina con y, entonces y combina con x".** En la BC cada par se escribe una sola vez (`combina(parmigiano_reggiano, balsamico).`). Prolog no sabe que la relación es simétrica, así que hay que representarlo:

```
∀x ∀y ( Combina(x, y) ∨ Combina(y, x) → SeCombinan(x, y) )
```

```prolog
se_combinan(X, Y) :- combina(X, Y).
se_combinan(X, Y) :- combina(Y, X).
```

No se escribe `combina(X, Y) :- combina(Y, X)`, porque Prolog se llamaría a sí mismo sin fin.

**Gluten.** Las reglas se prueban en orden y la primera que aplica decide:
1. Si el fabricante lo declara sin gluten → **apto**.
2. Si el envase advierte trazas → **no apto**.
3. Si es de un tipo con gluten (pasta, harina, savoiardi) → **no apto**.
4. Si es de un tipo que naturalmente no lo tiene (queso, vino, arroz…) → **apto**.
5. En cualquier otro caso → **sin información**.

```
∀p ( ∃t (EsUn(p, t) ∧ TipoConGluten(t)) ∧ ¬SinGluten(p) → ¬AptoCeliaco(p) )
```

**Maridaje:**

```
∀r ∀v ( ∃pf ∃c (Perfil(r, pf) ∧ MaridaPerfil(pf, c) ∧ EsUn(v, vino) ∧ (EsUn(v, c) ∨ Uva(v, c))) → VinoPara(r, v) )
```

Las sugerencias se ordenan dando prioridad a los vinos de la **misma región** del plato, luego a los disponibles y luego a los más baratos.

**Recetas:**
- `sirve_para(P, I)`: el producto P cubre el ingrediente I, ya sea porque es exactamente ese producto o porque es de ese tipo.
- `costo_receta/3`: suma la opción disponible más barata de cada ingrediente.
- `receta_sin_gluten/3`: busca, para cada ingrediente, un producto apto para celíacos. Si no lo hay, prueba con un sustituto (por ejemplo, guanciale → pancetta).

### 5.1 Razonamiento por defecto

Las personas razonan con sentido común: sacan conclusiones provisorias que se retractan si llega información nueva. Nuestra BC hace lo mismo con los embutidos:

```prolog
animal_de(P, A)     :- carne(P, A), !.          % si se sabe el animal, se usa
animal_de(P, cerdo) :- es_un(P, embutido).      % si no, se asume cerdo
```

`animal_de(nduja, X)` da `X = cerdo` porque no hay información en contra. En cambio, para la bresaola existe el hecho `carne(bresaola, vacuno)`, y la conclusión por defecto ya no se aplica. Esto es **negación por fallo**: Prolog considera falso lo que no puede demostrar.

### 5.2 Explicación de las conclusiones

Como un sistema experto, el chatbot no solo responde sí o no: también dice **por qué**. Por ejemplo, la respuesta puede ser "no es apto para celíacos porque es pasta de trigo" o "sí es apto porque es queso, que naturalmente no lleva gluten". La razón sale de la regla que se usó para concluir.

## 6. Fase 4: cómo Prolog demuestra una consulta

### 6.1 Unificación

| Expresiones | ¿Unifican? | Sustitución o razón |
|---|---|---|
| `region(nduja, R)` y `region(nduja, calabria)` | Sí | `R := calabria` |
| `tipo(P, salame)` y `tipo(salame_milano, salame)` | Sí | `P := salame_milano` |
| `region(nduja, R)` y `sello(nduja, R)` | No | predicados distintos |
| `region(nduja, lazio)` y `region(nduja, calabria)` | No | `lazio` y `calabria` son constantes distintas |

### 6.2 Encadenamiento hacia atrás

Consulta: `?- es_un(gorgonzola_dolce, queso).`

| Paso | Meta | Qué hace Prolog | Resultado |
|---|---|---|---|
| 1 | `es_un(gorgonzola_dolce, queso)` | unifica con la regla `es_un(P, T) :- tipo(P, T0), hereda(T0, T)` | `P := gorgonzola_dolce`, `T := queso`; nuevas metas `tipo(gorgonzola_dolce, T0)` y `hereda(T0, queso)` |
| 2 | `tipo(gorgonzola_dolce, T0)` | unifica con el hecho `tipo(gorgonzola_dolce, gorgonzola)` | `T0 := gorgonzola` |
| 3 | `hereda(gorgonzola, queso)` | llama a `hereda/3` con la lista de visitados `[gorgonzola]`; la primera cláusula pide que ambos tipos sean iguales y falla; la segunda busca un padre | nueva meta `subtipo(gorgonzola, M)` |
| 4 | `subtipo(gorgonzola, M)` | unifica con el hecho `subtipo(gorgonzola, queso_azul)` | `M := queso_azul`; nueva meta `hereda(queso_azul, queso)` |
| 5 | `hereda(queso_azul, queso)` | busca un padre: `subtipo(queso_azul, queso)` | nueva meta `hereda(queso, queso)` |
| 6 | `hereda(queso, queso)` | unifica con la primera cláusula `hereda(T, T, _)` | **éxito** → `true` |

Con una variable, la misma consulta devuelve todas las sustituciones que la hacen verdadera:

```prolog
?- es_un(gorgonzola_dolce, X).
X = gorgonzola ; X = queso_azul ; X = queso ; X = lacteo.
```

## 7. Interpretación del lenguaje (`prolog/lenguaje.pl`)

1. **Normalización:** se pasa a minúsculas, se quitan las tildes y los signos, y se separa en palabras.
2. **Entidades:** se buscan los nombres de productos, recetas, tipos, regiones, sellos, uvas y tipos de leche. Se reconocen el identificador, el nombre del tipo en singular y plural, el nombre de la región y los sinónimos de `sinonimos.pl`. Se toleran plurales, y si dos nombres coinciden gana el más largo ("pecorino romano" gana sobre "pecorino").
3. **Intención:** reglas ordenadas por palabras clave más las entidades encontradas; gana la primera que aplica. Por ejemplo, "vino" más una receta da `maridaje_receta`.
4. **Respuesta** (`prolog/respuestas.pl`): cada intención consulta las reglas y arma el texto.

## 8. Límites del modelo

Una base de conocimiento es una **representación parcial** de la realidad, y las inferencias son tan buenas como el conocimiento modelado:

- **Precios y stock congelados:** son una foto del 02-10-2026. Si la tienda cambia un precio, la BC no se entera.
- **Catálogo parcial:** solo hay 75 de unos 500 productos. Si preguntan por algo que no está, el bot no lo conoce.
- **Vegetariano simplificado:** la regla no considera el cuajo animal de algunos quesos.
- **Gluten conservador:** si el fabricante no lo declara y el tipo no es claramente libre de gluten, el bot responde "no puedo asegurarlo".
- **Lenguaje limitado:** el bot entiende palabras clave y nombres conocidos, no cualquier frase. Una pregunta con palabras que no están en la BC no se entiende.
