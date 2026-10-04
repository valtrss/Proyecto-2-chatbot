/*  cli.pl
    Responde una sola pregunta recibida como argumento y termina.
    Lo usa el backend en Python:
        $ swipl cli.pl "¿Cuánto cuesta el parmigiano?"
*/
:- encoding(utf8).
:- ensure_loaded(chatbot).

:- initialization(main, main).

main :-
    set_stream(user_output, encoding(utf8)),
    current_prolog_flag(argv, Args),
    atomic_list_concat(Args, ' ', Pregunta),
    responder(Pregunta, Respuesta),
    format("~w~n", [Respuesta]).
