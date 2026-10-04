/*  tests.pl
    Pruebas automáticas de la base de conocimiento y del chatbot.
        $ swipl -g run_tests -t halt tests.pl
*/
:- encoding(utf8).
:- ensure_loaded(chatbot).
:- use_module(library(plunit)).

:- begin_tests(reglas).

test(taxonomia_transitiva)        :- es_un(gorgonzola_dolce, queso).
test(herencia_multiple)           :- es_un(lambrusco_grasparossa, vino_tinto),
                                     es_un(lambrusco_grasparossa, vino_espumante).
test(animal_por_defecto)          :- animal_de(nduja, cerdo).
test(animal_excepcion)            :- animal_de(bresaola, vacuno).
test(pasta_contiene_gluten)       :- estado_gluten(spaghetti_gragnano, no, _).
test(pasta_sin_gluten_declarada)  :- apto_celiaco(spaghetti_sin_gluten).
test(queso_naturalmente_sin_gluten) :- apto_celiaco(grana_padano).
test(trazas_no_es_apto, [fail])   :- apto_celiaco(crema_pistacchio).
test(queso_tiene_lactosa, [fail]) :- apto_sin_lactosa(pecorino_romano).
test(agotado_no_disponible, [fail]) :- disponible(taleggio).
test(mas_barato_queso, [true(P == burrata)]) :- mas_barato(queso, P).
test(costo_carbonara, [true(T == 22015)]) :- costo_receta(carbonara, T, _).
test(receta_incompleta, [true(Is == [pasta_mista])]) :- ingredientes_agotados(pasta_e_patate, Is).
test(trofie_no_se_vende, [true(Is == [trofie])]) :- ingredientes_no_vendidos(trofie_pesto, Is).
test(carbonara_sin_gluten_con_sustituto) :-
    receta_sin_gluten(carbonara, Plan, []),
    memberchk(guanciale-sustituto(pancetta, pancetta), Plan).
test(maridaje_regional) :-
    sugerencias_vino_producto(gorgonzola_dolce, [vin_santo-_ | _]).

:- end_tests(reglas).

:- begin_tests(lenguaje).

intencion_de(Texto, I) :- normalizar(Texto, W), intencion(W, I).

test(normaliza_tildes, [true(W == [que, vino, va, con, la, carbonara])]) :-
    normalizar("¿Qué vino va con la carbonara?", W).
test(precio)      :- intencion_de("¿Cuánto cuesta el parmigiano?", precio([parmigiano_reggiano])).
test(sinonimo)    :- intencion_de("precio del parmesano", precio([parmigiano_reggiano])).
test(plural)      :- intencion_de("quesos azules", listar_tipo(queso_azul)).
test(maridaje)    :- intencion_de("¿Qué vino va con la carbonara?", maridaje_receta(carbonara)).
test(gluten_receta) :- intencion_de("¿puedo hacer carbonara sin gluten?", gluten_receta(carbonara)).
test(coccion)     :- intencion_de("¿cuánto demora en cocinarse los paccheri?", coccion([paccheri_gragnano])).
test(alias_largo) :- intencion_de("pecorino romano", ficha([pecorino_romano])).
test(ambiguo)     :- intencion_de("precio del chianti", precio([chianti_classico, chianti_riserva])).
test(zona)        :- intencion_de("¿qué embutidos hay del sur?", por_zona(sur, embutido)).
test(sello_puntos) :- intencion_de("¿Qué significa D.O.P.?", explicar_sello([dop])).
test(no_entiende) :- intencion_de("asdf qwerty", no_entiendo).

:- end_tests(lenguaje).
