/*  chatbot.pl
    Punto de entrada del chatbot en Prolog.

    Uso en consola:
        $ swipl chatbot.pl
        ?- iniciar.                 % conversación interactiva
        ?- responder("¿Qué vino va con la carbonara?", R).
        ?- analizar("precio del parmesano").   % muestra palabras e intención
*/
:- encoding(utf8).

:- ensure_loaded(base).
:- ensure_loaded('base/sinonimos').
:- ensure_loaded(lenguaje).
:- ensure_loaded(respuestas).

% responder(+Pregunta, -Respuesta): Pregunta y Respuesta son strings.
responder(Pregunta, Respuesta) :-
    normalizar(Pregunta, Palabras),
    intencion(Palabras, Intencion),
    (   catch(respuesta(Intencion, Respuesta0), E, (print_message(error, E), fail))
    ->  Respuesta = Respuesta0
    ;   Respuesta = "Entendí la pregunta, pero no pude armar una respuesta con lo que sé."
    ).

% analizar(+Pregunta): muestra cómo interpreta el chatbot una pregunta.
analizar(Pregunta) :-
    normalizar(Pregunta, Palabras),
    intencion(Palabras, Intencion),
    format("Palabras:   ~w~nIntención:  ~w~n", [Palabras, Intencion]).

iniciar :-
    respuesta(ayuda, Bienvenida),
    format("~w~n(escribe «salir» para terminar)~n", [Bienvenida]),
    bucle.

bucle :-
    format("~nTú: "), flush_output,
    read_line_to_string(user_input, Linea),
    (   ( Linea == end_of_file ; normalizar(Linea, [salir]) )
    ->  format("Bot: ¡Arrivederci!~n")
    ;   responder(Linea, R),
        format("Bot: ~w~n", [R]),
        bucle
    ).
