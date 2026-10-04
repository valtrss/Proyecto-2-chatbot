/*  taxonomia.pl
    Jerarquía de tipos de producto (relación "es un").

      subtipo(Hijo, Padre).        % todo Hijo es también un Padre
      nombre_tipo(Tipo, Singular, Plural).

    Un tipo puede tener más de un padre (por ejemplo, el lambrusco es
    a la vez un vino tinto y un vino espumante). La regla es_un/2 de
    reglas.pl recorre esta jerarquía de forma transitiva.
*/
:- encoding(utf8).

% --- Lácteos ---------------------------------------------------------
subtipo(queso_duro,      queso).
subtipo(queso_semiduro,  queso).
subtipo(queso_blando,    queso).
subtipo(queso_azul,      queso).
subtipo(queso_fresco,    queso).
subtipo(pecorino,        queso).
subtipo(gorgonzola,      queso_azul).
subtipo(mozzarella,      queso_fresco).
subtipo(mascarpone,      queso_fresco).
subtipo(provola,         queso_semiduro).
subtipo(queso,           lacteo).

% --- Embutidos (curados y cocidos) ----------------------------------
subtipo(prosciutto,      embutido).
subtipo(salame,          embutido).
subtipo(nduja,           embutido).
subtipo(guanciale,       embutido).
subtipo(pancetta,        embutido).
subtipo(mortadella,      embutido).
subtipo(bresaola,        embutido).
subtipo(cotechino,       embutido).
subtipo(embutido,        carne).

% --- Bebidas -----------------------------------------------------------
subtipo(vino_tinto,      vino).
subtipo(vino_blanco,     vino).
subtipo(vino_espumante,  vino).
subtipo(vino_dulce,      vino).
subtipo(lambrusco,       vino_tinto).
subtipo(lambrusco,       vino_espumante).
subtipo(vino,            bebida_alcoholica).
subtipo(digestivo,       licor).
subtipo(licor,           bebida_alcoholica).
subtipo(bebida_alcoholica, bebida).
subtipo(cafe,            bebida).

% --- Pastas ------------------------------------------------------------
subtipo(spaghetti,       pasta_larga).
subtipo(linguine,        pasta_larga).
subtipo(bucatini,        pasta_larga).
subtipo(tagliatelle,     pasta_larga).
subtipo(paccheri,        pasta_corta).
subtipo(rigatoni,        pasta_corta).
subtipo(fusilli,         pasta_corta).
subtipo(orecchiette,     pasta_corta).
subtipo(trofie,          pasta_corta).
subtipo(pasta_mista,     pasta_corta).
subtipo(pasta_larga,     pasta).
subtipo(pasta_corta,     pasta).

% --- Tomates, salsas y condimentos ------------------------------------
subtipo(tomate_pelado,      tomate_en_conserva).
subtipo(passata,            tomate_en_conserva).
subtipo(concentrado_tomate, tomate_en_conserva).
subtipo(tomate_cherry,      tomate_en_conserva).
subtipo(tomate_en_conserva, conserva).
subtipo(pesto,              salsa).
subtipo(salsa_trufa,        salsa).
subtipo(aceite_oliva,       condimento).
subtipo(aceto_balsamico,    condimento).
subtipo(peperoncino,        condimento).

% --- Otros -------------------------------------------------------------
subtipo(arroz_arborio,      arroz_para_risotto).
subtipo(arroz_carnaroli,    arroz_para_risotto).
subtipo(arroz_para_risotto, arroz).
subtipo(funghi_porcini,     hongo).
subtipo(alcaparras,         conserva).
subtipo(aceitunas,          conserva).
subtipo(anchoas,            conserva).
subtipo(anchoas,            pescado).
subtipo(pinoli,             fruto_seco).
subtipo(savoiardi,          dulce).
subtipo(postre,             dulce).
subtipo(crema_untable,      dulce).

% --- Nombres para mostrar ---------------------------------------------
nombre_tipo(queso,          "queso",            "quesos").
nombre_tipo(queso_duro,     "queso duro",       "quesos duros").
nombre_tipo(queso_semiduro, "queso semiduro",   "quesos semiduros").
nombre_tipo(queso_blando,   "queso blando",     "quesos blandos").
nombre_tipo(queso_azul,     "queso azul",       "quesos azules").
nombre_tipo(queso_fresco,   "queso fresco",     "quesos frescos").
nombre_tipo(pecorino,       "pecorino",         "pecorinos").
nombre_tipo(gorgonzola,     "gorgonzola",       "gorgonzolas").
nombre_tipo(mozzarella,     "mozzarella",       "mozzarellas").
nombre_tipo(mascarpone,     "mascarpone",       "mascarpones").
nombre_tipo(provola,        "provola",          "provolas").
nombre_tipo(lacteo,         "lácteo",           "lácteos").
nombre_tipo(embutido,       "embutido",         "embutidos").
nombre_tipo(prosciutto,     "prosciutto",       "prosciuttos").
nombre_tipo(salame,         "salame",           "salames").
nombre_tipo(nduja,          "'nduja",           "'nduja").
nombre_tipo(guanciale,      "guanciale",        "guanciales").
nombre_tipo(pancetta,       "pancetta",         "pancettas").
nombre_tipo(mortadella,     "mortadela",        "mortadelas").
nombre_tipo(bresaola,       "bresaola",         "bresaolas").
nombre_tipo(cotechino,      "cotechino",        "cotechinos").
nombre_tipo(carne,          "carne",            "carnes").
nombre_tipo(vino,           "vino",             "vinos").
nombre_tipo(vino_tinto,     "vino tinto",       "vinos tintos").
nombre_tipo(vino_blanco,    "vino blanco",      "vinos blancos").
nombre_tipo(vino_espumante, "vino espumante",   "vinos espumantes").
nombre_tipo(vino_dulce,     "vino dulce",       "vinos dulces").
nombre_tipo(lambrusco,      "lambrusco",        "lambruscos").
nombre_tipo(licor,          "licor",            "licores").
nombre_tipo(digestivo,      "digestivo",        "digestivos").
nombre_tipo(bebida_alcoholica, "bebida alcohólica", "bebidas alcohólicas").
nombre_tipo(bebida,         "bebida",           "bebidas").
nombre_tipo(cafe,           "café",             "cafés").
nombre_tipo(pasta,          "pasta",            "pastas").
nombre_tipo(pasta_larga,    "pasta larga",      "pastas largas").
nombre_tipo(pasta_corta,    "pasta corta",      "pastas cortas").
nombre_tipo(spaghetti,      "spaghetti",        "spaghetti").
nombre_tipo(linguine,       "linguine",         "linguine").
nombre_tipo(bucatini,       "bucatini",         "bucatini").
nombre_tipo(tagliatelle,    "tagliatelle",      "tagliatelle").
nombre_tipo(paccheri,       "paccheri",         "paccheri").
nombre_tipo(rigatoni,       "rigatoni",         "rigatoni").
nombre_tipo(fusilli,        "fusilli",          "fusilli").
nombre_tipo(orecchiette,    "orecchiette",      "orecchiette").
nombre_tipo(trofie,         "trofie",           "trofie").
nombre_tipo(pasta_mista,    "pasta mista",      "pasta mista").
nombre_tipo(tomate_en_conserva, "tomate en conserva", "tomates en conserva").
nombre_tipo(tomate_pelado,  "tomate pelado",    "tomates pelados").
nombre_tipo(passata,        "passata de tomate", "passatas de tomate").
nombre_tipo(concentrado_tomate, "concentrado de tomate", "concentrados de tomate").
nombre_tipo(tomate_cherry,  "tomate cherry",    "tomates cherry").
nombre_tipo(conserva,       "conserva",         "conservas").
nombre_tipo(salsa,          "salsa",            "salsas").
nombre_tipo(pesto,          "pesto",            "pestos").
nombre_tipo(salsa_trufa,    "salsa de trufa",   "salsas de trufa").
nombre_tipo(condimento,     "condimento",       "condimentos").
nombre_tipo(aceite_oliva,   "aceite de oliva",  "aceites de oliva").
nombre_tipo(aceto_balsamico, "aceto balsámico", "acetos balsámicos").
nombre_tipo(peperoncino,    "peperoncino",      "peperoncinos").
nombre_tipo(arroz,          "arroz",            "arroces").
nombre_tipo(arroz_para_risotto, "arroz para risotto", "arroces para risotto").
nombre_tipo(arroz_arborio,  "arroz arborio",    "arroces arborio").
nombre_tipo(arroz_carnaroli, "arroz carnaroli", "arroces carnaroli").
nombre_tipo(hongo,          "hongo",            "hongos").
nombre_tipo(funghi_porcini, "funghi porcini",   "funghi porcini").
nombre_tipo(alcaparras,     "alcaparras",       "alcaparras").
nombre_tipo(aceitunas,      "aceitunas",        "aceitunas").
nombre_tipo(anchoas,        "anchoas",          "anchoas").
nombre_tipo(pescado,        "pescado",          "pescados").
nombre_tipo(pinoli,         "piñones",          "piñones").
nombre_tipo(fruto_seco,     "fruto seco",       "frutos secos").
nombre_tipo(harina,         "harina",           "harinas").
nombre_tipo(dulce,          "dulce",            "dulces").
nombre_tipo(postre,         "postre",           "postres").
nombre_tipo(savoiardi,      "savoiardi",        "savoiardi").
nombre_tipo(crema_untable,  "crema untable",    "cremas untables").
