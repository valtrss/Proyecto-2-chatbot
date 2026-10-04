/*  base.pl
    Carga la base de conocimiento completa (hechos + reglas).
    Desde swipl:  ?- [base].
*/
:- encoding(utf8).

:- ensure_loaded('base/productos').
:- ensure_loaded('base/taxonomia').
:- ensure_loaded('base/regiones').
:- ensure_loaded('base/recetas').
:- ensure_loaded('base/maridajes').
:- ensure_loaded(reglas).
