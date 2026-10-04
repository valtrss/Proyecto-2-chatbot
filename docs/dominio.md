# Dominio y modelo del conocimiento

## 1. Dominio elegido

**Productos y cocina italiana**, con el catálogo de la tienda chilena
[gourmitalia.cl](https://gourmitalia.cl) como fuente principal.

El chatbot responde preguntas sobre:

- **Productos:** quesos, embutidos, vinos, licores, pastas, tomates, condimentos y dulces. Para cada uno conoce precio, formato, marca, región de origen, sello (D.O.P., I.G.P., D.O.C., …), tipo de leche, uvas, tiempo de cocción y stock.
- **Recetas:** las 9 del blog *Recetas de la Famiglia* del sitio, más dos clásicos (amatriciana y tiramisú).
- **Geografía gastronómica:** regiones de Italia, sus zonas y sus productos típicos.
- **Maridaje:** qué vino acompaña a cada plato o producto.
- **Restricciones alimentarias:** gluten, lactosa y dieta vegetariana.

### Por qué lo elegimos

1. **No es un dominio informático** y es fácil de entender para cualquier persona.
2. **Tiene entidades y relaciones claras:** producto → tipo → categoría, producto → región → zona, receta → ingredientes → productos, plato → perfil → vino. Esto permite escribir **reglas con inferencia real**, más allá de consultar datos.
3. **Combina datos concretos** (precios, stock) con **conocimiento experto** (maridajes, sellos, qué alimentos tienen gluten). Así, el informe puede comparar cómo manejan ambos tipos de conocimiento la versión Prolog y la versión LLM.
4. **Hay una fuente real y verificable.** Todas las respuestas se pueden contrastar con el sitio.

> Los precios y el stock son una foto del catálogo tomada el **02-10-2026**.
> El chatbot no está afiliado a Gourmitalia; solo usa su información pública.

## 2. Alcance de la base de conocimiento

| Elemento | Cantidad |
|---|---|
| Productos | 75 (de los ~500 del catálogo) |
| Tipos en la taxonomía | 76 |
| Regiones italianas | 15 |
| Recetas | 11 |
| Reglas de maridaje | 17 |
| Sinónimos | 113 |

Elegimos un subconjunto representativo de cada categoría para que la base sea fácil de leer y de modificar en vivo durante la interrogación.

## 3. Modelo en lógica de primer orden

### 3.1 Hechos (`prolog/base/`)

| Predicado | Significado |
|---|---|
| `producto(P, Nombre, Marca, Precio, Formato)` | P es un producto del catálogo |
| `tipo(P, T)` | P es directamente de tipo T |
| `subtipo(T1, T2)` | todo T1 es un T2 (taxonomía) |
| `region(P, R)` | P proviene de la región R |
| `region_italiana(R, Nombre, Zona, Capital)` | datos de la región |
| `sello(P, S)` | P tiene el sello de origen S |
| `leche(P, A)`, `uva(P, U)`, `coccion(P, Min)`, `maduracion(P, M)`, `grado_alcohol(P, G)` | atributos |
| `sin_gluten(P)`, `sin_lactosa(P)`, `picante(P)`, `ahumado(P)`, `agotado(P)`, … | propiedades |
| `receta(R, Nombre, Region, Fuente)`, `ingrediente(R, I, Cantidad)` | recetas |
| `perfil(R, Perfil)` | rasgo del plato (graso, tomate, pescado…) |
| `marida_perfil(Perfil, ClaseVino, Razon)`, `marida_tipo(T, ClaseVino, Razon)` | maridajes |
| `sustituto(I, S)` | I puede reemplazarse por S en una receta |

### 3.2 Reglas principales (`prolog/reglas.pl`)

**Taxonomía transitiva.** Un producto es de todos los tipos que están por encima del suyo:

```
∀P ∀T  es_un(P, T) ← ∃T0 (tipo(P, T0) ∧ hereda(T0, T))
∀T     hereda(T, T)
∀T ∀S  hereda(T, S) ← ∃M (subtipo(T, M) ∧ hereda(M, S))
```

Ejemplo: `gorgonzola_dolce → gorgonzola → queso_azul → queso → lacteo`.
La taxonomía admite herencia múltiple: el lambrusco es a la vez `vino_tinto` y `vino_espumante`.

**Razonamiento por defecto.** Un embutido es de cerdo salvo que se indique otra carne:

```
animal_de(P, A)     ← carne(P, A)
animal_de(P, cerdo) ← es_un(P, embutido) ∧ ¬∃A carne(P, A)
```

**Gluten**, con explicación del motivo. La primera regla que aplica decide:
1. Si el fabricante lo declara sin gluten → **apto**.
2. Si el envase advierte trazas → **no apto**.
3. Si es de un tipo con gluten (pasta, harina, savoiardi) → **no apto**.
4. Si es de un tipo que naturalmente no lo tiene (queso, vino, arroz…) → **apto**.
5. En cualquier otro caso → **sin información**.

**Recetas:**
- `sirve_para(P, I)`: el producto P cubre el ingrediente I, ya sea porque es exactamente ese producto o porque es de ese tipo.
- `costo_receta(R, Total, Detalle)`: suma la opción disponible más barata de cada ingrediente.
- `receta_completa(R)`: todo lo necesario está disponible en la tienda.
- `receta_sin_gluten(R, Plan, Problemas)`: busca, para cada ingrediente, un producto apto para celíacos. Si no lo hay, prueba con un sustituto (por ejemplo, guanciale → pancetta).

**Maridaje:**

```
vino_para_receta(R, V) ← perfil(R, Pf) ∧ marida_perfil(Pf, C, _) ∧ es_un(V, vino) ∧ (es_un(V, C) ∨ uva(V, C))
```

Las sugerencias se ordenan dando prioridad a los vinos de la **misma región** del plato, luego a los disponibles y luego a los más baratos.

### 3.3 Interpretación del lenguaje (`prolog/lenguaje.pl`)

1. **Normalización:** se pasa a minúsculas, se quitan las tildes y los signos, y se separa en palabras.
2. **Entidades:** se buscan los nombres de productos, recetas, tipos, regiones, sellos, uvas y tipos de leche. Se reconocen el identificador, el nombre del tipo en singular y plural, el nombre de la región y los sinónimos de `sinonimos.pl`. Se toleran plurales, y si dos nombres coinciden gana el más largo ("pecorino romano" gana sobre "pecorino").
3. **Intención:** reglas ordenadas por palabras clave más las entidades encontradas; gana la primera que aplica. Por ejemplo, "vino" más una receta da `maridaje_receta`, y "cuánto cuesta" más una receta da `costo_receta`.
4. **Respuesta** (`prolog/respuestas.pl`): cada intención consulta las reglas y arma el texto.
