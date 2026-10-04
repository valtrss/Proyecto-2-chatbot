/*  reglas.pl
    Reglas de inferencia sobre la base de conocimiento (carpeta base/).
    Aquí no hay datos: solo conocimiento que se deduce de los hechos.
*/
:- encoding(utf8).

:- use_module(library(lists)).

/* ===================================================================
   1. Clasificación (taxonomía transitiva)
   =================================================================== */

% hereda(+Tipo, ?Superior): Tipo es Superior o desciende de él.
% Se lleva la lista de tipos ya visitados para no caer en un ciclo infinito
% si alguien escribe por error subtipo(a, b) y subtipo(b, a).
hereda(T, Sup) :- hereda(T, Sup, [T]).

hereda(T, T, _).
hereda(T, Sup, Visitados) :-
    subtipo(T, Padre),
    \+ member(Padre, Visitados),
    hereda(Padre, Sup, [Padre | Visitados]).

% es_un(?Producto, ?Tipo): el producto pertenece al tipo, directa o
% indirectamente. Ej.: es_un(gorgonzola_dolce, queso) es verdadero porque
% gorgonzola -> queso_azul -> queso.
es_un(P, T) :- tipo(P, T0), hereda(T0, T).

% productos_de_tipo(+Tipo, -Productos): lista sin repetidos.
productos_de_tipo(T, Ps) :-
    findall(P, (producto(P, _, _, _, _), once(es_un(P, T))), Ps).

% cumple_tipo(?P, +T): P es de tipo T. El tipo especial "todo" acepta
% cualquier producto (se usa cuando la pregunta no nombra un tipo).
cumple_tipo(P, todo) :- producto(P, _, _, _, _).
cumple_tipo(P, T)    :- T \== todo, producto(P, _, _, _, _), once(es_un(P, T)).

% sirve_para(?Producto, +Ingrediente): el producto cubre ese ingrediente
% de una receta (el ingrediente es el producto mismo o un tipo).
sirve_para(P, P) :- producto(P, _, _, _, _).
sirve_para(P, I) :- \+ producto(I, _, _, _, _), es_un(P, I).

/* ===================================================================
   2. Datos derivados de cada producto
   =================================================================== */

precio(P, Precio)   :- producto(P, _, _, Precio, _).
nombre(P, Nombre)   :- producto(P, Nombre, _, _, _).
disponible(P)       :- producto(P, _, _, _, _), \+ agotado(P).

zona(P, Zona)       :- region(P, R), region_italiana(R, _, Zona, _).

% Por defecto los embutidos son de cerdo, salvo que se indique otra carne
% (razonamiento por defecto con negación por fallo).
animal_de(P, A)     :- carne(P, A), !.
animal_de(P, cerdo) :- es_un(P, embutido).

tiene_denominacion(P) :- sello(P, _).

/* ===================================================================
   3. Restricciones alimentarias
   =================================================================== */

% Tipos que por su naturaleza contienen gluten (trigo).
tipo_con_gluten(pasta).
tipo_con_gluten(harina).
tipo_con_gluten(savoiardi).

% Tipos que por su naturaleza no llevan gluten.
tipo_sin_gluten(queso).
tipo_sin_gluten(vino).
tipo_sin_gluten(licor).
tipo_sin_gluten(tomate_en_conserva).
tipo_sin_gluten(aceite_oliva).
tipo_sin_gluten(aceto_balsamico).
tipo_sin_gluten(peperoncino).
tipo_sin_gluten(arroz).
tipo_sin_gluten(hongo).
tipo_sin_gluten(conserva).
tipo_sin_gluten(fruto_seco).
tipo_sin_gluten(cafe).

% estado_gluten(+P, -Apto, -Razon): Apto = si | no | sin_info.
% Las cláusulas se prueban en orden y la primera que aplica corta el resto,
% por eso Apto debe llamarse sin instanciar (ver apto_celiaco/1).
estado_gluten(P, si, "el fabricante lo declara sin gluten") :-
    sin_gluten(P), !.
estado_gluten(P, no, "el envase advierte que puede contener trazas de gluten") :-
    trazas_gluten(P), !.
estado_gluten(P, no, Razon) :-
    tipo_con_gluten(T), es_un(P, T), !,
    nombre_tipo(T, Singular, _),
    format(string(Razon), "es ~w de trigo y contiene gluten", [Singular]).
estado_gluten(P, si, Razon) :-
    tipo_sin_gluten(T), es_un(P, T), !,
    nombre_tipo(T, Singular, _),
    format(string(Razon), "es ~w, que naturalmente no lleva gluten", [Singular]).
estado_gluten(_, sin_info, "no hay información del fabricante sobre gluten").

apto_celiaco(P) :- producto(P, _, _, _, _), estado_gluten(P, Apto, _), Apto == si.

% Lactosa: los lácteos la contienen salvo que se declare lo contrario.
estado_lactosa(P, si, "el fabricante lo declara sin lactosa") :-
    sin_lactosa(P), !.
estado_lactosa(P, no, "es un lácteo") :-
    es_un(P, lacteo), !.
estado_lactosa(P, sin_info, "no hay información del fabricante sobre lactosa") :-
    ( es_un(P, embutido) ; es_un(P, dulce) ; es_un(P, salsa) ), !.
estado_lactosa(_, si, "no es un lácteo ni tiene ingredientes lácteos").

apto_sin_lactosa(P) :- producto(P, _, _, _, _), estado_lactosa(P, Apto, _), Apto == si.

% Vegetariano: no es carne ni pescado.
vegetariano(P) :-
    producto(P, _, _, _, _),
    \+ es_un(P, carne),
    \+ es_un(P, pescado).

/* ===================================================================
   4. Precios y alternativas
   =================================================================== */

% mas_barato(+Tipo, -P): producto disponible más barato de un tipo.
% Se juntan pares Precio-Producto, se ordenan y se toma el primero.
mas_barato(T, P) :-
    findall(Pr-X, (cumple_tipo(X, T), disponible(X), precio(X, Pr)), Pares),
    sort(Pares, [_-P | _]).

mas_caro(T, P) :-
    findall(Pr-X, (cumple_tipo(X, T), disponible(X), precio(X, Pr)), Pares),
    sort(Pares, Ordenados),
    last(Ordenados, _-P).

% alternativa(+P, -Q): Q es del mismo tipo directo que P y está disponible.
alternativa(P, Q) :-
    tipo(P, T), tipo(Q, T), Q \== P, disponible(Q).

alternativas(P, Qs) :-
    setof(Q, alternativa(P, Q), Qs), !.
alternativas(_, []).

alternativa_mas_barata(P, Q) :-
    alternativa(P, Q), precio(P, PP), precio(Q, PQ), PQ < PP.

/* ===================================================================
   5. Recetas
   =================================================================== */

% Clasificación de cada ingrediente de una receta.
%   basico      -> no se vende (huevo, sal, ajo...)
%   en_tienda   -> hay al menos un producto que lo cubre
%   no_vendido  -> la tienda no tiene nada que lo cubra
clase_ingrediente(I, Clase) :-
    (   basico(I, _)      -> Clase0 = basico
    ;   sirve_para(_, I)  -> Clase0 = en_tienda
    ;   Clase0 = no_vendido
    ),
    Clase = Clase0.

% Opción más barata y disponible para un ingrediente.
mejor_opcion(I, P) :-
    findall(Pr-X, (sirve_para(X, I), disponible(X), precio(X, Pr)), Pares),
    sort(Pares, [_-P | _]).

% costo_receta(+R, -Total, -Detalle): suma una unidad de la opción más
% barata de cada ingrediente que vende la tienda. Detalle = [I-P-Precio].
costo_receta(R, Total, Detalle) :-
    receta(R, _, _, _),
    findall(I-P-Pr,
            ( ingrediente(R, I, _),
              clase_ingrediente(I, en_tienda),
              mejor_opcion(I, P),
              precio(P, Pr) ),
            Detalle),
    findall(Pr, member(_-_-Pr, Detalle), Precios),
    sum_list(Precios, Total).

% Ingredientes que la tienda vende pero cuyas opciones están agotadas.
ingredientes_agotados(R, Is) :-
    findall(I, ( ingrediente(R, I, _),
                 clase_ingrediente(I, en_tienda),
                 \+ mejor_opcion(I, _) ), Is).

ingredientes_no_vendidos(R, Is) :-
    findall(I, ( ingrediente(R, I, _), clase_ingrediente(I, no_vendido) ), Is).

% Se puede comprar todo lo necesario en la tienda (aparte de lo básico).
receta_completa(R) :-
    receta(R, _, _, _),
    ingredientes_agotados(R, []),
    ingredientes_no_vendidos(R, []).

% Un ingrediente no es vegetariano si lo cubre carne o pescado.
ingrediente_no_vegetariano(I) :-
    sirve_para(P, I), ( es_un(P, carne) ; es_un(P, pescado) ), !.

receta_vegetariana(R) :-
    receta(R, _, _, _),
    \+ ( ingrediente(R, I, _), ingrediente_no_vegetariano(I) ).

recetas_con(P, R) :-
    ingrediente(R, I, _), sirve_para(P, I).

/* ===================================================================
   6. Recetas sin gluten (con sustituciones)
   =================================================================== */

% opcion_celiaca(+I, -Resultado): cómo cubrir el ingrediente I sin gluten.
%   ok                 -> ingrediente básico, se asume sin gluten
%   producto(P)        -> un producto apto y disponible
%   sustituto(S, P)    -> se reemplaza I por S, usando el producto P
opcion_celiaca(I, ok) :- basico(I, _), !.
opcion_celiaca(I, producto(P)) :-
    sirve_para(P, I), disponible(P), apto_celiaco(P), !.
opcion_celiaca(I, sustituto(S, P)) :-
    sustituto(I, S), sirve_para(P, S), disponible(P), apto_celiaco(P), !.

% receta_sin_gluten(+R, -Plan, -Problemas)
%   Plan      = [I-Opcion] para los ingredientes que se pueden cubrir
%   Problemas = ingredientes sin opción apta para celíacos
receta_sin_gluten(R, Plan, Problemas) :-
    receta(R, _, _, _),
    findall(I-O, (ingrediente(R, I, _), opcion_celiaca(I, O)), Plan),
    findall(I, (ingrediente(R, I, _), \+ opcion_celiaca(I, _)), Problemas).

/* ===================================================================
   7. Maridaje
   =================================================================== */

% Un vino cumple una clase si es de ese tipo o si usa esa uva.
vino_cumple(V, Clase) :- es_un(V, Clase).
vino_cumple(V, Clase) :- uva(V, Clase).

vino_para_receta(R, V, Razon) :-
    perfil(R, Perfil),
    marida_perfil(Perfil, Clase, Razon),
    producto(V, _, _, _, _), es_un(V, vino),
    once(vino_cumple(V, Clase)).

vino_para_producto(P, V, Razon) :-
    marida_tipo(T, Clase, Razon),
    once(es_un(P, T)),
    producto(V, _, _, _, _), es_un(V, vino),
    once(vino_cumple(V, Clase)).

% Ordena las sugerencias: primero los vinos de la misma región del plato
% ("lo que crece junto, va junto"), luego los disponibles y luego por precio.
puntaje_vino(RegionPlato, V, Puntaje) :-
    ( region(V, RegionPlato) -> B1 = 0 ; B1 = 1 ),
    ( disponible(V)          -> B2 = 0 ; B2 = 1 ),
    precio(V, Pr),
    Puntaje = k(B1, B2, Pr).

sugerencias_vino_receta(R, Lista) :-
    receta(R, _, Reg, _),
    findall(Pt-(V-Razon),
            ( vino_para_receta(R, V, Razon), puntaje_vino(Reg, V, Pt) ),
            Pares0),
    msort(Pares0, Pares),
    quitar_claves(Pares, Todos),
    sin_repetir_vino(Todos, Lista).

sugerencias_vino_producto(P, Lista) :-
    ( region(P, Reg) -> true ; Reg = ninguna ),
    findall(Pt-(V-Razon),
            ( vino_para_producto(P, V, Razon), puntaje_vino(Reg, V, Pt) ),
            Pares0),
    msort(Pares0, Pares),
    quitar_claves(Pares, Todos),
    sin_repetir_vino(Todos, Lista).

% quitar_claves(+[Clave-Valor], -[Valor])
quitar_claves([], []).
quitar_claves([_-X | Resto], [X | Resto2]) :- quitar_claves(Resto, Resto2).

% Deja solo la primera sugerencia de cada vino (la de mejor puntaje).
sin_repetir_vino([], []).
sin_repetir_vino([V-R | Resto], [V-R | Lista]) :-
    quitar_vino(V, Resto, Resto2),
    sin_repetir_vino(Resto2, Lista).

quitar_vino(_, [], []).
quitar_vino(V, [V-_ | Resto], Resto2) :- !, quitar_vino(V, Resto, Resto2).
quitar_vino(V, [X | Resto], [X | Resto2]) :- quitar_vino(V, Resto, Resto2).

/* ===================================================================
   8. Relaciones entre productos
   =================================================================== */

% Dos productos distintos de la misma región.
misma_region(P1, P2) :-
    region(P1, R),
    region(P2, R),
    P1 \== P2.

% Dos productos distintos de la misma marca.
misma_marca(P1, P2) :-
    producto(P1, _, Marca, _, _),
    producto(P2, _, Marca, _, _),
    P1 \== P2.

% combina/2 (base/combinaciones.pl) se escribe en un solo sentido.
% "Combinar" es simétrico, así que la regla prueba ambos sentidos.
% No se escribe combina(X, Y) :- combina(Y, X) porque eso entra en un
% ciclo infinito.
se_combinan(X, Y) :- combina(X, Y).
se_combinan(X, Y) :- combina(Y, X).

% Listados por región, zona o sello, opcionalmente filtrados por tipo.
productos_de_region(T, R, Ps) :- findall(P, (cumple_tipo(P, T), region(P, R)), Ps).
productos_de_zona(T, Z, Ps)   :- findall(P, (cumple_tipo(P, T), zona(P, Z)), Ps).
productos_con_sello(T, S, Ps) :- findall(P, (cumple_tipo(P, T), sello(P, S)), Ps).
