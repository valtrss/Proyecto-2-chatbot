/*  sinonimos.pl
    Formas alternativas con que el usuario puede nombrar las cosas.
    El chatbot ya reconoce automáticamente:
      - el identificador de cada producto, receta y región
        (parmigiano_reggiano -> "parmigiano reggiano"),
      - los nombres de tipo singular y plural de taxonomia.pl,
      - el nombre de cada región en regiones.pl.
    Aquí se agregan los demás.

      sinonimo(Clase, Id, Texto).   Clase: producto | receta | tipo | region | sello
*/
:- encoding(utf8).

% --- Productos ----------------------------------------------------------
sinonimo(producto, parmigiano_reggiano,   "parmesano").
sinonimo(producto, parmigiano_reggiano,   "parmigiano").
sinonimo(producto, grana_padano,          "grana").
sinonimo(producto, gorgonzola_dolce,      "gorgonzola").
sinonimo(producto, gorgonzola_piccante,   "gorgonzola").
sinonimo(producto, provolone_piccante,    "provolone").
sinonimo(producto, mozzarella_bufala,     "mozzarella de bufala").
sinonimo(producto, mozzarella_bufala,     "mozzarella di bufala").
sinonimo(producto, mozzarella_bufala,     "mozzarella").
sinonimo(producto, provola_ahumada,       "provola").
sinonimo(producto, provola_ahumada,       "provola affumicata").
sinonimo(producto, ricotta,               "ricota").
sinonimo(producto, prosciutto_san_daniele, "san daniele").
sinonimo(producto, prosciutto_classico,   "prosciutto").
sinonimo(producto, prosciutto_classico,   "jamon crudo").
sinonimo(producto, speck,                 "jamon ahumado").
sinonimo(producto, pancetta,              "panceta").
sinonimo(producto, salame_finocchiona,    "finocchiona").
sinonimo(producto, salame_spianata_piccante, "spianata").
sinonimo(producto, mortadella_pistacchio, "mortadela").
sinonimo(producto, mortadella_pistacchio, "mortadella").
sinonimo(producto, chianti_classico,      "chianti").
sinonimo(producto, chianti_riserva,       "chianti").
sinonimo(producto, nero_davola,           "nero d avola").
sinonimo(producto, nero_davola,           "amira").
sinonimo(producto, primitivo,             "primitivo di manduria").
sinonimo(producto, lambrusco_grasparossa, "lambrusco").
sinonimo(producto, vin_santo,             "vinsanto").
sinonimo(producto, amaro_del_capo,        "amaro").
sinonimo(producto, spaghetti_gragnano,    "spaghetti di martino").
sinonimo(producto, spaghetti_gragnano,    "spaghetti di gragnano").
sinonimo(producto, paccheri_gragnano,     "paccheri").
sinonimo(producto, bucatini_gragnano,     "bucatini").
sinonimo(producto, linguine_granoro,      "linguine").
sinonimo(producto, tagliatelle_huevo,     "tagliatelle").
sinonimo(producto, spaghetti_integral,    "spaghetti integrales").
sinonimo(producto, pelati_san_marzano,    "san marzano").
sinonimo(producto, pelati_san_marzano,    "tomates san marzano").
sinonimo(producto, passata_gargano,       "passata").
sinonimo(producto, concentrado_mutti,     "concentrado de tomate").
sinonimo(producto, datterini_mutti,       "datterini").
sinonimo(producto, pesto_genovese,        "pesto").
sinonimo(producto, tartufata,             "salsa de trufa").
sinonimo(producto, tartufata,             "trufa").
sinonimo(producto, aceite_oliva,          "aceite").
sinonimo(producto, aceite_oliva,          "aceite de oliva").
sinonimo(producto, balsamico,             "aceto balsamico").
sinonimo(producto, balsamico,             "vinagre balsamico").
sinonimo(producto, peperoncino,           "aji").
sinonimo(producto, arroz_arborio,         "arborio").
sinonimo(producto, arroz_carnaroli,       "carnaroli").
sinonimo(producto, funghi_porcini,        "porcini").
sinonimo(producto, funghi_porcini,        "hongos porcini").
sinonimo(producto, alcaparras,            "capperi").
sinonimo(producto, aceitunas_negras,      "aceitunas").
sinonimo(producto, aceitunas_negras,      "olive").
sinonimo(producto, anchoas,               "acciughe").
sinonimo(producto, pinoli,                "pinones").
sinonimo(producto, harina_pizza,          "harina").
sinonimo(producto, harina_pizza,          "harina 00").
sinonimo(producto, cafe_borbone,          "cafe").
sinonimo(producto, cafe_borbone,          "borbone").
sinonimo(producto, savoiardi,             "galletas de champana").
sinonimo(producto, savoiardi,             "vainillas").
sinonimo(producto, tiramisu_listo,        "tiramisu listo").
sinonimo(producto, crema_pistacchio,      "crema de pistacho").

% --- Recetas ------------------------------------------------------------
sinonimo(receta, carbonara,             "spaghetti a la carbonara").
sinonimo(receta, carbonara,             "espagueti a la carbonara").
sinonimo(receta, amatriciana,           "bucatini all amatriciana").
sinonimo(receta, risotto_porcini,       "risotto").
sinonimo(receta, risotto_porcini,       "risotto de hongos").
sinonimo(receta, risotto_porcini,       "risotto ai funghi porcini").
sinonimo(receta, pasta_e_patate,        "pasta con papas").
sinonimo(receta, orecchiette_trapanese, "pesto trapanese").
sinonimo(receta, pesto_casero,          "pesto genovese").
sinonimo(receta, pesto_casero,          "pesto alla genovese").
sinonimo(receta, pesto_casero,          "pesto").
sinonimo(receta, trofie_pesto,          "trofie").
sinonimo(receta, ensalada_pesto,        "ensalada de pasta").
sinonimo(receta, ensalada_pesto,        "ensalada de pesto").
sinonimo(receta, linguine_anchoas,      "linguine con anchoas").
sinonimo(receta, linguine_pecorino,     "linguine con pecorino").
sinonimo(receta, linguine_pecorino,     "linguine integrales").
sinonimo(receta, tiramisu,              "tiramisu").

% --- Tipos --------------------------------------------------------------
sinonimo(tipo, embutido,       "fiambre").
sinonimo(tipo, embutido,       "fiambres").
sinonimo(tipo, vino_espumante, "espumantes").
sinonimo(tipo, vino_espumante, "espumoso").
sinonimo(tipo, digestivo,      "bajativo").
sinonimo(tipo, digestivo,      "bajativos").
sinonimo(tipo, pasta,          "fideos").
sinonimo(tipo, bebida_alcoholica, "alcohol").
sinonimo(tipo, postre,         "postres").

% --- Regiones -----------------------------------------------------------
sinonimo(region, puglia,         "puglia").
sinonimo(region, lazio,          "roma").
sinonimo(region, campania,       "napoles").
sinonimo(region, emilia_romana,  "emilia").
sinonimo(region, emilia_romana,  "modena").
sinonimo(region, emilia_romana,  "bolonia").
sinonimo(region, emilia_romana,  "parma").
sinonimo(region, friuli,         "friuli venezia giulia").
sinonimo(region, sicilia,        "sicilia").
sinonimo(region, cerdena,        "sardegna").
sinonimo(region, toscana,        "florencia").
sinonimo(region, liguria,        "genova").
sinonimo(region, lombardia,      "milan").

% --- Sellos -------------------------------------------------------------
sinonimo(sello, dop,  "d o p").
sinonimo(sello, igp,  "i g p").
sinonimo(sello, doc,  "d o c").
sinonimo(sello, docg, "d o c g").
sinonimo(sello, igt,  "i g t").
sinonimo(sello, dop,  "denominacion de origen protegida").
sinonimo(sello, igp,  "indicacion geografica protegida").
