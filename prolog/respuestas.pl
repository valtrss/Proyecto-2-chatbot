/*  respuestas.pl
    Convierte cada intención (lenguaje.pl) en un texto de respuesta,
    consultando la base de conocimiento y las reglas.
*/
:- encoding(utf8).

:- use_module(library(lists)).

:- discontiguous respuesta/2.

/* ===================================================================
   Utilidades de formato
   =================================================================== */

% 20900 -> "$20.900"
precio_texto(N, Texto) :-
    format(atom(A), '~D', [N]),
    atomic_list_concat(Partes, ',', A),
    atomic_list_concat(Partes, '.', B),
    format(string(Texto), "$~w", [B]).

% ["a","b","c"] -> "a, b y c"
enumerar([], "").
enumerar([X], S) :- !, format(string(S), "~w", [X]).
enumerar(Xs, S) :-
    append(Init, [Ult], Xs),
    atomic_list_concat(Init, ', ', A),
    format(string(S), "~w y ~w", [A, Ult]).

% Agrega punto final solo si el texto no termina ya en punto ("D.O.P.").
con_punto(S, S) :- sub_string(S, _, 1, 0, "."), !.
con_punto(S, S2) :- string_concat(S, ".", S2).

lineas(Lineas, Texto) :- atomic_list_concat(Lineas, '\n', A), atom_string(A, Texto).

linea_producto(P, Linea) :-
    producto(P, Nombre, Marca, Precio, Formato),
    precio_texto(Precio, PT),
    ( agotado(P) -> Extra = " (agotado)" ; Extra = "" ),
    format(string(Linea), "• ~w (~w): ~w, ~w~w", [Nombre, Marca, PT, Formato, Extra]).

lista_productos(Ps, Texto) :-
    maplist(linea_producto, Ps, Ls), lineas(Ls, Texto).

nombre_region(R, N) :- region_italiana(R, N, _, _), !.
nombre_region(R, R).

nombre_zona(norte,  "el norte de Italia").
nombre_zona(centro, "el centro de Italia").
nombre_zona(sur,    "el sur de Italia").
nombre_zona(islas,  "las islas").

zona_con_de(norte,  "del norte de Italia").
zona_con_de(centro, "del centro de Italia").
zona_con_de(sur,    "del sur de Italia").
zona_con_de(islas,  "de las islas (Sicilia y Cerdeña)").

nombre_sello(S, Sigla) :- significado_sello(S, Sigla, _), !.

nombre_tipo_sing(todo, "producto") :- !.
nombre_tipo_sing(T, S) :- nombre_tipo(T, S, _), !.
nombre_tipo_sing(T, T).
nombre_tipo_plur(todo, "productos") :- !.
nombre_tipo_plur(T, S) :- nombre_tipo(T, _, S), !.
nombre_tipo_plur(T, T).

nombre_ingrediente(I, N) :- producto(I, N, _, _, _), !.
nombre_ingrediente(I, N) :- basico(I, N), !.
nombre_ingrediente(I, N) :- nombre_tipo(I, N, _), !.
nombre_ingrediente(I, N) :-
    atomic_list_concat(Ps, '_', I), atomic_list_concat(Ps, ' ', N).

nombre_receta(R, N) :- receta(R, N, _, _).

nombre_uva(U, N) :- atomic_list_concat(Ps, '_', U), atomic_list_concat(Ps, ' ', A),
                    atom_string(A, N0), capitalizar(N0, N).

capitalizar(S, C) :-
    sub_string(S, 0, 1, _, Pri), sub_string(S, 1, _, 0, Resto),
    string_upper(Pri, PriM), string_concat(PriM, Resto, C).

% ["a","b"] -> "• a\n• b"
vinetas(Textos, Lista) :-
    findall(L, (member(X, Textos), format(string(L), "• ~w", [X])), Ls),
    lineas(Ls, Lista).

/* ===================================================================
   Respuestas por intención
   =================================================================== */

respuesta(ayuda, T) :-
    lineas([
      "¡Ciao! Soy el asistente de productos y cocina italiana (datos de gourmitalia.cl).",
      "Puedes preguntarme, por ejemplo:",
      "• ¿Cuánto cuesta el parmigiano?",
      "• ¿De qué región es la 'nduja?",
      "• ¿Qué vino va con la carbonara?",
      "• ¿Qué ingredientes lleva el risotto de hongos?",
      "• ¿Puedo hacer carbonara sin gluten?",
      "• ¿Cuánto cuesta preparar un tiramisú?",
      "• ¿Qué recetas puedo hacer con guanciale?",
      "• ¿Qué quesos son de leche de oveja?",
      "• ¿Qué significa D.O.P.?",
      "• ¿Qué diferencia hay entre el parmigiano y el grana padano?",
      "• ¿Qué productos son de Sicilia?"
    ], T).

respuesta(despedida, "¡Grazie a te! Buon appetito.").

respuesta(maridaje_desconocido, T) :-
    findall(N, receta(_, N, _, _), Rs), enumerar(Rs, LR),
    format(string(T), "No conozco ese plato. Puedo sugerir vino para estas recetas: ~w. También para quesos, embutidos y postres del catálogo, por ejemplo «¿qué vino va con el gorgonzola?».", [LR]).

respuesta(no_entiendo, T) :-
    lineas([
      "Perdón, no entendí la pregunta.",
      "Prueba nombrando un producto, una receta o una región, por ejemplo: «¿Qué vino va con la carbonara?» o «¿Qué quesos son D.O.P.?». Escribe «ayuda» para ver más ejemplos."
    ], T).

% --- Sellos -------------------------------------------------------------
respuesta(explicar_sello(Ss), T) :-
    findall(L, ( member(S, Ss), significado_sello(S, Sigla, Exp),
                 format(string(L0), "~w = ~w", [Sigla, Exp]), con_punto(L0, L) ), Ls),
    lineas(Ls, T).

respuesta(sello_producto(Ps), T) :-
    findall(L, ( member(P, Ps), nombre(P, N),
                 (   sello(P, S)
                 ->  significado_sello(S, Sigla, _),
                     format(string(L), "• Sí, ~w tiene sello ~w", [N, Sigla])
                 ;   format(string(L), "• ~w no tiene sello de origen registrado.", [N])
                 ) ), Ls),
    lineas(Ls, T).

respuesta(por_sello(S, Tipo), T) :-
    significado_sello(S, Sigla, Exp),
    productos_con_sello(Tipo, S, Ps),
    lista_productos(Ps, Lista),
    length(Ps, N),
    format(string(T), "~w (~w).~nHay ~w productos con este sello:~n~w", [Sigla, Exp, N, Lista]).

% --- Maridaje -----------------------------------------------------------
respuesta(maridaje_receta(R), T) :-
    nombre_receta(R, NR),
    sugerencias_vino_receta(R, Sug),
    (   Sug == []
    ->  format(string(T), "No tengo una sugerencia de vino para ~w.", [NR])
    ;   receta(R, _, Reg, _),
        lineas_vino(Sug, Reg, 3, Ls), lineas(Ls, Lista),
        format(string(T), "Para ~w te sugiero:~n~w", [NR, Lista])
    ).

respuesta(maridaje_producto(P), T) :-
    nombre(P, NP),
    sugerencias_vino_producto(P, Sug),
    (   Sug == []
    ->  format(string(T), "No tengo una regla de maridaje para ~w.", [NP])
    ;   ( region(P, Reg) -> true ; Reg = ninguna ),
        lineas_vino(Sug, Reg, 3, Ls), lineas(Ls, Lista),
        format(string(T), "Para acompañar ~w te sugiero:~n~w", [NP, Lista])
    ).

lineas_vino(Sug, Reg, Max, Ls) :-
    length(Sug, Len), N is min(Len, Max), length(Top, N), append(Top, _, Sug),
    findall(L, ( member(V-Razon, Top), linea_producto(V, LP),
                 ( region(V, Reg) -> Nota = ", y es de la misma región del plato" ; Nota = "" ),
                 format(string(L), "~w~n   porque ~w~w.", [LP, Razon, Nota]) ), Ls).

% --- Combinaciones -------------------------------------------------------
respuesta(combinaciones(P), T) :-
    nombre(P, N),
    findall(Q, se_combinan(P, Q), Qs),
    (   Qs == []
    ->  format(string(T), "No tengo combinaciones registradas para ~w.", [N])
    ;   lista_productos(Qs, L),
        format(string(T), "~w combina bien con:~n~w", [N, L])
    ).

% --- Gluten, lactosa, vegetariano, picante ------------------------------
respuesta(gluten([]), T) :- !,
    findall(P, apto_celiaco(P), Ps), length(Ps, N),
    findall(P, sin_gluten(P), Decl), maplist(nombre, Decl, Ns), enumerar(Ns, Lista),
    format(string(T), "~w productos del catálogo son aptos para celíacos. Los que el fabricante declara sin gluten son: ~w. Además, los quesos, vinos, arroces, tomates en conserva y aceites no llevan gluten por naturaleza. Pregunta por un tipo, por ejemplo «¿qué pastas son sin gluten?».", [N, Lista]).
respuesta(gluten([P]), T) :- !,
    nombre(P, N), estado_gluten(P, Apto, Razon),
    texto_apto(Apto, "apto para celíacos", TA),
    format(string(T), "~w: ~w, porque ~w.", [N, TA, Razon]).
respuesta(gluten([P1, P2 | Resto]), T) :-
    length([P1, P2 | Resto], N), N =< 3, !,
    findall(L, ( member(P, [P1, P2 | Resto]), nombre(P, Nom), estado_gluten(P, Apto, Razon),
                 texto_apto(Apto, "apto para celíacos", TA),
                 format(string(L), "• ~w: ~w, porque ~w.", [Nom, TA, Razon]) ), Ls),
    lineas(Ls, T).
respuesta(gluten(Ps), T) :-
    findall(P, (member(P, Ps), apto_celiaco(P)), Si),
    respuesta_filtro(Si, "sin gluten", T).

respuesta(gluten_receta(R), T) :-
    nombre_receta(R, NR),
    receta_sin_gluten(R, Plan, Problemas),
    findall(L, ( member(I-O, Plan), O \== ok, linea_plan(I, O, L) ), Ls),
    lineas(Ls, PlanTxt),
    (   Problemas == []
    ->  format(string(T), "Sí, puedes preparar ~w sin gluten con productos de la tienda:~n~w", [NR, PlanTxt])
    ;   maplist(nombre_ingrediente, Problemas, NPs), enumerar(NPs, PT),
        format(string(T), "Para ~w no encontré opción sin gluten para: ~w.~nLo demás se puede cubrir así:~n~w", [NR, PT, PlanTxt])
    ).

linea_plan(I, producto(P), L) :-
    nombre_ingrediente(I, NI), nombre(P, NP),
    ( I == P -> format(string(L), "• ~w (apto)", [NP])
    ;           format(string(L), "• ~w → ~w", [NI, NP]) ).
linea_plan(I, sustituto(S, P), L) :-
    nombre_ingrediente(I, NI), nombre_ingrediente(S, NS), nombre(P, NP),
    (   NS == NP
    ->  format(string(L), "• ~w → reemplazar por ~w, que sí es apto", [NI, NP])
    ;   format(string(L), "• ~w → reemplazar por ~w (~w), que sí es apto", [NI, NS, NP])
    ).

respuesta(lactosa([]), T) :- !,
    findall(P, sin_lactosa(P), Ps), maplist(nombre, Ps, Ns), enumerar(Ns, Lista),
    format(string(T), "Los lácteos contienen lactosa. Entre los embutidos, el fabricante declara sin lactosa: ~w. Los vinos, pastas, aceites y conservas tampoco tienen ingredientes lácteos.", [Lista]).
respuesta(lactosa([P]), T) :- !,
    nombre(P, N), estado_lactosa(P, Apto, Razon),
    texto_apto(Apto, "apto para intolerantes a la lactosa", TA),
    format(string(T), "~w: ~w, porque ~w.", [N, TA, Razon]).
respuesta(lactosa([P1, P2 | Resto]), T) :-
    length([P1, P2 | Resto], N), N =< 3, !,
    findall(L, ( member(P, [P1, P2 | Resto]), nombre(P, Nom), estado_lactosa(P, Apto, Razon),
                 texto_apto(Apto, "apto para intolerantes a la lactosa", TA),
                 format(string(L), "• ~w: ~w, porque ~w.", [Nom, TA, Razon]) ), Ls),
    lineas(Ls, T).
respuesta(lactosa(Ps), T) :-
    findall(P, (member(P, Ps), apto_sin_lactosa(P)), Si),
    respuesta_filtro(Si, "sin lactosa", T).

respuesta(vegetariano([P]), T) :- !,
    nombre(P, N),
    (   vegetariano(P)
    ->  format(string(T), "Sí, ~w es apto para vegetarianos (no es carne ni pescado).", [N])
    ;   ( animal_de(P, A) -> format(string(Extra), ", es carne de ~w", [A]) ; Extra = ", es pescado" ),
        format(string(T), "No, ~w no es vegetariano~w.", [N, Extra])
    ).
respuesta(vegetariano(Ps), T) :-
    ( Ps == [] -> findall(P, producto(P,_,_,_,_), Todos) ; Todos = Ps ),
    findall(P, (member(P, Todos), vegetariano(P)), Si),
    respuesta_filtro(Si, "aptos para vegetarianos", T).

respuesta(vegetariano_receta(R), T) :-
    nombre_receta(R, NR),
    findall(I, ( ingrediente(R, I, _), ingrediente_no_vegetariano(I) ), Is),
    (   Is == []
    ->  format(string(T), "Sí, la receta ~w es vegetariana: ninguno de sus ingredientes es carne o pescado.", [NR])
    ;   maplist(nombre_ingrediente, Is, Ns), enumerar(Ns, L),
        format(string(T), "No, la receta ~w lleva ~w.", [NR, L])
    ).

respuesta(picante([P]), T) :- !,
    nombre(P, N),
    ( picante(P) -> format(string(T), "Sí, ~w es picante.", [N])
    ;               format(string(T), "No, ~w no es picante.", [N]) ).
respuesta(picante(Ps), T) :-
    ( Ps == [] -> findall(P, producto(P,_,_,_,_), Todos) ; Todos = Ps ),
    findall(P, (member(P, Todos), picante(P)), Si),
    respuesta_filtro(Si, "picantes", T).

respuesta(ahumados, T) :-
    findall(P, ahumado(P), Ps),
    respuesta_filtro(Ps, "ahumados", T).

respuesta_filtro([], Desc, T) :- !,
    format(string(T), "No encontré productos ~w en ese grupo.", [Desc]).
respuesta_filtro(Ps, Desc, T) :-
    lista_productos(Ps, L), length(Ps, N),
    format(string(T), "Productos ~w (~w):~n~w", [Desc, N, L]).

texto_apto(si,       Desc, S) :- format(string(S), "sí es ~w", [Desc]).
texto_apto(no,       Desc, S) :- format(string(S), "no es ~w", [Desc]).
texto_apto(sin_info, _,    "no puedo asegurarlo").

% --- Recetas ------------------------------------------------------------
respuesta(recetas_filtro(Filtro), T) :-
    findall(N, ( receta(R, N, _, _), receta_cumple(Filtro, R) ), Ns),
    filtro_texto(Filtro, Desc),
    (   Ns == [] -> format(string(T), "No tengo recetas ~w.", [Desc])
    ;   vinetas(Ns, Lista),
        format(string(T), "Recetas ~w:~n~w", [Desc, Lista])
    ).

receta_cumple(vegetariano, R) :- receta_vegetariana(R).
receta_cumple(sin_gluten, R)  :- receta_sin_gluten(R, _, []).
filtro_texto(vegetariano, "vegetarianas").
filtro_texto(sin_gluten,  "que se pueden preparar sin gluten con productos de la tienda").

respuesta(listar_recetas, T) :-
    findall(L, ( receta(_, N, Reg, _),
                 ( Reg == ninguna -> format(string(L), "• ~w", [N])
                 ; nombre_region(Reg, NReg), format(string(L), "• ~w (~w)", [N, NReg]) ) ), Ls),
    lineas(Ls, Lista),
    format(string(T), "Conozco estas recetas:~n~w", [Lista]).

respuesta(ingredientes(R), T) :-
    receta(R, N, Reg, Fuente),
    findall(L, ( ingrediente(R, I, C), linea_ingrediente(I, C, L) ), Ls),
    lineas(Ls, Lista),
    ( Reg == ninguna -> Origen = "" ; nombre_region(Reg, NReg), format(string(Origen), " (plato típico de ~w)", [NReg]) ),
    ( Fuente == blog -> F = "receta del blog de gourmitalia.cl" ; F = "receta de conocimiento general" ),
    format(string(T), "~w~w lleva:~n~w~n(Fuente: ~w)", [N, Origen, Lista, F]).

linea_ingrediente(I, Cant, L) :-
    nombre_ingrediente(I, NI),
    clase_ingrediente(I, Clase),
    (   Clase == en_tienda, mejor_opcion(I, P), P \== I
    ->  nombre(P, NP), format(string(L), "• ~w: ~w → en la tienda: ~w", [NI, Cant, NP])
    ;   Clase == en_tienda, \+ mejor_opcion(I, _)
    ->  format(string(L), "• ~w: ~w (agotado en la tienda)", [NI, Cant])
    ;   Clase == no_vendido
    ->  format(string(L), "• ~w: ~w (la tienda no lo vende)", [NI, Cant])
    ;   format(string(L), "• ~w: ~w", [NI, Cant])
    ).

respuesta(costo_receta(R), T) :-
    nombre_receta(R, NR),
    costo_receta(R, Total, Detalle),
    findall(L, ( member(_-P-Pr, Detalle), nombre(P, NP), precio_texto(Pr, PT),
                 format(string(L), "• ~w: ~w", [NP, PT]) ), Ls),
    lineas(Ls, Lista), precio_texto(Total, TT),
    ingredientes_agotados(R, Ag), ingredientes_no_vendidos(R, NV),
    append(Ag, NV, Faltan),
    (   Faltan == [] -> Nota = ""
    ;   maplist(nombre_ingrediente, Faltan, NF), enumerar(NF, LF),
        format(string(Nota), "~nNo se incluye: ~w (no disponible en la tienda).", [LF])
    ),
    format(string(T), "Comprando la opción más barata de cada ingrediente, ~w cuesta ~w:~n~w~w~n(No incluye ingredientes básicos como huevos, sal o ajo.)", [NR, TT, Lista, Nota]).

respuesta(comprar_receta(R), T) :-
    nombre_receta(R, NR),
    ingredientes_agotados(R, Ag), ingredientes_no_vendidos(R, NV),
    (   receta_completa(R)
    ->  format(string(T), "Sí, la tienda tiene disponible todo lo necesario para ~w (aparte de ingredientes básicos como sal o huevos).", [NR])
    ;   append(Ag, NV, Faltan), maplist(nombre_ingrediente, Faltan, NF), enumerar(NF, LF),
        format(string(T), "No todo: para ~w falta ~w en la tienda.", [NR, LF])
    ).

respuesta(recetas_con(Ps), T) :-
    findall(R, ( member(P, Ps), recetas_con(P, R) ), Rs0), sort(Rs0, Rs),
    nombres_lista(Ps, NPs),
    (   Rs == []
    ->  format(string(T), "No conozco recetas que usen ~w.", [NPs])
    ;   maplist(nombre_receta, Rs, NRs), vinetas(NRs, Lista),
        format(string(T), "Con ~w puedes preparar:~n~w", [NPs, Lista])
    ).

respuesta(recetas_region(Reg), T) :-
    nombre_region(Reg, NReg),
    findall(N, receta(_, N, Reg, _), Ns),
    (   Ns == []
    ->  format(string(T), "No tengo recetas típicas de ~w.", [NReg])
    ;   vinetas(Ns, Lista),
        format(string(T), "Recetas típicas de ~w:~n~w", [NReg, Lista])
    ).

nombres_lista(Ps, Texto) :-
    length(Ps, N),
    (   N > 3 -> Texto = "esos productos"
    ;   maplist(nombre, Ps, Ns), enumerar(Ns, Texto)
    ).

% --- Comparar y alternativas --------------------------------------------
respuesta(comparar(Ps), T) :-
    maplist(ficha_texto, Ps, Fichas),
    atomic_list_concat(Fichas, '\n\n', A),
    format(string(T), "Comparación:~n~n~w", [A]).

respuesta(alternativas(P), T) :-
    nombre(P, N),
    alternativas(P, Qs),
    (   Qs == []
    ->  format(string(T), "No encontré alternativas disponibles para ~w.", [N])
    ;   lista_productos(Qs, L),
        precio(P, Pr), precio_texto(Pr, PT),
        format(string(T), "Alternativas a ~w (~w):~n~w", [N, PT, L])
    ).

respuesta(mas_barato(T0), T) :-
    nombre_tipo_sing(T0, NT),
    mas_barato(T0, P), !,
    linea_producto(P, L),
    format(string(T), "El ~w más barato disponible es:~n~w", [NT, L]).
respuesta(mas_barato(_), "No encontré productos disponibles de ese tipo.").

respuesta(mas_caro(T0), T) :-
    nombre_tipo_sing(T0, NT),
    mas_caro(T0, P), !,
    linea_producto(P, L),
    format(string(T), "El ~w más caro disponible es:~n~w", [NT, L]).
respuesta(mas_caro(_), "No encontré productos disponibles de ese tipo.").

% --- Atributos ----------------------------------------------------------
respuesta(precio(Ps), T) :-
    lista_productos(Ps, L),
    ( Ps = [_] -> Enc = "Precio" ; Enc = "Precios" ),
    format(string(T), "~w (gourmitalia.cl, octubre 2026):~n~w", [Enc, L]).

respuesta(disponibilidad(Ps), T) :-
    findall(L, ( member(P, Ps), nombre(P, N),
                 ( disponible(P) -> format(string(L), "• ~w: disponible", [N])
                 ; format(string(L), "• ~w: agotado", [N]) ) ), Ls),
    lineas(Ls, T).

respuesta(agotados, T) :-
    findall(P, agotado(P), Ps),
    respuesta_filtro(Ps, "agotados", T).

respuesta(por_leche(A), T) :-
    findall(P, leche(P, A), Ps),
    format(string(D), "de leche de ~w", [A]),
    respuesta_filtro(Ps, D, T).

respuesta(leche(Ps), T) :-
    findall(L, ( member(P, Ps), nombre(P, N), linea_animal(P, N, L) ), Ls),
    lineas(Ls, T).

linea_animal(P, N, L) :- leche(P, A), !, format(string(L), "• ~w: leche de ~w", [N, A]).
linea_animal(P, N, L) :- animal_de(P, A), !, format(string(L), "• ~w: carne de ~w", [N, A]).
linea_animal(_, N, L) :- format(string(L), "• ~w: no es un producto animal registrado", [N]).

respuesta(por_uva(U), T) :-
    findall(P, uva(P, U), Ps), nombre_uva(U, NU),
    format(string(D), "con uva ~w", [NU]),
    respuesta_filtro(Ps, D, T).

respuesta(uva(Ps), T) :-
    findall(L, ( member(P, Ps), es_un(P, vino), nombre(P, N),
                 findall(NU, (uva(P, U), nombre_uva(U, NU)), NUs), enumerar(NUs, LU),
                 format(string(L), "• ~w: ~w", [N, LU]) ), Ls0),
    ( Ls0 == [] -> T = "Ese producto no es un vino, así que no tiene uvas registradas." ; sort(Ls0, Ls), lineas(Ls, T) ).

respuesta(maduracion(Ps), T) :-
    findall(L, ( member(P, Ps), nombre(P, N),
                 ( maduracion(P, M) -> format(string(L), "• ~w: ~w de maduración", [N, M])
                 ; format(string(L), "• ~w: no tengo el dato de maduración", [N]) ) ), Ls),
    lineas(Ls, T).

respuesta(coccion(Ps), T) :-
    findall(L, ( member(P, Ps), coccion(P, M), nombre(P, N),
                 format(string(L), "• ~w: ~w minutos", [N, M]) ), Ls),
    ( Ls == [] -> T = "No tengo el tiempo de cocción de ese producto."
    ; lineas(Ls, Lista), format(string(T), "Tiempo de cocción:~n~w", [Lista]) ).

respuesta(alcohol(Ps), T) :-
    findall(L, ( member(P, Ps), grado_alcohol(P, G), nombre(P, N),
                 format(string(L), "• ~w: ~w% vol.", [N, G]) ), Ls),
    ( Ls == [] -> T = "No tengo el grado alcohólico de ese producto." ; lineas(Ls, T) ).

respuesta(origen(Ps), T) :-
    findall(L, ( member(P, Ps), nombre(P, N), linea_origen(P, N, L) ), Ls),
    lineas(Ls, T).

linea_origen(P, N, L) :-
    region(P, R), !,
    region_italiana(R, NR, Z, _), nombre_zona(Z, NZ),
    format(string(L), "• ~w viene de ~w, en ~w.", [N, NR, NZ]).
linea_origen(_, N, L) :-
    format(string(L), "• ~w: no tengo registrada su región de origen.", [N]).

respuesta(por_zona(Z, Tipo), T) :-
    zona_con_de(Z, NZ), nombre_tipo_plur(Tipo, NT),
    productos_de_zona(Tipo, Z, Ps),
    format(string(D), "~w (~w)", [NZ, NT]),
    respuesta_filtro(Ps, D, T).

respuesta(por_region(R, Tipo), T) :-
    region_italiana(R, NR, Z, Cap), nombre_zona(Z, NZ), nombre_tipo_plur(Tipo, NT),
    productos_de_region(Tipo, R, Ps),
    findall(N, receta(_, N, R, _), Rs),
    (   Ps == [] -> format(string(LP), "No tengo ~w de ~w en el catálogo.", [NT, NR])
    ;   lista_productos(Ps, L), length(Ps, Cant), capitalizar(NT, NTM),
        format(string(LP), "~w de ~w (~w):~n~w", [NTM, NR, Cant, L])
    ),
    (   Rs == [] -> LR = ""
    ;   enumerar(Rs, ER), format(string(LR), "~nRecetas típicas: ~w.", [ER])
    ),
    format(string(T), "~w está en ~w; su capital es ~w.~n~w~w", [NR, NZ, Cap, LP, LR]).

% --- Fichas y listados ---------------------------------------------------
respuesta(ficha(Ps), T) :-
    maplist(ficha_texto, Ps, Fichas),
    atomic_list_concat(Fichas, '\n\n', A), atom_string(A, T).

respuesta(listar_tipo(Tipo), T) :-
    productos_de_tipo(Tipo, Ps), nombre_tipo_plur(Tipo, NT),
    (   Ps == [] -> format(string(T), "No hay ~w en el catálogo.", [NT])
    ;   lista_productos(Ps, L), length(Ps, N),
        format(string(T), "Tenemos ~w ~w:~n~w", [N, NT, L])
    ).

% El tipo más específico del producto (el primero si hay varios).
tipo_principal(P, T) :-
    once(( tipo(P, T), \+ (tipo(P, T2), T2 \== T, hereda(T2, T)) )).

ficha_texto(P, Texto) :-
    linea_producto(P, Cab),
    findall(S, detalle(P, S), Ds),
    atomic_list_concat(Ds, ' ', Det),
    format(string(Texto), "~w~n~w", [Cab, Det]).

detalle(P, S) :- tipo_principal(P, T),
                 nombre_tipo_sing(T, NT), format(string(S), "Tipo: ~w.", [NT]).
detalle(P, S) :- region(P, R), region_italiana(R, NR, Z, _), nombre_zona(Z, NZ),
                 format(string(S), "Origen: ~w (~w).", [NR, NZ]).
detalle(P, S) :- sello(P, Se), nombre_sello(Se, Sigla),
                 format(string(S0), "Sello ~w", [Sigla]), con_punto(S0, S).
detalle(P, S) :- leche(P, A), format(string(S), "Leche de ~w.", [A]).
detalle(P, S) :- \+ leche(P, _), animal_de(P, A), format(string(S), "Carne de ~w.", [A]).
detalle(P, S) :- maduracion(P, M), format(string(S), "Maduración: ~w.", [M]).
detalle(P, S) :- findall(NU, (uva(P, U), nombre_uva(U, NU)), NUs), NUs \== [],
                 enumerar(NUs, L), format(string(S), "Uva: ~w.", [L]).
detalle(P, S) :- grado_alcohol(P, G), format(string(S), "~w% vol.", [G]).
detalle(P, S) :- coccion(P, M), format(string(S), "Cocción: ~w min.", [M]).
detalle(P, "Sin gluten.")         :- sin_gluten(P).
detalle(P, "Picante.")            :- picante(P).
detalle(P, "Ahumado.")            :- ahumado(P).
detalle(P, "Producto congelado.") :- congelado(P).
detalle(P, "Pasta al huevo.")     :- con_huevo(P).
detalle(P, "Integral.")           :- integral(P).
detalle(P, "Trafilada al bronce.") :- trafilada_bronce(P).
detalle(P, S) :- dato(P, D), format(string(S), "~w.", [D]).
