/*  lenguaje.pl
    Interpretación de la pregunta del usuario:
      1. normalizar/2  : texto -> lista de palabras (minúsculas, sin tildes)
      2. menciones/3   : qué productos, recetas, tipos, regiones... aparecen
      3. intencion/2   : qué se está preguntando (precio, maridaje, ...)
*/
:- encoding(utf8).

:- use_module(library(lists)).

/* ===================================================================
   1. Normalización
   =================================================================== */

normalizar(Texto, Palabras) :-
    string_lower(Texto, Minus),
    string_chars(Minus, Cs0),
    maplist(simplificar_char, Cs0, Cs),
    string_chars(Limpio, Cs),
    split_string(Limpio, " ", " ", Partes),
    findall(A, (member(S, Partes), S \== "", atom_string(A, S)), Palabras).

% Quita tildes y convierte todo lo que no sea letra o dígito en espacio.
simplificar_char(C, S) :- tilde(C, S), !.
simplificar_char(C, C) :- char_type(C, alnum), !.
simplificar_char(_, ' ').

tilde('á', a). tilde('é', e). tilde('í', i). tilde('ó', o). tilde('ú', u).
tilde('ü', u). tilde('ñ', n). tilde('à', a). tilde('è', e). tilde('ì', i).
tilde('ò', o). tilde('ù', u).

/* ===================================================================
   2. Reconocimiento de entidades
   =================================================================== */

% alias(?Clase, ?Id, -Palabras): una forma de nombrar la entidad.
alias(producto, Id, Ps) :- producto(Id, _, _, _, _), id_palabras(Id, Ps).
alias(receta,   Id, Ps) :- receta(Id, _, _, _),      id_palabras(Id, Ps).
alias(region,   Id, Ps) :- region_italiana(Id, _, _, _), id_palabras(Id, Ps).
alias(region,   Id, Ps) :- region_italiana(Id, Nombre, _, _), normalizar(Nombre, Ps).
alias(tipo,     Id, Ps) :- nombre_tipo(Id, Sing, _), normalizar(Sing, Ps).
alias(tipo,     Id, Ps) :- nombre_tipo(Id, _, Plur), normalizar(Plur, Ps).
alias(sello,    Id, [Id]) :- significado_sello(Id, _, _).
alias(zona,     Z,  [Z])  :- member(Z, [norte, centro, sur, islas]).
alias(leche,    A,  [A])  :- member(A, [vaca, oveja, bufala]).
alias(uva,      U,  Ps)   :- findall(X, uva(_, X), Us0), sort(Us0, Us),
                             member(U, Us), id_palabras(U, Ps).
alias(Clase,    Id, Ps)   :- sinonimo(Clase, Id, Texto), normalizar(Texto, Ps).

id_palabras(Id, Ps) :- atomic_list_concat(Ps, '_', Id).

% Una palabra del usuario coincide con una del alias, tolerando plurales.
coincide(P, P) :- !.
coincide(P, A) :- atom_concat(A, s, P), !.
coincide(P, A) :- atom_concat(A, es, P), !.
coincide(P, A) :- atom_concat(P, s, A).

% El alias aparece como secuencia contigua dentro de la pregunta.
aparece(Alias, Palabras) :-
    append(_, Resto, Palabras),
    prefijo_coincide(Alias, Resto), !.

prefijo_coincide([], _).
prefijo_coincide([A | As], [P | Ps]) :- coincide(P, A), prefijo_coincide(As, Ps).

% menciones(+Palabras, +Clase, -Ids): entidades de la clase mencionadas.
% Si varias coinciden, se quedan las de alias más largo ("pecorino romano"
% gana sobre "pecorino"). Si empatan, se devuelven todas.
menciones(Palabras, Clase, Ids) :-
    findall(N-Id, ( alias(Clase, Id, Alias),
                    aparece(Alias, Palabras),
                    length(Alias, N) ), Pares),
    (   Pares == []
    ->  Ids = []
    ;   findall(N, member(N-_, Pares), Largos),
        max_list(Largos, Max),
        findall(Id, member(Max-Id, Pares), Ids0),
        sort(Ids0, Ids)
    ).

menciona(Palabras, Clase, Id) :-
    menciones(Palabras, Clase, Ids), member(Id, Ids).

% productos_mencionados(+Palabras, -Ps): productos nombrados o, si no hay,
% todos los productos del tipo nombrado ("quesos azules").
productos_mencionados(Palabras, Ps) :-
    menciones(Palabras, producto, Ps), Ps \== [], !.
productos_mencionados(Palabras, Ps) :-
    menciones(Palabras, tipo, [T | _]), !,
    productos_de_tipo(T, Ps).
productos_mencionados(_, []).

% Alguna palabra de la lista aparece en la pregunta.
dice(Palabras, Claves) :-
    member(C, Claves), member(P, Palabras), coincide(P, C), !.

/* ===================================================================
   3. Intenciones
   Se prueban en orden; gana la primera que aplica.
   =================================================================== */

intencion([], ayuda) :- !.
intencion(W, Int) :- once(intencion_(W, Int)).

intencion_(W, despedida) :-
    dice(W, [gracias, chao, adios, bye]).

intencion_(W, ayuda) :-
    dice(W, [ayuda, ayudame, puedes, sabes, hola, buenas, menu, opciones]),
    menciones(W, producto, []), menciones(W, receta, []), menciones(W, tipo, []).

% "¿Qué significa D.O.P.?"  "¿Diferencia entre DOC y DOCG?"
intencion_(W, explicar_sello(Ss)) :-
    menciones(W, sello, Ss0), Ss0 \== [],
    menciones(W, producto, []),
    dice(W, [significa, significado, que, quiere, explica, diferencia, sigla]),
    \+ dice(W, [productos, cuales, tienen, hay]),
    todas_las_menciones(W, sello, Ss).

% "¿Qué vino va con la carbonara?"  "¿Con qué vino acompaño el gorgonzola?"
intencion_(W, maridaje_receta(R)) :-
    dice(W, [vino, maridaje, maridar, marida, acompanar, acompana, acompano, beber, tomar]),
    menciona(W, receta, R).
intencion_(W, maridaje_producto(P)) :-
    dice(W, [vino, maridaje, maridar, marida, acompanar, acompana, acompano, beber, tomar]),
    productos_mencionados(W, [P | _]), \+ es_un(P, vino).
intencion_(W, maridaje_desconocido) :-
    (   dice(W, [maridaje, maridar, marida, acompanar, acompana, acompano])
    ;   dice(W, [vino]), memberchk(con, W)
    ),
    menciones(W, producto, []), menciones(W, receta, []).

% "¿Con qué combina el parmigiano?"
intencion_(W, combinaciones(P)) :-
    dice(W, [combina, combinan, combinar, combino, juntar]),
    menciona(W, producto, P).

% Restricciones alimentarias
intencion_(W, recetas_filtro(vegetariano)) :-
    dice(W, [receta, recetas, plato, platos]), menciones(W, receta, []),
    dice(W, [vegetariano, vegetariana, vegetarianos, vegetarianas]).
intencion_(W, recetas_filtro(sin_gluten)) :-
    dice(W, [receta, recetas, plato, platos]), menciones(W, receta, []),
    dice(W, [gluten, celiaco, celiaca, celiaquia]).
intencion_(W, gluten_receta(R)) :-
    dice(W, [gluten, celiaco, celiaca, celiaquia]),
    menciona(W, receta, R).
intencion_(W, gluten(Ps)) :-
    dice(W, [gluten, celiaco, celiaca, celiaquia]),
    productos_mencionados(W, Ps).
intencion_(W, lactosa(Ps)) :-
    dice(W, [lactosa, intolerante, lacteos]),
    \+ menciona(W, receta, _),
    productos_mencionados(W, Ps).
intencion_(W, vegetariano_receta(R)) :-
    dice(W, [vegetariano, vegetariana, vegetarianos, vegetarianas]),
    menciona(W, receta, R).
intencion_(W, vegetariano(Ps)) :-
    dice(W, [vegetariano, vegetariana, vegetarianos, vegetarianas]),
    productos_mencionados(W, Ps).
intencion_(W, picante(Ps)) :-
    dice(W, [picante, picantes, pica, picoso]),
    productos_mencionados(W, Ps).
intencion_(W, ahumados) :-
    dice(W, [ahumado, ahumada, affumicato, affumicata]).

% Recetas
intencion_(W, recetas_region(Reg)) :-
    dice(W, [receta, recetas, plato, platos]),
    menciona(W, region, Reg),
    menciones(W, receta, []).
intencion_(W, recetas_con(Ps)) :-
    dice(W, [receta, recetas, preparar, cocinar, hacer, plato, platos, usar, ocupar]),
    menciones(W, receta, []),
    productos_mencionados(W, Ps), Ps \== [].
intencion_(W, costo_receta(R)) :-
    menciona(W, receta, R),
    dice(W, [cuesta, costo, cuanto, precio, presupuesto, sale, gastar, gasto, plata]).
intencion_(W, comprar_receta(R)) :-
    menciona(W, receta, R),
    dice(W, [comprar, disponible, stock, falta, faltan, agotado, tienda, hay, conseguir]).
intencion_(W, ingredientes(R)) :-
    menciona(W, receta, R),
    \+ ( menciones(W, producto, [_|_]),
         dice(W, [precio, cuesta, vale, origen, donde]) ).
intencion_(W, listar_recetas) :-
    dice(W, [receta, recetas]).

% Comparaciones y alternativas
intencion_(W, comparar(Ps)) :-
    dice(W, [diferencia, diferencias, comparar, compara, comparacion, versus, vs]),
    todas_las_menciones(W, producto, Ps), Ps = [_, _ | _].
intencion_(W, alternativas(P)) :-
    dice(W, [alternativa, reemplazar, reemplazo, sustituir, sustituto, parecido,
             similar, similares, cambiar, reemplazarlo, reemplazarla]),
    menciona(W, producto, P).
intencion_(W, mas_barato(T)) :-
    dice(W, [barato, barata, economico, economica]),
    tipo_o_todo(W, T).
intencion_(W, mas_caro(T)) :-
    dice(W, [caro, cara, costoso, costosa, exclusivo]),
    tipo_o_todo(W, T).

% Atributos de productos
intencion_(W, por_leche(A)) :-
    menciona(W, leche, A),
    menciones(W, producto, []).
intencion_(W, leche(Ps)) :-
    dice(W, [leche, animal, carne]),
    productos_mencionados(W, Ps), Ps \== [].
intencion_(W, por_uva(U)) :-
    menciona(W, uva, U),
    menciones(W, producto, []).
intencion_(W, uva(Ps)) :-
    dice(W, [uva, cepa, cepas]),
    productos_mencionados(W, Ps), Ps \== [].
intencion_(W, maduracion(Ps)) :-
    dice(W, [maduracion, madura, maduro, curado, curacion, envejecido, meses]),
    productos_mencionados(W, Ps), Ps \== [].
intencion_(W, coccion(Ps)) :-
    dice(W, [coccion, cocer, cocinar, minutos, tiempo, demora, hervir]),
    productos_mencionados(W, Ps), Ps \== [].
intencion_(W, alcohol(Ps)) :-
    dice(W, [grado, alcohol, alcoholico, alcoholica]),
    menciones(W, producto, Ps), Ps \== [].
intencion_(W, sello_producto(Ps)) :-
    (   dice(W, [sello, denominacion, certificacion])
    ;   menciona(W, sello, _)
    ),
    menciones(W, producto, Ps), Ps \== [].
intencion_(W, por_sello(S, T)) :-
    menciona(W, sello, S),
    tipo_o_todo(W, T).
intencion_(W, origen(Ps)) :-
    dice(W, [donde, origen, region, viene, vienen, proviene, procedencia, zona, hace, produce]),
    menciones(W, producto, Ps), Ps \== [].
intencion_(W, por_zona(Z, T)) :-
    menciona(W, zona, Z),
    menciones(W, producto, []),
    tipo_o_todo(W, T).
intencion_(W, por_region(R, T)) :-
    menciona(W, region, R),
    menciones(W, producto, []),
    tipo_o_todo(W, T).

intencion_(W, precio(Ps)) :-
    dice(W, [precio, cuesta, cuestan, vale, valen, valor, cuanto, cuanta]),
    productos_mencionados(W, Ps), Ps \== [].
intencion_(W, agotados) :-
    dice(W, [agotado, agotada, agotados, agotadas]),
    menciones(W, producto, []).
intencion_(W, disponibilidad(Ps)) :-
    dice(W, [stock, disponible, disponibles, agotado, agotada, hay, quedan, queda]),
    productos_mencionados(W, Ps), Ps \== [].
% Si solo se nombra algo, se muestra su ficha.
intencion_(W, ficha(Ps)) :-
    menciones(W, producto, Ps), Ps \== [].
intencion_(W, listar_tipo(T)) :-
    menciona(W, tipo, T).
intencion_(_, no_entiendo).

% Auxiliares ------------------------------------------------------------

% Todas las entidades de una clase, sin quedarse solo con las más largas
% (para "diferencia entre parmigiano y grana padano").
todas_las_menciones(W, Clase, Ids) :-
    findall(Id, ( alias(Clase, Id, Alias), aparece(Alias, W) ), Ids0),
    sort(Ids0, Ids).

tipo_o_todo(W, T) :- menciona(W, tipo, T), !.
tipo_o_todo(_, todo).
