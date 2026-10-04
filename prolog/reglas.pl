/*  reglas.pl
    Reglas de inferencia sobre la base de conocimiento (carpeta base/).
    Aquí no hay datos: solo conocimiento que se deduce de los hechos.
*/
:- encoding(utf8).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(aggregate)).

/* ===================================================================
   1. Clasificación (taxonomía transitiva)
   =================================================================== */

% hereda(+Tipo, ?Superior): Tipo es Superior o desciende de él.
hereda(T, T).
hereda(T, Sup) :- subtipo(T, Padre), hereda(Padre, Sup).

% es_un(?Producto, ?Tipo): el producto pertenece al tipo, directa o
% indirectamente. Ej.: es_un(gorgonzola_dolce, queso) es verdadero porque
% gorgonzola -> queso_azul -> queso.
es_un(P, T) :- tipo(P, T0), hereda(T0, T).

% productos_de_tipo(+Tipo, -Productos): lista sin repetidos.
productos_de_tipo(T, Ps) :-
    findall(P, (producto(P, _, _, _, _), once(es_un(P, T))), Ps).

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
mas_barato(T, P) :-
    aggregate_all(min(Pr, X), (es_un(X, T), disponible(X), precio(X, Pr)), min(_, P)).

mas_caro(T, P) :-
    aggregate_all(max(Pr, X), (es_un(X, T), disponible(X), precio(X, Pr)), max(_, P)).

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
    aggregate_all(min(Pr, X), (sirve_para(X, I), disponible(X), precio(X, Pr)), min(_, P)).

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
    foldl([_-_-Pr, A0, A]>>(A is A0 + Pr), Detalle, 0, Total).

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
    keysort(Pares0, Pares),
    pairs_values(Pares, Todos),
    sin_repetir_vino(Todos, Lista).

sugerencias_vino_producto(P, Lista) :-
    ( region(P, Reg) -> true ; Reg = ninguna ),
    findall(Pt-(V-Razon),
            ( vino_para_producto(P, V, Razon), puntaje_vino(Reg, V, Pt) ),
            Pares0),
    keysort(Pares0, Pares),
    pairs_values(Pares, Todos),
    sin_repetir_vino(Todos, Lista).

sin_repetir_vino([], []).
sin_repetir_vino([V-R | Resto], [V-R | Lista]) :-
    exclude([V2-_]>>(V2 == V), Resto, Resto2),
    sin_repetir_vino(Resto2, Lista).
